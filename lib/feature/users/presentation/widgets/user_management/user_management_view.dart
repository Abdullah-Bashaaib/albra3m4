import 'package:albra3m4/feature/users/presentation/manager/users_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../manager/users_state.dart';
import 'user_list_item.dart';
import 'user_search_filter_bar.dart';
import 'user_stats_row.dart';

/// ⚠️ لا تُنشئ أي BlocProvider هنا — [UsersCubit] مزوَّد بالفعل عالمياً
/// من main.dart. هذا الـ widget فقط يستهلك النسخة الموجودة بأعلى الشجرة
/// ويطلب تحميل البيانات مرة واحدة عند دخول الشاشة (initState)، بدل ما
/// ينشئ نسخة جديدة كل ما يدخل المستخدم لتبويب "إدارة المستخدمين".
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

        // switch شامل (exhaustive) على كل حالات UsersState —
        // لو انضافت حالة جديدة لاحقاً ونسيت تتعامل معها هنا،
        // Dart يعطيك خطأ وقت الكتابة مباشرة.
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
                    return UserListItem(
                      user: user,
                      onStatusToggle: (_) => cubit.toggleUserStatus(user.uid),
                      onRoleChange: (role) =>
                          cubit.changeUserRole(user.uid, role),
                      onDelete: () => _confirmDelete(
                        context,
                        cubit,
                        user.uid,
                        user.fullName,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context,
      UsersCubit cubit,
      String uid,
      String name,) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف المستخدم "$name"؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              cubit.deleteUser(uid);
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}