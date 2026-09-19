import 'package:albra3m4/core/database/database_helper.dart';
import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/feature/auth/Data/models/user_model.dart';
import 'package:albra3m4/feature/teachers_management/data/models/teacher_model.dart';

abstract class TeacherLocal {
  Future<List<UserModel>> getTeacher();

  Future<void> addTeacher(UserModel user, TeacherModel teacher);

  Future<void> updateTeacher(UserModel user, TeacherModel teacher);

  Future<void> deleteTeacher(String userId);
}

class TeacherLocalImp implements TeacherLocal {
  final DatabaseHelper helper;

  TeacherLocalImp(this.helper);

  @override
  Future<void> addTeacher(UserModel user, TeacherModel teacher) async {
    try {
      final db = await helper.database;

      await db.transaction((txn) async {
        // --------------------------------------------------------
        // 1. بيانات المستخدم
        // --------------------------------------------------------

        await txn.insert('users', user.toMap());

        // --------------------------------------------------------
        // 2. بيانات المعلم
        // --------------------------------------------------------

        await txn.insert('teachers', teacher.toMap());
      });
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  @override
  @override
  Future<void> updateTeacher(UserModel user, TeacherModel teacher) async {
    try {
      final db = await helper.database;

      await db.transaction((txn) async {
        // تحديث بيانات المستخدم
        await txn.update(
          'users',
          user.toMap(),
          where: 'uid = ?',
          whereArgs: [user.uid],
        );

        // تحديث بيانات المعلم
        await txn.update(
          'teachers',
          teacher.toMap(),
          where: 'user_id = ?',
          whereArgs: [user.uid],
        );
      });
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  @override
  Future<void> deleteTeacher(String userId) async {
    try {
      final db = await helper.database;

      await db.transaction((txn) async {
        // أولاً نحذف بيانات المعلم
        await txn.delete('teachers', where: 'user_id = ?', whereArgs: [userId]);

        // ثم نحذف حساب المستخدم
        await txn.delete('users', where: 'uid = ?', whereArgs: [userId]);
      });
    } catch (e) {
      throw LocalException(e.toString());
    }
  }

  // ============================================================
  // جلب المعلمين
  // ============================================================

  @override
  Future<List<UserModel>> getTeacher() async {
    try {
      final db = await helper.database;

      final result = await db.rawQuery(
        '''
      SELECT
        u.uid,
        u.full_name,
        u.school_id,
        u.email,
        u.phone,
        u.role,
        u.is_verified,
        u.is_active,
        u.created_at,

        t.id AS id,
        t.user_id AS user_id,
        t.birth_date AS birth_date,
        t.birth_place AS birth_place,
        t.academic_qualification AS academic_qualification,
        t.qualification_date AS qualification_date,
        t.specialization AS specialization,
        t.social_status AS social_status,
        t.children_count AS children_count,
        t.home_phone AS home_phone

      FROM users u

      LEFT JOIN teachers t
        ON u.uid = t.user_id

      WHERE u.role = ?

      ORDER BY u.created_at DESC
      ''',
        ['teacher'],
      );

      return result.map((map) => UserModel.fromMap(map)).toList();
    } catch (e) {
      throw LocalException(e.toString());
    }
  }
}
