import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';

sealed class UsersState extends Equatable {
  const UsersState();
}

class UsersInitial extends UsersState {
  @override
  List<Object?> get props => [];
}

class UsersLoading extends UsersState {
  @override
  List<Object?> get props => [];
}

class UsersError extends UsersState {
  final String message;

  const UsersError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UsersLoaded extends UsersState {
  final List<UserEntity> users;
  final UserRole? roleFilter;
  final String searchQuery;

  const UsersLoaded({
    required this.users,
    this.roleFilter,
    this.searchQuery = '',
  });

  /// القائمة بعد تطبيق البحث والفلترة — تُحسب مباشرة، بدون تخزين نسخة مكررة بالـ state.
  List<UserEntity> get filteredUsers {
    final query = searchQuery.trim().toLowerCase();
    return users.where((u) {
      final matchesRole = roleFilter == null || u.role == roleFilter;
      final matchesQuery =
          query.isEmpty ||
          u.fullName.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query);
      return matchesRole && matchesQuery;
    }).toList();
  }

  int get totalCount => users.length;

  int get activeCount => users.where((u) => u.isActive).length;

  int get teacherCount => users.where((u) => u.role == UserRole.teacher).length;

  int get parentCount => users.where((u) => u.role == UserRole.parent).length;

  UsersLoaded copyWith({
    List<UserEntity>? users,
    UserRole? roleFilter,
    bool clearRoleFilter = false,
    String? searchQuery,
  }) {
    return UsersLoaded(
      users: users ?? this.users,
      roleFilter: clearRoleFilter ? null : (roleFilter ?? this.roleFilter),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [users, roleFilter, searchQuery];
}
