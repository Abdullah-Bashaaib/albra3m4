import 'package:albra3m4/core/utils/snake_bar_helper.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/teacher_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/presentation/cubit/teacher_cubit.dart';

import 'teacher_details_screen.dart';
import 'teacher_form_screen.dart';

class TeachersListScreen extends StatelessWidget {
  const TeachersListScreen({super.key});

  Future<void> _openAdd(BuildContext context) async {
    final newTeacher = await Navigator.push<UserEntity>(
      context,
      MaterialPageRoute(builder: (_) => const TeacherFormScreen()),
    );

    if (newTeacher != null && context.mounted) {
      context.read<TeacherCubit>().addTeacher(newTeacher);
    }
  }

  Future<void> _openDetails(BuildContext context, UserEntity teacher) async {
    final result = await Navigator.push<TeacherDetailsResult>(
      context,
      MaterialPageRoute(builder: (_) => TeacherDetailsScreen(teacher: teacher)),
    );

    if (result == null || !context.mounted) {
      return;
    }

    if (result.deleted) {
      context.read<TeacherCubit>().deleteTeacher(teacher.uid);

      _showSnack(context, 'تم حذف المعلمة');
    } else if (result.updated != null) {
      context.read<TeacherCubit>().updateTeacher(result.updated!);

      _showSnack(context, 'تم حفظ التعديلات');
    }
  }

  void _showSnack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TeacherCubit, TeacherState>(
      listener: (context, state) {
        if (state.error != null) {
          SnackBarHelper.error(context, state.error!);
        }
        if (state.success != null) {
          SnackBarHelper.success(context, state.success!);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المعلمات'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: BlocBuilder<TeacherCubit, TeacherState>(
                  buildWhen: (previous, current) =>
                      previous.teachers.length != current.teachers.length,
                  builder: (context, state) {
                    return Text(
                      '${state.teachers.length} معلمة',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        body: BlocBuilder<TeacherCubit, TeacherState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: TextField(
                    onChanged: context.read<TeacherCubit>().search,

                    decoration: InputDecoration(
                      hintText: 'ابحثي عن معلمة...',
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.muted,
                      ),
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.line),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: state.displayedTeachers.isEmpty
                      ? Center(
                          child: Text(
                            state.query.isEmpty
                                ? 'لا توجد معلمات مضافة'
                                : 'لا توجد نتائج مطابقة لبحثك',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13.5,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                          itemCount: state.displayedTeachers.length,
                          itemBuilder: (context, index) {
                            final teacher = state.displayedTeachers[index];

                            return TeacherCard(
                              teacher: teacher,
                              onTap: () => _openDetails(context, teacher),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),

        // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        // floatingActionButton: BlocBuilder<TeacherCubit, TeacherState>(
        //   builder: (context, state) {
        //     return state.isLoading
        //         ? Center(child: CircularProgressIndicator())
        //         : Padding(
        //             padding: const EdgeInsets.only(right: 4, bottom: 4),
        //             child: FloatingActionButton.extended(
        //               onPressed: () => _openAdd(context),
        //               backgroundColor: AppColors.apricot,
        //               icon: const Icon(Icons.add),
        //               label: const Text(
        //                 'إضافة معلمة',
        //                 style: TextStyle(fontWeight: FontWeight.w800),
        //               ),
        //             ),
        //           );
        //   },
        // ),
      ),
    );
  }
}
