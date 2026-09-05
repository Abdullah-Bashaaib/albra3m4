import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/date_picker_card.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/decor_circle.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/empty_view.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/summary_row.dart';
import 'package:albra3m4/feature/teachers_management/presentation/widgets/teacher_attendance_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

/// شاشة عرض تحضير المعلمات — مخصصة للمديرة
class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar').then((_) => _load());
  }

  void _load() {
    context.read<AttendanceCubit>().loadTeacherAttendanceByDate(_selectedDate);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: AppBackground(
        child: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── AppBar ──────────────────────────────────────────
                _buildAppBar(context),

                // ── محتوى ────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── اختيار التاريخ ─────────────────────────────
                      DatePickerCard(date: _selectedDate, onTap: _pickDate),

                      const SizedBox(height: 20),

                      // ── ملخص سريع ──────────────────────────────────
                      if (!state.isLoadingAttendanceList)
                        SummaryRow(records: state.teacherAttendanceList),

                      const SizedBox(height: 16),

                      // ── قائمة المعلمات ─────────────────────────────
                      if (state.isLoadingAttendanceList)
                        _buildShimmer()
                      else if (state.error != null)
                        ErrorView(message: state.error!, onRetry: _load)
                      else if (state.teacherAttendanceList.isEmpty)
                        EmptyView(date: _selectedDate)
                      else
                        ...state.teacherAttendanceList.map(
                          (t) => TeacherAttendanceCard(attendance: t),
                        ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0277BD), Color(0xFF4FC3F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                left: -30,
                child: DecorCircle(size: 150, opacity: 0.08),
              ),
              Positioned(
                bottom: -20,
                right: -20,
                child: DecorCircle(size: 110, opacity: 0.12),
              ),
            ],
          ),
        ),
        title: const Text(
          'تحضير المعلمات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        5,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
