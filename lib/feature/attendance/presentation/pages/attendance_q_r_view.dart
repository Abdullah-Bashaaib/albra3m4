import 'package:albra3m4/core/utils/snake_bar_helper.dart';
import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AttendanceQRView extends StatefulWidget {
  const AttendanceQRView({super.key});

  @override
  State<AttendanceQRView> createState() => _AttendanceQRViewState();
}

class _AttendanceQRViewState extends State<AttendanceQRView> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceCubit>().loadAttendanceCode();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<AttendanceCubit, AttendanceState>(
        listener: (context, state) {
          if (state.error != null) {
            SnackBarHelper.error(context, state.error!);
          }
          if (state.success != null) {
            SnackBarHelper.success(context, state.success!);
          }
        },

        child: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'QR Code لتحضير المعلمين',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                actions: [
                  // IconButton(
                  //   icon: const Icon(Icons.refresh),
                  //   onPressed: () {
                  //     context.read<AttendanceCubit>().loadAttendanceCode();
                  //   },
                  //   tooltip: 'تحديث الكود',
                  // ),
                  // IconButton(
                  //   icon: const Icon(Icons.print),
                  //   onPressed: () {
                  //     // _generatePdf(state);
                  //   },
                  //   tooltip: 'طباعة الكود',
                  // ),
                ],
              ),
              body: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildBody(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AttendanceState state) {
    final code = state.attendanceQR?.code ?? '';
    _controller.text = state.attendanceQR?.code ?? '';
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // _generatePdf(state);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(Icons.print),
                    label: const Text(
                      'طباعة كود QR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            code.isNotEmpty
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 3,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data:
                                '${state.attendanceQR!.code}:${state.schoolId}',
                            version: QrVersions.auto,
                            size: 250.0,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'اسم المدرسة: ${state.schoolName}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Text('لا يوجد QR حاليا قم بانشاءه'),

            const SizedBox(height: 20),

            Text(
              'آخر تحديث: ${_formatDate(state.attendanceQR?.date)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '🔄 تغيير كود الحضور',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: state.isLoadingQ
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: () {
                            context.read<AttendanceCubit>().saveAttendanceCode(
                              _controller.text,
                            );
                            context.read<AttendanceCubit>().clearMessage();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'حفظ الكود الجديد',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AttendanceCubit>().generateNewCode();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      ' انشاء كود عشوائي',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? isoDate) {
    try {
      final parsedDate = isoDate;
      if (parsedDate == null) {
        return '';
      }

      return '${parsedDate.year}/${parsedDate.month}/${parsedDate.day}'
          ' - ${parsedDate.hour}:${parsedDate.minute}';
    } catch (e) {
      return 'تاريخ غير معروف';
    }
  }
}
