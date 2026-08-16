import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_font.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
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
                        TextFormField(),
                        TextFormField(),
                      ],
                    ),
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
