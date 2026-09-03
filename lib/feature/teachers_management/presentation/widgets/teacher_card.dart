import 'package:flutter/material.dart';

import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';

import 'teacher_avatar.dart';
import 'status_pill.dart';

class TeacherCard extends StatelessWidget {
  final UserEntity teacher;
  final VoidCallback onTap;

  const TeacherCard({
    super.key,
    required this.teacher,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final teacherDetails = teacher.tDetails;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),

      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ),

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.line,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  AppColors.ink.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),

        child: Row(
          children: [
            TeacherAvatar(
              initials: _initials(
                teacher.fullName,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.fullName,

                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: AppColors.ink,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Row(
                    children: [
                      const Icon(
                        Icons.school_outlined,
                        size: 13,
                        color: AppColors.muted,
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          teacherDetails
                                  ?.specialization ??
                              'بدون تخصص',

                          style:
                              const TextStyle(
                            fontSize: 12,
                            color:
                                AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            StatusPill(
            isActive: teacher.isActive ,
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');

    if (parts.length == 1) {
      return parts.first.isNotEmpty
          ? parts.first[0]
          : '';
    }

    return '${parts[0][0]}${parts[1][0]}';
  }
}