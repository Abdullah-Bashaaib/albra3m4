part of 'teacher_cubit.dart';

class TeacherState extends Equatable {
  final bool isLoading;
  final String? success;
  final String? error;
  final String query;
  final List<UserEntity> teachers;
  final List<UserEntity> resultSearch;

  const TeacherState({
    this.isLoading = false,
    this.success,
    this.error,
    this.query = '',
    this.teachers = const [],
    this.resultSearch = const [],
  });

  /// القائمة التي ستعرضها الصفحة
  List<UserEntity> get displayedTeachers {
    if (query.trim().isEmpty) {
      return teachers;
    }

    return resultSearch;
  }

  @override
  List<Object?> get props => [
    isLoading,
    success,
    error,
    query,
    teachers,
    resultSearch,
  ];

  TeacherState copyWith({
    bool? isLoading,
    String? success,
    String? error,
    List<UserEntity>? teachers,
    String? query,
    List<UserEntity>? resultSearch,
  }) {
    return TeacherState(
      isLoading: isLoading ?? this.isLoading,
      success: success,
      error: error,
      teachers: teachers ?? this.teachers,
      query: query ?? this.query,
      resultSearch: resultSearch ?? this.resultSearch,
    );
  }
}
