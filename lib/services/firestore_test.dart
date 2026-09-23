import 'firestore_service.dart';
import '../models/trip.dart';

Future<void> testFirestoreUpload() async {
  final firestoreService = FirestoreService();

  final testTrip = Trip(
    userId: 1,
    destination: 'Goa',
    numberOfDays: 3,
    budget: '15000',
    numberOfPeople: 2,
  );

  try {
    final cloudId = await firestoreService.uploadTrip(testTrip, 'test-user-1');

    print('Trip uploaded successfully!');
    print('Firestore document ID: $cloudId');
  } catch (error) {
    print('Firestore upload failed: $error');
  }
}
