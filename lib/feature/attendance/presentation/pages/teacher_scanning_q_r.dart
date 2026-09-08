import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/constants/app_font.dart';
import 'package:albra3m4/core/utils/snake_bar_helper.dart';
import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TeacherScanningQR extends StatefulWidget {
  final UserEntity user;

  const TeacherScanningQR({super.key, required this.user});

  @override
  State<TeacherScanningQR> createState() => _AttendanceScannerPageState();
}

class _AttendanceScannerPageState extends State<TeacherScanningQR> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void initState() {
    super.initState();

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

    await context.read<AttendanceCubit>().handleScan(widget.user, scannedCode);
  }

  // =========================================================
  // Build
  // =========================================================

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
            backgroundColor: AppColors.background,

            appBar: _buildAppBar(),

            body: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: state.attendanceDone
                      ? _buildSuccessView(state)
                      : _buildScannerView(),
                ),

                if (state.isLoading) _buildLoadingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // App Bar
  // =========================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,

      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 17,
            color: AppColors.primaryDark,
          ),
        ),
      ),

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 20,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            'تسجيل الحضور',
            style: TextStyle(
              color: AppColors.ink,
              fontFamily: AppFont.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Scanner
  // =========================================================

  Widget _buildScannerView() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: Column(
                children: [
                  // =====================================================
                  // Header
                  // =====================================================
                  _buildScannerHeader(),

                  const SizedBox(height: 24),

                  // =====================================================
                  // Scanner
                  // =====================================================
                  _buildScannerCard(),

                  const SizedBox(height: 20),

                  // =====================================================
                  // Hint
                  // =====================================================
                  _buildScannerHint(),

                  const SizedBox(height: 20),

                  // =====================================================
                  // Bottom Info
                  // =====================================================
                  _buildInfoCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // Scanner Header
  // =========================================================

  Widget _buildScannerHeader() {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.qr_code_2_rounded,
            size: 31,
            color: AppColors.primaryDark,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'امسح رمز QR',
          style: TextStyle(
            fontFamily: AppFont.primary,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),

        const SizedBox(height: 7),

        Text(
          'وجّه الكاميرا نحو رمز الحضور لتسجيل حضورك',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppFont.primary,
            fontSize: 14,
            height: 1.6,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // Scanner Card
  // =========================================================

  Widget _buildScannerCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 390),
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),

      child: AspectRatio(
        aspectRatio: 1,

        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),

          child: Stack(
            fit: StackFit.expand,
            children: [
              // ===================================================
              // Camera
              // ===================================================
              MobileScanner(controller: _controller, onDetect: _handleScan),

              // ===================================================
              // Dark Overlay
              // ===================================================
              IgnorePointer(
                child: CustomPaint(painter: _ScannerOverlayPainter()),
              ),

              // ===================================================
              // Scanner Corners
              // ===================================================
              IgnorePointer(
                child: Center(
                  child: SizedBox(
                    width: 235,
                    height: 235,
                    child: CustomPaint(painter: _ScannerCornersPainter()),
                  ),
                ),
              ),

              // ===================================================
              // Center Hint
              // ===================================================
              Positioned(
                bottom: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ضع الرمز داخل الإطار',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Scanner Hint
  // =========================================================

  Widget _buildScannerHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.apricot.withOpacity(.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lightbulb_outline_rounded,
            size: 17,
            color: AppColors.apricot,
          ),
        ),

        const SizedBox(width: 9),

        Flexible(
          child: Text(
            'تأكد من وضوح الرمز وإضاءة المكان بشكل جيد',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFont.primary,
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // Info Card
  // =========================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(.18)),
      ),

      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              'سيتم تسجيل حضورك تلقائيًا عند قراءة رمز QR الصحيح.',
              style: TextStyle(
                fontFamily: AppFont.primary,
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Loading
  // =========================================================

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(.25),

        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.12),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),

            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primaryDark,
                  ),
                ),

                SizedBox(height: 14),

                Text(
                  'جاري تسجيل الحضور...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Success
  // =========================================================

  Widget _buildSuccessView(AttendanceState state) {
    final bool isLate = state.attendanceTStatus == "متأخر";

    final Color statusColor = isLate ? AppColors.warning : AppColors.success;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===================================================
              // Success Icon
              // ===================================================
              Container(
                width: 110,
                height: 110,

                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.10),
                  shape: BoxShape.circle,
                ),

                child: Container(
                  margin: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.16),
                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    isLate ? Icons.access_time_rounded : Icons.check_rounded,
                    size: 48,
                    color: statusColor,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ===================================================
              // Title
              // ===================================================
              Text(
                isLate ? 'تم تسجيل حضورك' : 'تم تسجيل حضورك بنجاح',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontFamily: AppFont.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),

              const SizedBox(height: 10),

              // ===================================================
              // Status
              // ===================================================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),

                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.10),
                  borderRadius: BorderRadius.circular(30),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLate ? Icons.schedule_rounded : Icons.verified_rounded,
                      size: 17,
                      color: statusColor,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      isLate ? 'تم التسجيل متأخرًا' : 'تم التسجيل في الوقت',
                      style: TextStyle(
                        fontFamily: AppFont.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===================================================
              // Teacher Card
              // ===================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,

                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),

                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.primaryDark,
                      ),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المعلم',
                            style: TextStyle(
                              fontFamily: AppFont.primary,
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            state.teacherName,
                            style: TextStyle(
                              fontFamily: AppFont.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'يمكنك الآن متابعة استخدام التطبيق',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFont.primary,
                  fontSize: 13,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Dispose
  // =========================================================

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// =============================================================
// Scanner Overlay Painter
// =============================================================

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    const double scanSize = 235;

    final Rect scanRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: scanSize,
      height: scanSize,
    );

    final Paint overlayPaint = Paint()..color = Colors.black.withOpacity(.38);

    final Path overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(18)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// =============================================================
// Scanner Corners Painter
// =============================================================

class _ScannerCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 32;

    final double left = 0;
    final double right = size.width;
    final double top = 0;
    final double bottom = size.height;

    // Top Left
    canvas.drawLine(Offset(left, cornerLength), Offset(left, 0), paint);

    canvas.drawLine(Offset(left, 0), Offset(cornerLength, top), paint);

    // Top Right
    canvas.drawLine(
      Offset(right - cornerLength, top),
      Offset(right, top),
      paint,
    );

    canvas.drawLine(Offset(right, top), Offset(right, cornerLength), paint);

    // Bottom Left
    canvas.drawLine(
      Offset(left, bottom - cornerLength),
      Offset(left, bottom),
      paint,
    );

    canvas.drawLine(Offset(left, bottom), Offset(cornerLength, bottom), paint);

    // Bottom Right
    canvas.drawLine(
      Offset(right - cornerLength, bottom),
      Offset(right, bottom),
      paint,
    );

    canvas.drawLine(
      Offset(right, bottom - cornerLength),
      Offset(right, bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
