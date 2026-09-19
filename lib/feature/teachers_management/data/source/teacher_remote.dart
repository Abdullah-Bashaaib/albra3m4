import 'package:albra3m4/core/errors/exceptions.dart';
import 'package:albra3m4/feature/auth/Data/models/user_model.dart';
import 'package:albra3m4/feature/teachers_management/data/models/teacher_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TeacherRemote {
  Future<List<UserModel>> getTeacher(String schoolId);
  Future<void> saveTeacher(UserModel user, TeacherModel teacher);
  Future<void> deleteTeacher(String userId);
}

class TeacherRemoteImp implements TeacherRemote {
  final FirebaseFirestore firestore;

  TeacherRemoteImp(this.firestore);

  @override
  Future<void> saveTeacher(UserModel user, TeacherModel teacher) async {
    try {
      await firestore.runTransaction((transaction) async {
        final userRef = firestore.collection('users').doc(user.uid);

        final teacherRef = firestore.collection('teachers').doc(user.uid);

        transaction.set(userRef, user.toFirestore(), SetOptions(merge: true));

        transaction.set(teacherRef, teacher.toMap(), SetOptions(merge: true));
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteTeacher(String userId) async {
    try {
      await firestore.runTransaction((transaction) async {
        final userRef = firestore.collection('users').doc(userId);

        final teacherRef = firestore.collection('teachers').doc(userId);

        transaction.delete(userRef);
        transaction.delete(teacherRef);
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<UserModel>> getTeacher(String schoolId) async {
    try {
      final userSnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .where('school_id', isEqualTo: schoolId)
          .get();

      final teacherSnapshot = await firestore
          .collection('teachers')
          // .where('school_id', isEqualTo: schoolId)
          .get();

      final teacherMap = <String, TeacherModel>{};

      for (final doc in teacherSnapshot.docs) {
        final teacher = TeacherModel.fromJson(doc.data());
        teacherMap[teacher.userId] = teacher;
      }

      return userSnapshot.docs.map((doc) {
        final user = UserModel.fromFirestore(doc.data());

        return UserModel(
          uid: user.uid,
          fullName: user.fullName,
          schoolId: user.schoolId,
          email: user.email,
          phone: user.phone,
          role: user.role,
          isVerified: user.isVerified,
          isActive: user.isActive,
          createdAt: user.createdAt,
          tDetails: teacherMap[user.uid],
        );
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
