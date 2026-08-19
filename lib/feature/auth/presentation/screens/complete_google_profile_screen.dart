import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_font.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/validators/auth_validators.dart';
import '../../../../core/utils/widgets/custom_button.dart';
import '../../../../core/utils/widgets/custom_text_form_field.dart';
import '../../domain/entities/user.dart';
import '../manger/login_cubit.dart';

/// تُعرض بعد أول تسجيل دخول عبر Google فقط (isNewUser = true).
/// الاسم والبريد يأتيان جاهزين من Google (للقراءة فقط) — المطلوب من
/// المستخدم فقط: اختيار دوره الحقيقي في الروضة، وإدخال رقم هاتفه.
class CompleteGoogleProfileScreen extends StatefulWidget {
  const CompleteGoogleProfileScreen({super.key, required this.user});

  final UserEntity user;

  @override
  State<CompleteGoogleProfileScreen> createState() =>
      _CompleteGoogleProfileScreenState();
}

class _CompleteGoogleProfileScreenState
    extends State<CompleteGoogleProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phoneController;

  UserRole? _selectedRole;
  bool _roleTouched = false;

  static const Map<UserRole, String> _availableRoles = {
    UserRole.teacher: 'معلمة',
    UserRole.parent: 'ولي أمر',
  };

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _roleTouched = true);

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid || _selectedRole == null) {
      return;
    }

    context.read<LoginCubit>().completeGoogleProfile(
      currentUser: widget.user,
      role: _selectedRole!,
      phone: _phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // TODO: استبدلها بمسار التوجيه حسب الدور (role-based navigation)
            // مثل باقي التطبيق — UC-003.
            // go() وليس push() — لا نريد المستخدم يرجع لشاشة إكمال البيانات
            // بزر الرجوع بعد ما خلص.
            context.go(AppRoutes.home);
          }

          if (state is LoginFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.surface],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: Icon(
                        Icons.person_pin_circle_rounded,
                        size: 72,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'خطوة أخيرة قبل البدء',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: AppFont.primary,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أكمل بياناتك للمتابعة إلى تطبيق البراعم',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: AppFont.primary,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // الاسم — من Google، للقراءة فقط
                    _ReadOnlyField(
                      label: 'الاسم',
                      value: widget.user.fullName,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // البريد — من Google، للقراءة فقط
                    _ReadOnlyField(
                      label: 'البريد الإلكتروني',
                      value: widget.user.email,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    // الدور — إلزامي، Teacher أو Parent فقط
                    _RoleDropdown(
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

                    // الهاتف — إلزامي
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
                    const SizedBox(height: 28),

                    BlocSelector<LoginCubit, LoginState, bool>(
                      selector: (state) => state is LoginLoading,
                      builder: (context, isLoading) {
                        return CustomButton(
                          label: 'حفظ ومتابعة',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _submit,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// حقل للعرض فقط (بيانات جاهزة من Google) — بنفس الشكل البصري لباقي
/// الحقول، لكن غير قابل للتعديل، ليبقى للمستخدم واضح أن هذه بياناته
/// الحقيقية من حساب Google الذي سجّل به للتو.
class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppFont.primary,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppFont.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}

/// Dropdown مخصص لاختيار الدور، بنفس نمط تصميم CustomTextFormField
/// (حدود دائرية، خلفية معبأة، رسالة خطأ تحت الحقل عند عدم الاختيار).
class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({
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
