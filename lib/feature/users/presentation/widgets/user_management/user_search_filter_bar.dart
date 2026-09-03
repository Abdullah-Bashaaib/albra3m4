import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_font.dart';
import '../../../../auth/domain/entities/user.dart';

class UserSearchFilterBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<UserRole?> onRoleSelected;
  final UserRole? selectedRole;

  const UserSearchFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onRoleSelected,
    required this.selectedRole,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: onSearchChanged,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو البريد الإلكتروني...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13.5,
                fontFamily: AppFont.primary,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _RoleChip(
                  label: 'الكل',
                  selected: selectedRole == null,
                  onTap: () => onRoleSelected(null),
                ),
                _RoleChip(
                  label: 'مدير',
                  selected: selectedRole == UserRole.manager,
                  onTap: () => onRoleSelected(UserRole.manager),
                ),
                _RoleChip(
                  label: 'معلمة',
                  selected: selectedRole == UserRole.teacher,
                  onTap: () => onRoleSelected(UserRole.teacher),
                ),
                _RoleChip(
                  label: 'ولي أمر',
                  selected: selectedRole == UserRole.parent,
                  onTap: () => onRoleSelected(UserRole.parent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontFamily: AppFont.primary,
          ),
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        showCheckmark: false,
      ),
    );
  }
}
