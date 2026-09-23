part of 'student_cubit.dart';

class StudentState extends Equatable {
  final List<StudentEntity> students;
  final List<StudentEntity> displayedStudents;
  final KindergartenClass? selectedClass;
  final String query;
  final bool isLoading;
  final bool isLoadingSave;
  final bool isLoadingDelete;
  final String? error;
  final String? success;

  const StudentState({
    this.students = const [],
    this.displayedStudents = const [],
    this.selectedClass,
    this.query = '',
    this.isLoading = false,
    this.isLoadingSave = false,
    this.isLoadingDelete = false,
    this.error,
    this.success,
  });

  StudentState copyWith({
    List<StudentEntity>? students,
    List<StudentEntity>? displayedStudents,
    Object? selectedClass = _sentinel,
    String? query,
    bool? isLoading,
    bool? isLoadingSave,
    bool? isLoadingDelete,
    Object? error = _sentinel,
    Object? success = _sentinel,
  }) {
    return StudentState(
      students: students ?? this.students,
      displayedStudents: displayedStudents ?? this.displayedStudents,
      selectedClass: selectedClass == _sentinel
          ? this.selectedClass
          : selectedClass as KindergartenClass?,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      isLoadingSave: isLoadingSave ?? this.isLoadingSave,
      isLoadingDelete: isLoadingDelete ?? this.isLoadingDelete,
      error: error == _sentinel ? this.error : error as String?,
      success: success == _sentinel ? this.success : success as String?,
    );
  }

  @override
  List<Object?> get props => [
    students,
    displayedStudents,
    selectedClass,
    query,
    isLoading,
    isLoadingSave,
    isLoadingDelete,
    error,
    success,
  ];
}

// sentinel value for nullable copyWith params
const Object _sentinel = Object();
