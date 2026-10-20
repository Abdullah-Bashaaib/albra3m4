import 'package:dartz/dartz.dart';
import '../entities/student_entity.dart';

abstract class StudentRepo {
  Future<Either<String, List<StudentEntity>>> getStudents();
  Future<Either<String, void>> saveStudent(StudentEntity student);
  Future<Either<String, void>> deleteStudent(String id);
  Future<Either<String, void>> updateGrades(
    String studentId,
    List<SubjectGrades> grades,
  );
}
