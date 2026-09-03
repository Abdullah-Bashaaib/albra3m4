import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:albra3m4/core/utils/snake_bar_helper.dart';
import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TeacherScanningQR extends StatefulWidget {
  const TeacherScanningQR({super.key});

  @override
  State<TeacherScanningQR> createState() => _AttendanceScannerPageState();
}

class _AttendanceScannerPageState extends State<TeacherScanningQR> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void initState() {
    super.initState();

    // تحميل كود الحضور والتحقق من حالة تحضير المعلم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceCubit>().initializeScanning();
    });
  }

  // =========================================================
  // معالجة قراءة QR
  // =========================================================

  Future<void> _handleScan(BarcodeCapture barcodeCapture) async {
    final barcode = barcodeCapture.barcodes.firstOrNull;

    final scannedCode = barcode?.rawValue;

    if (scannedCode == null || scannedCode.isEmpty) {
      return;
    }

    await _controller.stop();

    if (!mounted) return;

    await context.read<AttendanceCubit>().handleScan(scannedCode);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceCubit, AttendanceState>(
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
              backgroundColor: AppColors.primary,
              title: Text(
                'التحضير',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: AppFont.primary,
                ),
              ),
              elevation: 0,
            ),
            body: Stack(
              children: [
                state.attendanceDone
                    ? _buildSuccessView(state)
                    : _buildScannerView(),

                if (state.isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // شاشة النجاح
  // =========================================================

  Widget _buildSuccessView(AttendanceState state) {
    final bool isLate = state.attendanceTStatus == "متأخر";

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLate ? Icons.access_time : Icons.check_circle_outline,
              size: 100,
              color: isLate ? Colors.orange : Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            Text(
              isLate
                  ? "تم تسجيل حضورك بنجاح (متأخر) ⏰"
                  : "تم تسجيل حضورك بنجاح ✅",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isLate ? Colors.orange : Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              state.teacherName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            // ElevatedButton.icon(
            //   onPressed: () => Navigator.of(context).pop(),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.blueAccent,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 30,
            //       vertical: 14,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(15),
            //     ),
            //   ),
            //   icon: const Icon(Icons.arrow_back),
            //   label: const Text("رجوع", style: TextStyle(fontSize: 18)),
            // ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // شاشة QR
  // =========================================================

  Widget _buildScannerView() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),
        const Text(
          '📷 امسح رمز QR لتسجيل الحضور ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: MobileScanner(
                controller: _controller,
                onDetect: _handleScan,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
