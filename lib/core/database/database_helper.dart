import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _databaseName = 'app_database.db';
  static const int _databaseVersion = 3;

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
    school_id TEXT NOT NULL,
    birth_date TEXT NOT NULL,
    birth_place TEXT NOT NULL,
    academic_qualification TEXT NOT NULL,
    qualification_date TEXT NOT NULL,
    specialization TEXT NOT NULL,
    social_status TEXT NOT NULL,
    children_count INTEGER NOT NULL DEFAULT 0,
    home_phone TEXT NOT NULL,
    mobile_phone TEXT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(uid)
  )
''');
    print('================= database Created =====================');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (_databaseVersion < 3) {
      await db.execute(
        ''''''
        '',
      );
      await db.execute('''
  CREATE TABLE teachers (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    school_id TEXT NOT NULL,
    birth_date TEXT NOT NULL,
    birth_place TEXT NOT NULL,
    academic_qualification TEXT NOT NULL,
    qualification_date TEXT NOT NULL,
    specialization TEXT NOT NULL,
    social_status TEXT NOT NULL,
    children_count INTEGER NOT NULL DEFAULT 0,
    home_phone TEXT NOT NULL,
    mobile_phone TEXT NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(uid)
  )
''');
    }
    print('==================database Upgraded ====================');
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
