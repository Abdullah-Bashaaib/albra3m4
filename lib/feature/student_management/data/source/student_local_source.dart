import 'dart:developer';
import 'package:albra3m4/core/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/student_entity.dart';
import '../models/student_model.dart';

abstract class StudentLocalSource {
  Future<List<StudentEntity>> getStudents();
  Future<void> saveStudent(StudentEntity student);
  Future<void> deleteStudent(String id);
}

class StudentLocalSourceImpl implements StudentLocalSource {
  final DatabaseHelper _dbHelper;

  StudentLocalSourceImpl(this._dbHelper);

  static const _table = 'students';

  Future<Database> get _db => _dbHelper.database;

  @override
  Future<List<StudentEntity>> getStudents() async {
    try {
      final db = await _db;
      final rows = await db.query(_table, orderBy: 'createdAt ASC');
      return rows.map((r) => StudentModel.fromDb(r)).toList();
    } catch (e) {
      log('StudentLocalSource.getStudents error: $e');
      return [];
    }
  }

  @override
  Future<void> saveStudent(StudentEntity student) async {
    final db = await _db;
    await db.insert(
      _table,
      StudentModel.fromEntity(student).toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteStudent(String id) async {
    final db = await _db;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
