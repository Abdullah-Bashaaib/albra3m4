import 'dart:developer';

import 'package:albra3m4/core/utils/widgets/custom_snack_bar.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/users/presentation/manager/users_cubit.dart';
import 'package:albra3m4/feature/users/presentation/widgets/user_management/user_search_filter_bar.dart';
import 'package:albra3m4/feature/users/presentation/widgets/user_management/user_stats_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_font.dart';
import '../../manager/users_state.dart';
import 'edit_user_dialog.dart';
import 'user_list_item.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  @override
  void initState() {
    super.initState();
    context.read<UsersCubit>().getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        final cubit = context.read<UsersCubit>();

        return switch (state) {
          UsersInitial() ||
          UsersLoading() => const Center(child: CircularProgressIndicator()),
          UsersError(:final message) => _ErrorView(
            message: message,
            onRetry: cubit.getAllUsers,
          ),
          UsersLoaded() => _LoadedContent(state: state, cubit: cubit),
        };
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final UsersLoaded state;
  final UsersCubit cubit;

  const _LoadedContent({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final users = state.filteredUsers;

    return Column(
      children: [
        const SizedBox(height: 12),
        UserStatsRow(
          total: state.totalCount,
          active: state.activeCount,
          teachers: state.teacherCount,
          parents: state.parentCount,
        ),
        const SizedBox(height: 16),
        UserSearchFilterBar(
          selectedRole: state.roleFilter,
          onSearchChanged: cubit.updateSearchQuery,
          onRoleSelected: cubit.filterByRole,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: users.isEmpty
              ? Center(
                  child: Text(
                    'لا يوجد مستخدمون مطابقون',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSuperAdmin = user.role == UserRole.superAdmin;

                    return UserListItem(
                      user: user,
                      onStatusToggle: (_) => cubit.toggleUserStatus(user.uid),
                      onRoleChange: isSuperAdmin
                          ? null
                          : (role) {
                              log(
                                '---------------- [message] : role $role [message]----------------',
                              );
                              log(
                                '---------------- [message] : uid ${user.fullName} [message]----------------',
                              );
                              cubit.changeUserRole(user.uid, role);
                              CustomSnackBar.showSuccess(
                                context,
                                'تم تغيير الدور بنجاح ${user.fullName} الى ${role.arabicLabel}',
                              );
                            },
                      onDelete: isSuperAdmin
                          ? null
                          : () => _confirmDelete(
                              context,
                              cubit,
                              user.uid,
                              user.fullName,
                            ),
                      onEdit: isSuperAdmin
                          ? null
                          : () => EditUserDialog.show(
                              context,
                              user: user,
                              onSave: (updatedUser) {
                                cubit.updateUser(updatedUser);
                                CustomSnackBar.showSuccess(
                                  context,
                                  'تم تحديث بيانات ${updatedUser.fullName} بنجاح',
                                );
                              },
                            ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    UsersCubit cubit,
    String uid,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'تأكيد الحذف',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: AppFont.primary),
        ),
        content: Text(
          'هل أنت متأكد من حذف المستخدم "$name"؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: AppFont.primary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteUser(uid);
              CustomSnackBar.showSuccess(
                context,
                'تم حذف المستخدم "$name" بنجاح',
              );
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red, fontFamily: AppFont.primary),
            ),
          ),
        ],
      ),
    );
  }
}
