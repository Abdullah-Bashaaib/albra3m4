import 'package:flutter/material.dart';

import '../../../../auth/domain/entities/user.dart';

class UserListItem extends StatelessWidget {
  final UserEntity user;
  final ValueChanged<bool> onStatusToggle;
  final ValueChanged<UserRole> onRoleChange;
  final VoidCallback onDelete;

  const UserListItem({
    super.key,
    required this.user,
    required this.onStatusToggle,
    required this.onRoleChange,
    required this.onDelete,
  });

  Color get _roleColor => switch (user.role) {
    UserRole.superAdmin => const Color(0xFF6C63FF),
    UserRole.manager => const Color(0xFFFF9F43),
    UserRole.teacher => const Color(0xFF00B8D9),
    UserRole.parent => const Color(0xFF2ECC71),
  };

  @override
  Widget build(BuildContext context) {
    final initial = user.fullName.trim().isNotEmpty
        ? user.fullName.trim().substring(0, 1)
        : '؟';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: _roleColor.withOpacity(0.12),
            child: Text(
              initial,
              style: TextStyle(
                color: _roleColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (!user.isVerified) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: Colors.orange.shade400,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.arabicLabel,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: _roleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: user.isActive,
                onChanged: onStatusToggle,
                activeColor: const Color(0xFF2ECC71),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey.shade500,
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                    return;
                  }
                  final role = UserRole.values.firstWhere(
                    (r) => r.name == value,
                  );
                  onRoleChange(role);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'manager', child: Text('تعيين كمدير')),
                  PopupMenuItem(value: 'teacher', child: Text('تعيين كمعلمة')),
                  PopupMenuItem(value: 'parent', child: Text('تعيين كولي أمر')),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'حذف المستخدم',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
