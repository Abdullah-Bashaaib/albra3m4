import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/feature/teachers_management/presentation/cubit/teacher_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: TextField(
        onChanged: (value) {
          context.read<TeacherCubit>().search(value);
        },

        decoration: InputDecoration(
          hintText: 'ابحثي عن معلمة أو فصل...',

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
    );
  }
}
