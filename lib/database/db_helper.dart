import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/trip.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'wander_genie.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ------------------------------------------------------------
  // CREATE DATABASE
  // ------------------------------------------------------------

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE trips(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        destination TEXT NOT NULL,
        numberOfDays INTEGER NOT NULL,
        budget TEXT NOT NULL,
        numberOfPeople INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        cloudId TEXT,
        syncStatus TEXT DEFAULT 'pending',
        lastSyncedAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // ------------------------------------------------------------
  // DATABASE UPGRADE
  // ------------------------------------------------------------

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS trips');
      await db.execute('''
        CREATE TABLE trips(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          destination TEXT NOT NULL,
          numberOfDays INTEGER NOT NULL,
          budget TEXT NOT NULL,
          numberOfPeople INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          cloudId TEXT,
          syncStatus TEXT DEFAULT 'pending',
          lastSyncedAt TEXT,
          updatedAt TEXT
        )
      ''');
    }

    if (oldVersion < 3) {
      // Add cloud sync fields if they don't exist
      try {
        await db.execute('ALTER TABLE trips ADD COLUMN cloudId TEXT');
      } catch (_) {}
      try {
        await db.execute(
          "ALTER TABLE trips ADD COLUMN syncStatus TEXT DEFAULT 'pending'",
        );
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE trips ADD COLUMN lastSyncedAt TEXT');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE trips ADD COLUMN updatedAt TEXT');
      } catch (_) {}

      // Also ensure users table has createdAt
      try {
        await db.execute('ALTER TABLE users ADD COLUMN createdAt TEXT');
      } catch (_) {}
    }
  }

  // ------------------------------------------------------------
  // USER METHODS
  // ------------------------------------------------------------

  Future<int> insertUser(User user) async {
    final db = await database;

    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<User?> getUser(String email, String password) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }

    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }

    return null;
  }

  Future<User> getOrCreateUserByEmail(String email, String name) async {
    final existing = await getUserByEmail(email);
    if (existing != null) {
      return existing;
    }
    final newUser = User(
      fullName: name.isNotEmpty ? name : 'Wanderer',
      email: email,
      password: 'firebase_auth_user',
    );
    final id = await insertUser(newUser);
    return newUser.copyWith(id: id);
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  // ------------------------------------------------------------
  // TRIP METHODS
  // ------------------------------------------------------------

  Future<int> insertTrip(Trip trip) async {
    final db = await database;

    final int id = await db.insert('trips', trip.toMap());

    return id;
  }

  Future<List<Trip>> getTrips() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) => Trip.fromMap(maps[i]));
  }

  Future<List<Trip>> getUnsyncedTrips() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: "syncStatus = 'pending' OR syncStatus = 'failed'",
    );

    return List.generate(maps.length, (i) => Trip.fromMap(maps[i]));
  }

  Future<List<Trip>> getTripsForUser(int userId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) => Trip.fromMap(maps[i]));
  }

  Future<Trip?> getTripById(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Trip.fromMap(maps.first);
    }

    return null;
  }

  Future<Trip?> getTripByCloudId(String cloudId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'trips',
      where: 'cloudId = ?',
      whereArgs: [cloudId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Trip.fromMap(maps.first);
    }

    return null;
  }

  Future<int> updateTrip(Trip trip) async {
    final db = await database;

    return await db.update(
      'trips',
      trip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<int> deleteTrip(int id) async {
    final db = await database;

    return await db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------------------------------------------
  // DEBUG / TEST
  // ------------------------------------------------------------

  Future<void> printAllTrips() async {
    final trips = await getTrips();

    for (final trip in trips) {
      print(
        'TRIP: '
        'id=${trip.id}, '
        'userId=${trip.userId}, '
        'destination=${trip.destination}, '
        'days=${trip.numberOfDays}, '
        'budget=${trip.budget}, '
        'people=${trip.numberOfPeople}, '
        'createdAt=${trip.createdAt}, '
        'cloudId=${trip.cloudId}, '
        'syncStatus=${trip.syncStatus}',
      );
    }
  }
}
