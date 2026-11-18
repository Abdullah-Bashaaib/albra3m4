import 'package:albra3m4/feature/auth/domain/entities/app_permission.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/users/presentation/manager/teacher_permissions_cubit.dart';
import 'package:albra3m4/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shared assignment dialog used by the school manager and super admin.
class TeacherPermissionsDialog extends StatefulWidget {
  final UserEntity teacher;
  const TeacherPermissionsDialog({super.key, required this.teacher});

  static Future<UserEntity?> show(
    BuildContext context, {required UserEntity teacher},
  ) {
    return showDialog<UserEntity>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider<TeacherPermissionsCubit>(
        create: (_) => sl<TeacherPermissionsCubit>(),
        child: TeacherPermissionsDialog(teacher: teacher),
      ),
    );
  }

  @override
  State<TeacherPermissionsDialog> createState() => _TeacherPermissionsDialogState();
}

class _TeacherPermissionsDialogState extends State<TeacherPermissionsDialog> {
  late final Set<AppPermission> _selected = {...widget.teacher.permissions};

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherPermissionsCubit, TeacherPermissionsState>(
      listener: (context, state) {
        if (state is TeacherPermissionsSaved) {
          Navigator.of(context).pop(state.user);
        } else if (state is TeacherPermissionsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final saving = state is TeacherPermissionsSaving;
        return AlertDialog(
          title: const Text('التكليفات الإدارية'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.teacher.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('حددي المهام الإضافية لهذه المعلمة. '
                      'ستبقى معلمة، ويمكن اختيار أكثر من قسم.'),
                  const SizedBox(height: 12),
                  for (final permission in AppPermission.values)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(permission.arabicLabel),
                      value: _selected.contains(permission),
                      onChanged: saving ? null : (checked) {
                        setState(() {
                          if (checked == true) {
                            _selected.add(permission);
                          } else {
                            _selected.remove(permission);
                          }
                        });
                      },
                    ),
                  const SizedBox(height: 8),
                  Text(_selected.isEmpty
                      ? 'لا توجد صلاحيات إدارية إضافية'
                      : 'عدد التكليفات المختارة: ${_selected.length}'),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: saving ? null : () => setState(_selected.clear),
                      child: const Text('إلغاء جميع التكليفات'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton.icon(
              onPressed: saving ? null : () {
                context.read<TeacherPermissionsCubit>().save(
                  widget.teacher,
                  AppPermission.values.where(_selected.contains).toList(),
                );
              },
              icon: saving
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save_outlined),
              label: const Text('حفظ التكليفات'),
            ),
          ],
        );
      },
    );
  }
}
