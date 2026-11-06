import 'package:albra3m4/feature/auth/domain/entities/app_permission.dart';
import 'package:albra3m4/feature/auth/presentation/manger/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract final class InternalDepartmentKeys {
  static String forPermission(AppPermission permission) =>
      'internal_${permission.name}';

  static AppPermission? fromKey(String key) {
    for (final permission in AppPermission.values) {
      if (key == forPermission(permission)) return permission;
    }
    return null;
  }
}

/// Departments do not have working CRUD modules yet.
class InternalDepartmentScreen extends StatelessWidget {
  final AppPermission permission;
  const InternalDepartmentScreen({super.key, required this.permission});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        final user = context.read<LoginCubit>().user;
        final authorized = user?.hasPermission(permission) ?? false;
        return Scaffold(
          appBar: AppBar(title: Text(permission.arabicLabel)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(authorized ? Icons.construction_outlined
                      : Icons.lock_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    authorized
                        ? 'تم السماح بالوصول إلى قسم ${permission.arabicLabel}'
                        : 'لم تعد لديك صلاحية الوصول إلى هذا القسم',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  if (authorized) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'وظائف القسم قيد التطوير. منح التكليف لا يغيّر دورك كمعلمة.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
