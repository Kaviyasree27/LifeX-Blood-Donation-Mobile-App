import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static Database? _database;

  // Open or create the database
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lifesaver.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create users table for authentication
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            username TEXT,
            password_hash TEXT,
            phone TEXT,
            gender TEXT,
            blood_group TEXT
          )
        ''');

        // Create donors table for donor info
        await db.execute('''
          CREATE TABLE donors(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER,
            gender TEXT,
            blood_group TEXT,
            phone TEXT,
            address TEXT,
            city TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  // Insert new user into users table
  static Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await getDatabase();
    await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Query user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await getDatabase();
    final users = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (users.isEmpty) return null;
    return users.first;
  }

  // Insert new donor into donors table
  static Future<void> insertDonor(Map<String, dynamic> donor) async {
    final db = await getDatabase();
    await db.insert('donors', donor, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Retrieve all donors
  static Future<List<Map<String, dynamic>>> getDonors() async {
    final db = await getDatabase();
    return db.query('donors');
  }

  // Optional: Clear donors table
  static Future<void> clearDonors() async {
    final db = await getDatabase();
    await db.delete('donors');
  }

  // Optional: Update password hash for user
  static Future<void> updateUserPassword(String email, String newPasswordHash) async {
    final db = await getDatabase();
    await db.update(
      'users',
      {'password_hash': newPasswordHash},
      where: 'email = ?',
      whereArgs: [email],
    );
  }
}