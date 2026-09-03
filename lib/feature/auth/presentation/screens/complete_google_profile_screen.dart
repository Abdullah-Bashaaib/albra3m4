import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/core/utils/widgets/custom_snack_bar.dart';
import 'package:albra3m4/feature/auth/presentation/widgets/read_only_field.dart';
import 'package:albra3m4/feature/auth/presentation/widgets/role_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_font.dart';
import '../../../../core/routing/role_route_mapper.dart';
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
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  UserRole? _selectedRole;
  bool _roleTouched = false;

  static const Map<UserRole, String> _availableRoles = {
    UserRole.teacher: 'معلمة',
    UserRole.parent: 'ولي أمر',
  };

  @override
  void initState() {
    super.initState();
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
      fullName: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginGoogleProfileIncomplete) {
            CustomSnackBar.showInfo(
              context,
              'يرجى إكمال بياناتك للمتابعة إلى تطبيق البراعم',
            );
          }
          if (state is LoginSuccess) {
            CustomSnackBar.showSuccess(context, 'تم تسجيل الدخول بنجاح');
            context.go(state.user.role.dashboardRoute);
          }

          if (state is LoginFailure) {
            CustomSnackBar.showError(context, state.message);
          }
        },
        child: AppBackground(
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
                    const Text(
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

                    // البريد — من Google، للقراءة فقط
                    ReadOnlyField(
                      label: 'البريد الإلكتروني',
                      value: widget.user.email,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    // الدور — إلزامي، Teacher أو Parent فقط
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