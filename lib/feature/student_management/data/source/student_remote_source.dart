import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/student_entity.dart';
import '../models/student_model.dart';

abstract class StudentRemoteSource {
  Future<List<StudentEntity>> getStudents();
  Future<void> saveStudent(StudentEntity student);
  Future<void> deleteStudent(String id);
}

class StudentRemoteSourceImpl implements StudentRemoteSource {
  final FirebaseFirestore _firestore;

  StudentRemoteSourceImpl(this._firestore);

  static const String _collection = 'students';

  @override
  Future<List<StudentEntity>> getStudents() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => StudentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      log('StudentRemoteSource.getStudents error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveStudent(StudentEntity student) async {
    try {
      final model = StudentModel.fromEntity(student);
      await _firestore
          .collection(_collection)
          .doc(student.id)
          .set(model.toJson(), SetOptions(merge: true));
    } catch (e) {
      log('StudentRemoteSource.saveStudent error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteStudent(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      log('StudentRemoteSource.deleteStudent error: $e');
      rethrow;
    }
  }
}
