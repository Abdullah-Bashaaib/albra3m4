import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/attendance/presentation/widgets/qr_white_card.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// بطاقة عرض كود QR مع اسم المدرسة وتاريخ آخر تحديث
class QrCodeCard extends StatelessWidget {
  final AttendanceState state;
  final String formattedDate;

  const QrCodeCard({
    super.key,
    required this.state,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final code = state.attendanceQR?.code ?? '';

    return QrWhiteCard(
      child: Column(
        children: [
          if (code.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: QrImageView(
                data: '${state.attendanceQR!.code}:${state.schoolId}',
                version: QrVersions.auto,
                size: 220,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF0277BD),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF0277BD),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 16,
                  color: Color(0xFF4FC3F7),
                ),
                const SizedBox(width: 6),
                Text(
                  state.schoolName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Color(0xFF9E9E9E),
                ),
                const SizedBox(width: 4),
                Text(
                  'آخر تحديث: $formattedDate',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ] else ...[
            const Icon(
              Icons.qr_code_2_rounded,
              size: 80,
              color: Color(0xFFB0BEC5),
            ),
            const SizedBox(height: 12),
            const Text(
              'لا يوجد QR حاليًا\nقم بإنشائه من الأسفل',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9E9E9E),
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
