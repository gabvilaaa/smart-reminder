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
      reminder_id INTEGER,
      FOREIGN KEY (reminder_id) REFERENCES reminders(id)
    )
  ''');
  }

  Future<int> insertReminder(Map<String, String> reminder) async {
    final db = await database;
    reminder['createdAt'] = DateTime.now().toString();
    reminder['updatedAt'] = DateTime.now().toString();
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

  Future<int> insertUser(int id, Map<String, String> users) async {
    final db = await database;
    return await db.insert('user', users);
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

    // Consulta para verificar por email
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    // Retorna true se encontrar pelo menos um registro, caso contrário, false
    return results.isNotEmpty;
  }
}

