import 'dart:ui';

import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/core/utils/widgets/custom_snack_bar.dart';
import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/attendance/presentation/widgets/build_state_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_font.dart';

class StudentsAttendance extends StatefulWidget {
  const StudentsAttendance({super.key});

  @override
  State<StudentsAttendance> createState() => _StudentsAttendanceState();
}

class _StudentsAttendanceState extends State<StudentsAttendance> {
  bool isLoading = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  // دالة لتغيير التاريخ المحدد
  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // تنسيق التاريخ بدون الحاجة إلى intl
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$year-$month-$day';
  }

  // حفظ بيانات الحضور مؤقتًا
  void _saveAttendance() {
    CustomSnackBar.showSuccess(context, 'تم حفظ بيانات الحضور بنجاح');
  }

  // دالة لعرض مربع حوار سبب الغياب
  void _showAbsenceReasonDialog(dynamic absenceReasons, dynamic student) {
    final String studentId = student['id'];

    final TextEditingController reasonController = TextEditingController(
      text: absenceReasons[studentId] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سبب الغياب'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'أدخل سبب الغياب',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                absenceReasons[studentId] = reasonController.text.trim();
              });

              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2D2D3A),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text(
          'تحضير الطلاب',
          style: TextStyle(fontFamily: AppFont.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'اختر تاريخ',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAttendance,
            tooltip: 'حفظ التحضير',
          ),
        ],
      ),
      body: isLoading
          ? AppBackground(
              child: SafeArea(
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
          : _errorMessage != null
          ? AppBackground(
              child: SafeArea(
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            )
          : AppBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    // عرض التاريخ
                    Container(
                      padding: const EdgeInsets.all(16),
                      // color: Colors.grey.shade100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'تاريخ التحضير:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _formatDate(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    // الإحصائيات
                    BlocBuilder<AttendanceCubit, AttendanceState>(
                      builder: (context, state) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          // color: Colors.grey.shade200,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              BuildStateCard(
                                title: 'إجمالي الطلاب',
                                value: state.students.length.toString(),
                                color: Colors.blue,
                              ),
                              BuildStateCard(
                                title: 'الحضور',
                                value: state.attendanceStatus.values
                                    .where((e) => e)
                                    .length
                                    .toString(),
                                color: Colors.green,
                              ),
                              BuildStateCard(
                                title: 'الغياب',
                                value: state.attendanceStatus.values
                                    .where((e) => !e)
                                    .length
                                    .toString(),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // قائمة الطلاب
                    BlocBuilder<AttendanceCubit, AttendanceState>(
                      builder: (context, state) {
                        return Expanded(
                          child: state.students.isEmpty
                              ? const Center(
                                  child: Text('لا يوجد طلاب في هذه الحلقة'),
                                )
                              : ListView.builder(
                                  itemCount: state.students.length,
                                  itemBuilder: (context, index) {
                                    final student = state.students[index];

                                    final String studentId = student['id'];

                                    final bool isPresent =
                                        state.attendanceStatus[studentId] ??
                                        true;

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: isPresent
                                              ? Colors.green
                                              : Colors.red,
                                          child: Icon(
                                            isPresent
                                                ? Icons.check
                                                : Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(
                                          '${student['firstName'] ?? ''} '
                                          '${student['middleName'] ?? ''} '
                                          '${student['lastName'] ?? ''}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: AppFont.primary,
                                          ),
                                        ),

                                        // عرض سبب الغياب
                                        subtitle:
                                            !isPresent &&
                                                state
                                                        .absenceReasons[studentId]
                                                        ?.isNotEmpty ==
                                                    true
                                            ? Text(
                                                'سبب الغياب: '
                                                '${state.absenceReasons[studentId]}',
                                                style: TextStyle(
                                                  color: Colors.red.shade700,
                                                ),
                                              )
                                            : null,

                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // زر سبب الغياب
                                            if (!isPresent)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit_note,
                                                  color: Colors.orange,
                                                ),
                                                onPressed: () =>
                                                    _showAbsenceReasonDialog(
                                                      state.absenceReasons,
                                                      student,
                                                    ),
                                                tooltip: 'سبب الغياب',
                                              ),

                                            // مفتاح تبديل الحضور
                                            Switch(
                                              value: isPresent,
                                              activeColor: Colors.green,
                                              inactiveTrackColor:
                                                  Colors.red.shade200,
                                              inactiveThumbColor: Colors.red,
                                              onChanged: (value) {
                                                context
                                                    .read<AttendanceCubit>()
                                                    .updateAttendance(
                                                      studentId,
                                                    );

                                                // إذا أصبح حاضرًا
                                                // نحذف سبب الغياب
                                                if (value) {
                                                  context
                                                      .read<AttendanceCubit>()
                                                      .removeAbsence(studentId);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
