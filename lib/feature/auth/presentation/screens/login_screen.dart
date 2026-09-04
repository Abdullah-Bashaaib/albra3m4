import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/utils/validators/auth_validators.dart';
import 'package:albra3m4/core/utils/widgets/custom_button.dart';
import 'package:albra3m4/core/utils/widgets/custom_snack_bar.dart';
import 'package:albra3m4/core/utils/widgets/custom_text_form_field.dart';
import 'package:albra3m4/feature/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_font.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/routing/role_route_mapper.dart';
import '../../../../core/utils/widgets/app_background.dart';
import '../manger/login_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<LoginCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            CustomSnackBar.showSuccess(context, 'تم تسجيل الدخول بنجاح!');
            context.go(state.user.role.dashboardRoute, extra: state.user);
          }

          if (state is LoginGoogleProfileIncomplete) {
            // أول تسجيل دخول عبر Google — لازم يكمّل بياناته أولاً.
            // push() وليس go() — عشان زر الرجوع يرجّعه لشاشة الدخول
            // لو غيّر رأيه قبل إكمال البيانات.
            CustomSnackBar.showInfo(
              context,
              'يرجى إكمال بياناتك الشخصية أولاً.',
            );
            context.push(AppRoutes.completeGoogleProfile, extra: state.user);
          }
          if (state is LoginFailure) {
            CustomSnackBar.showError(context, state.message);
          }
        },
        child: AppBackground(
          child: SafeArea(
            bottom: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Image.asset(
                              'assets/images/logo01.png',
                              height: 180,
                              width: MediaQuery.of(context).size.width * 0.5,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'مرحباً بك !',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontFamily: AppFont.primary,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "سجل الدخول للوصول إلى حسابك",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFont.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        CustomTextFormField(
                          controller: _emailController,
                          validator: AuthValidators.validateEmail,
                          suffixIcon: Icon(
                            Icons.email,
                            color: AppColors.primary,
                          ),
                          textInputAction: TextInputAction.next,
                          label: 'بريدك الالكتروني',
                          obscureText: false,
                          autoFocus: true,
                          enabled: true,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16.0),
                        CustomTextFormField(
                          controller: _passwordController,
                          validator: AuthValidators.validateLoginPassword,
                          textInputAction: TextInputAction.done,
                          label: 'كلمة المرور',
                          obscureText: true,
                          autoFocus: false,
                          enabled: true,
                          keyboardType: TextInputType.visiblePassword,
                        ),
                        const SizedBox(height: 5.0),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CustomButton(
                            label: 'نسيت كلمة المرور؟',
                            onPressed: () {},
                            variant: ButtonVariant.text,
                            width: 200,
                            fontSize: 14,
                            height: 35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        BlocSelector<LoginCubit, LoginState, bool>(
                          selector: (state) => state is LoginLoading,
                          builder: (context, isLoading) {
                            return CustomButton(
                              label: 'تسجيل الدخول',
                              isLoading: isLoading,
                              onPressed: isLoading ? null : _submitLogin,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.3,
                                ),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'أو',
                                style: TextStyle(
                                  fontFamily: AppFont.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.3,
                                ),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        BlocSelector<LoginCubit, LoginState, bool>(
                          selector: (state) => state is LoginLoading,
                          builder: (context, isLoading) {
                            return GoogleSignInButton(
                              isLoading: isLoading,
                              onPressed: () =>
                                  context.read<LoginCubit>().loginWithGoogle(),
                            );
                          },
                        ),

                        const SizedBox(height: 50.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
