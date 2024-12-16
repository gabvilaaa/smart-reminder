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
    return await openDatabase(path, version: 2, onCreate: _onCreate);
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
    await db.execute('''
    CREATE TABLE added_device (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      id_reminder INTEGER,
      id_device INTEGER    
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
    reminder['updated_at'] = DateTime.now().toString();
    return await db
        .update('reminders', reminder, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearReminders() async {
    final db = await database;
    return await db.delete('reminders', where: 'id >= 0 ');
  }

  Future<List<Map<String, dynamic>>> getReminders() async {
    final db = await database;
    return await db.query('reminders');
  }

  Future<int> insertAddedDevices(Map<String, dynamic> addedDevice) async {
    final db = await database;
    return await db.insert('added_device', addedDevice);
  }

  Future<int> updateAddedDevices(int id, Map<String, dynamic> added_device) async {
    final db = await database;

    return await db
        .update('added_device', added_device, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAddedDevices(int id) async {
    final db = await database;
    return await db.delete('added_device', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAddedDevices() async {
    final db = await database;
    return await db.query('added_device');
  }

  Future<List<Map<String, dynamic>>> getRemindersForDevice(int deviceId) async {
    final db = await database;
    final List<Map<String, dynamic>> reminders = await db.rawQuery('''
    SELECT r.*
    FROM reminders r
    JOIN added_device ad ON r.id = ad.id_reminder
    WHERE ad.id_device = ?
  ''', [deviceId]);

    return reminders;
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

  Future<int> updateUser(int id, Map<String, String> user) async {
    final db = await database;
    user['updated_at'] = DateTime.now().toString();
    return await db.update('users', user, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }
}
