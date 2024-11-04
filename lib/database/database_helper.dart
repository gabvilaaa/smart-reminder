import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'reminders.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate
    );
  }

  Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE reminders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      date TEXT,
      created_at TEXT,
      updated_at TEXT
    )
  ''');

  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      surname TEXT,
      email TEXT,
      password TEXT,
      profile_image TEXT,
      created_at TEXT,
      updated_at TEXT
      
    )
  ''');
  }

  Future<int> insertReminder(Map<String, String> reminder) async {
    final db = await database;
    reminder['created_at'] = DateTime.now().toString();
    reminder['updated_at'] = DateTime.now().toString();
    return await db.insert('reminders', reminder);
  }

  Future<int> updateReminder(int id, Map<String, String> reminder) async {
    final db = await database;
    reminder['updatedAt'] = DateTime.now().toString();
    return await db.update('reminders', reminder, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    final db = await database;
    return await db.query('reminders');
  }

  Future<int> insertUser(Map<String, String> user) async {
    final db = await database;
    user['created_at'] = DateTime.now().toString();
    user['updated_at'] = DateTime.now().toString();
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUser() async {
    final db = await database;
    return await db.query('users');
  }

  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }

  Future<bool> userExists(String email) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return results.isNotEmpty;
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUser(int id, Map<String, String> user) async {
    final db = await database;
    user['updated_at'] = DateTime.now().toString();
    return await db.update('users', user, where: 'id = ?', whereArgs: [id]);
  }
}

