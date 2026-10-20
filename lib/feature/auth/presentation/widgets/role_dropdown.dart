import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';

/// Dropdown مخصص لاختيار الدور، بنفس نمط تصميم CustomTextFormField
/// (حدود دائرية، خلفية معبأة، رسالة خطأ تحت الحقل عند عدم الاختيار).
class RoleDropdown extends StatelessWidget {
  const RoleDropdown({
    super.key,
    required this.selectedRole,
    required this.showError,
    required this.roles,
    required this.onChanged,
  });

  final UserRole? selectedRole;
  final bool showError;
  final Map<UserRole, String> roles;
  final ValueChanged<UserRole?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<UserRole>(
          value: selectedRole,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          decoration: InputDecoration(
            labelText: 'أنا',
            labelStyle: TextStyle(
              fontFamily: AppFont.primary,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: AppColors.surface.withValues(alpha: 0.6),
            prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.0),
              borderSide: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.25),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.0),
              borderSide: BorderSide(
                color: showError
                    ? Colors.redAccent
                    : AppColors.textSecondary.withValues(alpha: 0.25),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.0),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          items: roles.entries
              .map(
                (entry) => DropdownMenuItem<UserRole>(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontFamily: AppFont.primary,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 4),
            child: Text(
              'يرجى اختيار دورك',
              style: TextStyle(
                fontFamily: AppFont.primary,
                fontSize: 12,
                color: Colors.redAccent,
              ),
            ),
          ),
      ],
    );
  }
}
