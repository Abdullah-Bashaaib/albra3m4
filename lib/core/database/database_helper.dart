import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _databaseName = 'app_database.db';
  static const int _databaseVersion = 6;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, _databaseName);

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        uid TEXT PRIMARY KEY,
        school_id TEXT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL,
        is_verified INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
  CREATE TABLE teachers (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    birth_date TEXT NOT NULL,
    birth_place TEXT NOT NULL,
    academic_qualification TEXT NOT NULL,
    qualification_date TEXT NOT NULL,
    specialization TEXT NOT NULL,
    social_status TEXT NOT NULL,
    children_count INTEGER NOT NULL DEFAULT 0,
    home_phone TEXT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(uid)
  )
''');
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        gender INTEGER NOT NULL DEFAULT 0,
        birthDate TEXT NOT NULL,
        classroom INTEGER NOT NULL DEFAULT 0,
        guardianPhone TEXT,
        notes TEXT,
        grades TEXT NOT NULL DEFAULT '[]',
        createdAt TEXT NOT NULL
      )
    ''');
    print('================= database Created =====================');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await db.execute('DROP TABLE teachers;');
      await db.execute('''
  CREATE TABLE teachers (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    birth_date TEXT NOT NULL,
    birth_place TEXT NOT NULL,
    academic_qualification TEXT NOT NULL,
    qualification_date TEXT NOT NULL,
    specialization TEXT NOT NULL,
    social_status TEXT NOT NULL,
    children_count INTEGER NOT NULL DEFAULT 0,
    home_phone TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(uid)
  )
''');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS students (
          id TEXT PRIMARY KEY,
          fullName TEXT NOT NULL,
          gender INTEGER NOT NULL DEFAULT 0,
          birthDate TEXT NOT NULL,
          classroom INTEGER NOT NULL DEFAULT 0,
          guardianPhone TEXT,
          notes TEXT,
          grades TEXT NOT NULL DEFAULT '[]',
          createdAt TEXT NOT NULL
        )
      ''');
    }
    log('================== database Upgraded ====================');
  }

  Future<void> close() async {
    final db = _database;

    if (db == null) {
      return;
    }

    await db.close();

    _database = null;
  }
}
