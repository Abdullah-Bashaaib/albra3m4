import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/utils/validators/auth_validators.dart';
import 'package:albra3m4/core/utils/widgets/custom_button.dart';
import 'package:albra3m4/core/utils/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_font.dart';
import '../manger/login_cubit.dart';
import '../widgets/forget_password_widget.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.surface],
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                MediaQuery
                    .of(context)
                    .size
                    .height -
                    MediaQuery
                        .of(context)
                        .padding
                        .top -
                    MediaQuery
                        .of(context)
                        .padding
                        .bottom,
              ),
              child: IntrinsicHeight(
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
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
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.5,
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
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16.0),
                      CustomTextFormField(
                          validator: AuthValidators.validateLoginPassword,
                          textInputAction: TextInputAction.none,
                          label: 'كلمة المرور',
                          obscureText: true,
                          autoFocus: true,
                          enabled: true,
                          keyboardType: TextInputType.visiblePassword
                      ),
                      const SizedBox(height: 5.0),
                      ForgetPasswordWidget(),
                      const SizedBox(height: 14),
                      CustomButton(label: 'تسجيل الدخول', onPressed: () {}),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.textSecondary.withValues(
                                  alpha: 0.3),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
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
                                  alpha: 0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GoogleSignInButton(
                        onPressed: context
                            .read<LoginCubit>()
                            .loginWithGoogle,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(label: 'إنشاء حساب',
                        onPressed: () {},
                        variant: ButtonVariant.outlined,),
                      const SizedBox(height: 20),
                    ],
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



