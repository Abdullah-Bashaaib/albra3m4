part of 'teacher_cubit.dart';

class TeacherState extends Equatable {
  final bool isLoading;
  final bool isLoadingEdit;
  final bool isLoadingDelete;
  final String? success;
  final String? error;
  final String query;
  final List<UserEntity> teachers;
  final List<UserEntity> resultSearch;

  const TeacherState({
    this.isLoading = false,
    this.isLoadingEdit = false,
    this.isLoadingDelete = false,
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
    isLoadingEdit,
    isLoadingDelete,
    success,
    error,
    query,
    teachers,
    resultSearch,
  ];

  TeacherState copyWith({
    bool? isLoading,
    bool? isLoadingEdit,
    bool? isLoadingDelete,
    String? success,
    String? error,
    List<UserEntity>? teachers,
    String? query,
    List<UserEntity>? resultSearch,
  }) {
    return TeacherState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingEdit: isLoadingEdit ?? this.isLoadingEdit,
      isLoadingDelete: isLoadingDelete ?? this.isLoadingDelete,
      success: success,
      error: error,
      teachers: teachers ?? this.teachers,
      query: query ?? this.query,
      resultSearch: resultSearch ?? this.resultSearch,
    );
  }
}
