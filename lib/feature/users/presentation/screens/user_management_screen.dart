import 'package:flutter/material.dart';

import '../../../../core/utils/widgets/app_background.dart';
import '../../../teachers_management/presentation/widgets/decorative_circle.dart';
import '../widgets/user_management/user_management_view.dart';

/// شاشة إدارة المستخدمين المستقلة للمشرف التقني.
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text(
          'إدارة المستخدمين',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: const [
              Positioned(
                top: -20,
                left: -20,
                child: DecorativeCircle(size: 100, opacity: 0.1),
              ),
              Positioned(
                bottom: -20,
                right: 20,
                child: DecorativeCircle(size: 80, opacity: 0.12),
              ),
            ],
          ),
        ),
      ),
      body: const AppBackground(
        child: SafeArea(
          child: UserManagementView(),
        ),
      ),
    );
  }
}
