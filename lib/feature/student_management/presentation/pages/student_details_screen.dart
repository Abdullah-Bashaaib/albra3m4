import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/utils/widgets/custom_snack_bar.dart';
import 'package:albra3m4/feature/student_management/domain/entities/student_entity.dart';
import 'package:albra3m4/feature/student_management/presentation/cubit/student_cubit.dart';
import 'package:albra3m4/feature/student_management/presentation/pages/student_form_screen.dart';
import 'package:albra3m4/feature/student_management/presentation/pages/student_grades_screen.dart';
import 'package:albra3m4/feature/student_management/presentation/widgets/classroom_badge.dart';
import 'package:albra3m4/feature/student_management/presentation/widgets/student_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentDetailsResult {
  final StudentEntity? updated;
  final bool deleted;
  const StudentDetailsResult({this.updated, this.deleted = false});
}

class StudentDetailsScreen extends StatefulWidget {
  final StudentEntity student;
  final int rankInClass;

  const StudentDetailsScreen({
    super.key,
    required this.student,
    required this.rankInClass,
  });

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  late StudentEntity _student = widget.student;
  bool _changed = false;

  Future<void> _edit() async {
    final result = await Navigator.push<StudentEntity>(
      context,
      MaterialPageRoute(builder: (_) => StudentFormScreen(existing: _student)),
    );
    if (result == null) return;
    setState(() {
      _student = result;
      _changed = true;
    });
  }

  Future<void> _openGrades() async {
    final cubit = context.read<StudentCubit>();
    final result = await Navigator.push<List<SubjectGrades>>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: StudentGradesScreen(student: _student),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _student = _student.copyWith(grades: result);
        _changed = true;
      });
    }
  }

  Future<void> _promote() async {
    final next = _student.classroom.next;
    if (next == null) {
      CustomSnackBar.showError(context, 'الطالب في أعلى مرحلة بالفعل');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('ترقية الصف'),
          content: Text(
            'هل تريد ترقية ${_student.fullName} من ${_student.classroom.shortLabel} إلى ${next.shortLabel}؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.apricot,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ترقية'),
            ),
          ],
        ),
      ),
    );

    if (confirm != true || !mounted) return;
    setState(() {
      _student = _student.copyWith(classroom: next);
      _changed = true;
    });
    if (mounted) {
      CustomSnackBar.showSuccess(
        context,
        'تم ترقية الطالب إلى ${next.arabicLabel}',
      );
    }
  }

  void _handleBack() {
    Navigator.pop(
      context,
      _changed ? StudentDetailsResult(updated: _student) : null,
    );
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف الطالب'),
          content: Text(
            'هل أنت متأكد من حذف ${_student.fullName}؟ لا يمكن التراجع عن هذه العملية.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true && mounted) {
      Navigator.pop(context, const StudentDetailsResult(deleted: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final avg = (_student.overallAverage * 100).toStringAsFixed(1);
    final rank = widget.rankInClass;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.apricot,
            foregroundColor: Colors.white,
            title: const Text(
              'ملف الطالب',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _handleBack,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'تعديل',
                onPressed: _edit,
              ),
            ],
          ),
          body: BlocListener<StudentCubit, StudentState>(
            listener: (ctx, state) {
              if (state.error != null)
                CustomSnackBar.showError(ctx, state.error!);
              if (state.success != null)
                CustomSnackBar.showSuccess(ctx, state.success!);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
              children: [
                // ── Header card ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE65100), Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.apricot.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      StudentAvatar(initials: _student.initials, size: 72),
                      const SizedBox(height: 12),
                      Text(
                        _student.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClassroomBadge(classroom: _student.classroom),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _student.gender.arabicLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // stats row
                      Row(
                        children: [
                          _StatPill(
                            label: 'المتوسط',
                            value: '$avg%',
                            icon: Icons.bar_chart_rounded,
                          ),
                          const SizedBox(width: 10),
                          if (_student.grades.isNotEmpty)
                            _StatPill(
                              label: 'الترتيب',
                              value: _rankLabel(rank),
                              icon: Icons.emoji_events_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ── Actions row ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.grade_rounded,
                        label: 'الدرجات',
                        color: AppColors.primary,
                        onTap: _openGrades,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.upgrade_rounded,
                        label: 'ترقية الصف',
                        color: const Color(0xFF26A69A),
                        onTap: _promote,
                        disabled: _student.classroom.next == null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Info card ────────────────────────────────────────────────
                _InfoCard(
                  children: [
                    _InfoRow(
                      icon: Icons.cake_outlined,
                      label: 'تاريخ الميلاد',
                      value: _fmtDate(_student.birthDate),
                    ),
                    _InfoRow(
                      icon: Icons.class_outlined,
                      label: 'الصف الدراسي',
                      value: _student.classroom.arabicLabel,
                    ),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'هاتف ولي الأمر',
                      value: _student.guardianPhone ?? 'غير محدد',
                      ltr: true,
                    ),
                    _InfoRow(
                      icon: Icons.notes_rounded,
                      label: 'ملاحظات',
                      value: _student.notes ?? 'لا يوجد',
                      last: true,
                    ),
                  ],
                ),

                if (_student.grades.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _SectionHeader(title: 'ملخص الدرجات'),
                  const SizedBox(height: 10),
                  ..._student.grades.map((g) => _GradeSummaryRow(grade: g)),
                ],
              ],
            ),
          ),

          // ── Bottom actions ────────────────────────────────────────────────
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              decoration: const BoxDecoration(
                color: AppColors.cream,
                border: Border(top: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.dangerFg,
                      ),
                      label: const Text(
                        'حذف',
                        style: TextStyle(
                          color: AppColors.dangerFg,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.dangerBg,
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _edit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('تعديل البيانات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.apricot,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _rankLabel(int r) {
    if (r == 1) return '🥇 الأول';
    if (r == 2) return '🥈 الثاني';
    if (r == 3) return '🥉 الثالث';
    return 'المركز $r';
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool disabled;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: disabled ? AppColors.line : color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: disabled
                  ? Colors.transparent
                  : color.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: disabled ? AppColors.muted : color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: disabled ? AppColors.muted : color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool ltr;
  final bool last;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.ltr = false,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.apricot),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                value,
                textDirection: ltr ? TextDirection.ltr : null,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        if (!last) const Divider(height: 1, indent: 46),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.apricot,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _GradeSummaryRow extends StatelessWidget {
  final SubjectGrades grade;
  const _GradeSummaryRow({required this.grade});

  @override
  Widget build(BuildContext context) {
    final pct = grade.yearlyAverage;
    Color c = pct >= 0.85
        ? AppColors.success
        : pct >= 0.60
        ? AppColors.warning
        : AppColors.danger;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                grade.subjectName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.ink,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: AppColors.line,
                  valueColor: AlwaysStoppedAnimation<Color>(c),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(pct * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
