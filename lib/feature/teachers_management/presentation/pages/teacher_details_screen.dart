import 'package:flutter/material.dart';

import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/domain/entities/teacher_entity.dart';

import '../widgets/teacher_avatar.dart';
import '../widgets/status_pill.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/teacher_info_card.dart';
import '../widgets/teacher_info_row.dart';

import 'teacher_form_screen.dart';

class TeacherDetailsResult {
  final UserEntity? updated;
  final bool deleted;

  const TeacherDetailsResult({
    this.updated,
    this.deleted = false,
  });
}

class TeacherDetailsScreen
    extends StatefulWidget {
  final UserEntity teacher;

  const TeacherDetailsScreen({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherDetailsScreen> createState() =>
      _TeacherDetailsScreenState();
}

class _TeacherDetailsScreenState
    extends State<TeacherDetailsScreen> {
  late UserEntity _teacher =
      widget.teacher;

  bool _changed = false;

  Future<void> _edit() async {
    final result =
        await Navigator.push<UserEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherFormScreen(
          existing: _teacher,
        ),
      ),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _teacher = result;
      _changed = true;
    });
  }

  Future<void> _delete() async {
    final confirmed =
        await showDeleteTeacherDialog(
      context,
      _teacher,
    );

    if (confirmed && mounted) {
      Navigator.pop(
        context,
        const TeacherDetailsResult(
          deleted: true,
        ),
      );
    }
  }

  void _handleBack() {
    Navigator.pop(
      context,
      _changed
          ? TeacherDetailsResult(
              updated: _teacher,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = _teacher.tDetails;

    return Directionality(
      textDirection: TextDirection.rtl,

      child: PopScope(
        canPop: false,

        onPopInvokedWithResult:
            (didPop, _) {
          if (!didPop) {
            _handleBack();
          }
        },

        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'ملف المعلمة',
            ),

            leading: IconButton(
              icon: const Icon(
                Icons.arrow_forward,
              ),
              onPressed: _handleBack,
            ),
          ),

          body: ListView(
            padding:
                const EdgeInsets.fromLTRB(
              18,
              22,
              18,
              24,
            ),

            children: [
              // --------------------------------------------------
              // Header
              // --------------------------------------------------

              Center(
                child: Column(
                  children: [
                    TeacherAvatar(
                      initials:
                          _initials(
                        _teacher.fullName,
                      ),
                      size: 76,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _teacher.fullName,

                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                        fontSize: 17,
                        color:
                            AppColors.ink,
                      ),
                    ),

                    const SizedBox(height: 8),

                    StatusPill(
                      isActive:
                          _teacher.isActive,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // --------------------------------------------------
              // User information
              // --------------------------------------------------

              TeacherInfoCard(
                children: [
                  TeacherInfoRow(
                    icon: Icons.email_outlined,
                    label: 'البريد الإلكتروني',
                    value: _teacher.email,
                    ltr: true,
                  ),

                  TeacherInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'رقم الجوال',
                    value:
                        _teacher.phone ??
                        details?.mobilePhone
                            .toString() ??
                        '-',
                    ltr: true,
                  ),

                  TeacherInfoRow(
                    icon:
                        Icons.verified_outlined,
                    label: 'حالة التحقق',
                    value:
                        _teacher.isVerified
                            ? 'تم التحقق'
                            : 'غير متحقق',
                    last: true,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // Birth information
              // --------------------------------------------------

              TeacherInfoCard(
                children: [
                  TeacherInfoRow(
                    icon: Icons.cake_outlined,
                    label: 'تاريخ الميلاد',
                    value: details == null
                        ? '-'
                        : _formatDate(
                            details.birthDate,
                          ),
                  ),

                  TeacherInfoRow(
                    icon:
                        Icons.location_on_outlined,
                    label: 'مكان الميلاد',
                    value:
                        details?.birthPlace ??
                            '-',
                  ),

                  TeacherInfoRow(
                    icon:
                        Icons.family_restroom,
                    label: 'الحالة الاجتماعية',
                    value: details == null
                        ? '-'
                        : _socialStatusLabel(
                            details
                                .socialStatus,
                          ),
                  ),

                  TeacherInfoRow(
                    icon:
                        Icons.child_care_outlined,
                    label: 'عدد الأبناء',
                    value:
                        details
                                ?.childrenCount
                                .toString() ??
                            '0',
                    last: true,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // Professional information
              // --------------------------------------------------

              TeacherInfoCard(
                children: [
                  TeacherInfoRow(
                    icon:
                        Icons.school_outlined,
                    label: 'المؤهل العلمي',
                    value:
                        details
                                ?.academicQualification ??
                            '-',
                  ),

                  TeacherInfoRow(
                    icon:
                        Icons.auto_stories_outlined,
                    label: 'التخصص',
                    value:
                        details?.specialization ??
                            '-',
                  ),

                  TeacherInfoRow(
                    icon:
                        Icons.calendar_today_outlined,
                    label:
                        'تاريخ الحصول على المؤهل',
                    value: details == null
                        ? '-'
                        : _formatDate(
                            details
                                .qualificationDate,
                          ),
                    last: true,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // Contact
              // --------------------------------------------------

              TeacherInfoCard(
                children: [
                  TeacherInfoRow(
                    icon: Icons.phone_outlined,
                    label: 'هاتف المنزل',
                    value: details == null
                        ? '-'
                        : details.homePhone
                            .toString(),
                    ltr: true,
                    last: true,
                  ),
                ],
              ),
            ],
          ),

          // ----------------------------------------------------
          // Bottom actions
          // ----------------------------------------------------

          bottomNavigationBar: SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                16,
              ),

              decoration:
                  const BoxDecoration(
                color: AppColors.cream,
                border: Border(
                  top: BorderSide(
                    color: AppColors.line,
                  ),
                ),
              ),

              child: Row(
                children: [
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: _delete,

                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color:
                            AppColors.dangerFg,
                      ),

                      label: const Text(
                        'حذف',
                        style: TextStyle(
                          color:
                              AppColors.dangerFg,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      style: OutlinedButton
                          .styleFrom(
                        backgroundColor:
                            AppColors
                                .dangerBg,
                        side:
                            BorderSide.none,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 12,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    flex: 2,
                    child: ElevatedButton
                        .icon(
                      onPressed: _edit,

                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),

                      label: const Text(
                        'تعديل البيانات',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _socialStatusLabel(
    SocialStatus status,
  ) {
    switch (status) {
      case SocialStatus.single:
        return 'عزباء';
      case SocialStatus.married:
        return 'متزوجة';
      case SocialStatus.divorced:
        return 'مطلقة';
      case SocialStatus.widowed:
        return 'أرملة';
    }
  }
}