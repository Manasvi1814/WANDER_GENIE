import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/trip.dart';
import 'firestore_service.dart';

enum SyncStatusResult {
  synced,
  savedLocallyNotLoggedIn,
  savedLocallySyncFailed,
}

class SaveTripResult {
  final int localId;
  final SyncStatusResult status;
  final String? cloudId;
  final String? errorMessage;

  SaveTripResult({
    required this.localId,
    required this.status,
    this.cloudId,
    this.errorMessage,
  });

  bool get isSynced => status == SyncStatusResult.synced;
  bool get isNotLoggedIn => status == SyncStatusResult.savedLocallyNotLoggedIn;
  bool get isSyncFailed => status == SyncStatusResult.savedLocallySyncFailed;
}

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Helper to get current Firebase User or null if not logged in.
  User? get currentFirebaseUser => _auth.currentUser;

  /// Get actual Firebase UID or null if unauthenticated.
  String? get firebaseUserId => _auth.currentUser?.uid;

  /// Ensure Firebase user is authenticated.
  /// If no user is logged in, attempt temporary Anonymous sign-in for testing.
  Future<User?> _ensureAuthenticated() async {
    if (_auth.currentUser != null) {
      debugPrint(
        'Existing Firebase user found. UID: ${_auth.currentUser!.uid}',
      );
      return _auth.currentUser;
    }

    try {
      debugPrint('========== FIREBASE AUTHENTICATION START ==========');
      debugPrint(
        'No active user found. Attempting temporary Anonymous Sign-In...',
      );
      final UserCredential credential = await _auth.signInAnonymously();
      final User? user = credential.user;

      if (user != null) {
        debugPrint('========== FIREBASE ANONYMOUS AUTH SUCCESS ==========');
        debugPrint('Actual Firebase UID: ${user.uid}');
        debugPrint('=====================================================');
      }
      return user;
    } catch (e, stackTrace) {
      debugPrint('========== FIREBASE AUTHENTICATION FAILED ==========');
      debugPrint('Error      : $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('====================================================');
      return null;
    }
  }

  /// Save trip locally to SQLite first, then attempt Firestore upload after ensuring auth.
  Future<SaveTripResult> saveAndSyncTrip(Trip trip) async {
    // 1. Validate trip data
    if (trip.destination.trim().isEmpty) {
      throw ArgumentError('Trip destination cannot be empty.');
    }
    if (trip.numberOfDays <= 0) {
      throw ArgumentError('Number of days must be greater than zero.');
    }
    if (trip.numberOfPeople <= 0) {
      throw ArgumentError('Number of travellers must be greater than zero.');
    }

    final String nowIso = DateTime.now().toIso8601String();

    // 2. Prepare local trip object
    final tripToInsert = trip.copyWith(
      createdAt: trip.createdAt ?? nowIso,
      updatedAt: trip.updatedAt ?? nowIso,
      syncStatus: 'pending',
    );

    // 3. Save locally to SQLite FIRST
    final int localId = await _dbHelper.insertTrip(tripToInsert);
    final savedLocalTrip = tripToInsert.copyWith(id: localId);

    debugPrint('Trip saved to SQLite with local ID: $localId');

    // 4. Ensure Firebase Authentication is available (sign in anonymously if needed)
    final User? user = await _ensureAuthenticated();

    if (user == null) {
      debugPrint(
        'Firebase authentication unavailable. Trip preserved in local SQLite.',
      );
      return SaveTripResult(
        localId: localId,
        status: SyncStatusResult.savedLocallySyncFailed,
        errorMessage: 'Firebase Authentication unavailable.',
      );
    }

    final String uid = user.uid;

    // 5. User is authenticated, attempt upload to Firestore
    try {
      String cloudId;
      if (savedLocalTrip.cloudId != null &&
          savedLocalTrip.cloudId!.isNotEmpty) {
        // Update existing document
        await _firestoreService.updateTripInCloud(savedLocalTrip, uid);
        cloudId = savedLocalTrip.cloudId!;
      } else {
        // New upload
        cloudId = await _firestoreService.uploadTrip(savedLocalTrip, uid);
      }

      // Update local SQLite record with synced details
      final syncedTrip = savedLocalTrip.copyWith(
        cloudId: cloudId,
        syncStatus: 'synced',
        lastSyncedAt: nowIso,
        updatedAt: nowIso,
      );
      await _dbHelper.updateTrip(syncedTrip);

      return SaveTripResult(
        localId: localId,
        status: SyncStatusResult.synced,
        cloudId: cloudId,
      );
    } catch (e, stackTrace) {
      debugPrint('Cloud sync failed during saveAndSyncTrip: $e\n$stackTrace');

      // Update SQLite record to 'failed' status so background sync can retry
      final failedTrip = savedLocalTrip.copyWith(syncStatus: 'failed');
      await _dbHelper.updateTrip(failedTrip);

      return SaveTripResult(
        localId: localId,
        status: SyncStatusResult.savedLocallySyncFailed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Synchronize all local and cloud data for authenticated user.
  Future<void> syncTrips() async {
    final User? user = await _ensureAuthenticated();
    if (user == null) {
      debugPrint('Skipping syncTrips: Firebase Authentication unavailable.');
      return;
    }

    final String uid = user.uid;
    debugPrint('Starting background sync for user: $uid');

    // 1. Upload unsynced local trips
    await _uploadUnsyncedTrips(uid);

    // 2. Fetch cloud trips and merge with local
    await _pullCloudTrips(uid);

    debugPrint('Sync completed for user: $uid');
  }

  /// Upload unsynced trips ('pending' or 'failed') for authenticated user.
  Future<void> _uploadUnsyncedTrips(String uid) async {
    final unsyncedTrips = await _dbHelper.getUnsyncedTrips();
    debugPrint('Found ${unsyncedTrips.length} unsynced trip(s)');

    final String nowIso = DateTime.now().toIso8601String();

    for (var trip in unsyncedTrips) {
      try {
        if (trip.cloudId == null || trip.cloudId!.isEmpty) {
          final cloudId = await _firestoreService.uploadTrip(trip, uid);
          final updatedTrip = trip.copyWith(
            cloudId: cloudId,
            syncStatus: 'synced',
            lastSyncedAt: nowIso,
            updatedAt: nowIso,
          );
          await _dbHelper.updateTrip(updatedTrip);
        } else {
          await _firestoreService.updateTripInCloud(trip, uid);
          final updatedTrip = trip.copyWith(
            syncStatus: 'synced',
            lastSyncedAt: nowIso,
            updatedAt: nowIso,
          );
          await _dbHelper.updateTrip(updatedTrip);
        }
      } catch (e) {
        debugPrint('Failed to sync trip localId=${trip.id}: $e');
        await _dbHelper.updateTrip(trip.copyWith(syncStatus: 'failed'));
      }
    }
  }

  /// Pull trips from Firestore and update local DB safely.
  Future<void> _pullCloudTrips(String uid) async {
    try {
      final rawCloudTrips = await _firestoreService.getRawTripsFromCloud(uid);
      debugPrint(
        'Fetched ${rawCloudTrips.length} cloud trip(s) from Firestore',
      );

      final fbUser = currentFirebaseUser;
      int localUserId = 1;
      if (fbUser != null && fbUser.email != null && fbUser.email!.isNotEmpty) {
        final localUser = await _dbHelper.getOrCreateUserByEmail(
          fbUser.email!,
          fbUser.displayName ?? '',
        );
        localUserId = localUser.id ?? 1;
      }

      final String nowIso = DateTime.now().toIso8601String();

      for (var map in rawCloudTrips) {
        final String? cloudId = map['cloudId'] as String?;
        if (cloudId == null || cloudId.isEmpty) continue;

        // Map userId to local integer user ID
        map['userId'] = localUserId;

        final cloudTrip = Trip.fromMap(map);
        final localTrip = await _dbHelper.getTripByCloudId(cloudId);

        if (localTrip == null) {
          // New trip from cloud, insert locally
          final newLocalTrip = cloudTrip.copyWith(
            syncStatus: 'synced',
            lastSyncedAt: nowIso,
          );
          await _dbHelper.insertTrip(newLocalTrip);
          debugPrint('Pulled new trip from cloud: ${cloudTrip.destination}');
        } else {
          // Compare update timestamps
          final DateTime cloudUpdated =
              DateTime.tryParse(
                cloudTrip.updatedAt ?? cloudTrip.createdAt ?? '',
              ) ??
              DateTime.fromMillisecondsSinceEpoch(0);

          final DateTime localUpdated =
              DateTime.tryParse(
                localTrip.updatedAt ?? localTrip.createdAt ?? '',
              ) ??
              DateTime.fromMillisecondsSinceEpoch(0);

          if (cloudUpdated.isAfter(localUpdated)) {
            final updatedLocal = cloudTrip.copyWith(
              id: localTrip.id,
              userId: localTrip.userId,
              syncStatus: 'synced',
              lastSyncedAt: nowIso,
            );
            await _dbHelper.updateTrip(updatedLocal);
            debugPrint(
              'Updated local trip from cloud: ${cloudTrip.destination}',
            );
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to pull cloud trips: $e\n$stackTrace');
    }
  }
}
