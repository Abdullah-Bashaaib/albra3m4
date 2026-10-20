import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:albra3m4/core/utils/validators/auth_validators.dart';
import 'package:albra3m4/core/utils/widgets/custom_button.dart';
import 'package:albra3m4/core/utils/widgets/custom_text_form_field.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/auth/presentation/widgets/read_only_field.dart';
import 'package:albra3m4/feature/auth/presentation/widgets/role_dropdown.dart';
import 'package:flutter/material.dart';

class EditUserDialog extends StatefulWidget {
  final UserEntity user;
  final ValueChanged<UserEntity> onSave;

  const EditUserDialog({super.key, required this.user, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    required UserEntity user,
    required ValueChanged<UserEntity> onSave,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EditUserDialog(user: user, onSave: onSave),
    );
  }

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late UserRole? _selectedRole;
  bool _roleTouched = false;

  static const Map<UserRole, String> _availableRoles = {
    UserRole.manager: 'مديرة',
    UserRole.teacher: 'معلمة',
    UserRole.parent: 'ولي أمر',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _selectedRole = widget.user.role == UserRole.superAdmin
        ? null
        : widget.user.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _roleTouched = true);

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || _selectedRole == null) return;

    final updatedUser = widget.user.copyWith(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
    );

    widget.onSave(updatedUser);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primaryDark,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تعديل بيانات المستخدم',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              fontFamily: AppFont.primary,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'قم بتحديث المعلومات الشخصية والدور',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: AppFont.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 20),

                // الاسم
                CustomTextFormField(
                  controller: _nameController,
                  label: 'الاسم',
                  obscureText: false,
                  autoFocus: false,
                  enabled: true,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال الاسم';
                    }
                    if (value.trim().length < 3) {
                      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                    }
                    return null;
                  },
                  suffixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // البريد الإلكتروني (للقراءة فقط)
                ReadOnlyField(
                  label: 'البريد الإلكتروني',
                  value: widget.user.email,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // اختيار الدور
                RoleDropdown(
                  selectedRole: _selectedRole,
                  showError: _roleTouched && _selectedRole == null,
                  roles: _availableRoles,
                  onChanged: (role) {
                    setState(() {
                      _selectedRole = role;
                      _roleTouched = true;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // رقم الهاتف
                CustomTextFormField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  obscureText: false,
                  autoFocus: false,
                  enabled: true,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  validator: AuthValidators.validateRequiredPhone,
                  suffixIcon: Icon(
                    Icons.phone_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontFamily: AppFont.primary,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        label: 'حفظ التعديلات',
                        isLoading: false,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
