import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/utils/snake_bar_helper.dart';
import 'package:albra3m4/core/utils/widgets/app_background.dart';
import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/attendance/presentation/widgets/qr_code_card.dart';
import 'package:albra3m4/feature/attendance/presentation/widgets/qr_code_editor_card.dart';
import 'package:albra3m4/feature/attendance/presentation/widgets/qr_decorative_circle.dart';
import 'package:albra3m4/feature/attendance/presentation/widgets/qr_gradient_button.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_font.dart';

class AttendanceQRView extends StatefulWidget {
  final UserEntity user;
  const AttendanceQRView({super.key, required this.user});

  @override
  State<AttendanceQRView> createState() => _AttendanceQRViewState();
}

class _AttendanceQRViewState extends State<AttendanceQRView> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceCubit>().loadAttendanceCode();
    });
  }

  // ── منطق الطباعة ─────────────────────────────────────────────────

  Future<void> _printQR(AttendanceState state) async {
    if (state.attendanceQR == null) return;
    final qrData = '${state.attendanceQR!.code}:${state.schoolId}';

    // تحميل خطوط Somar من الأصول
    final fontBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/SomarRounded-Bold.ttf'),
    );
    final fontRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/SomarRounded-Regular.ttf'),
    );
    final fontLight = pw.Font.ttf(
      await rootBundle.load('assets/fonts/SomarRounded-Light.ttf'),
    );

    final qrImage = await _buildQrPdfImage(qrData, 400);
    final date = _formatDate(state.attendanceQR?.date);

    // ألوان المشروع بصيغة PDF
    const primaryDark = PdfColor(0.016, 0.467, 0.741); // 0277BD
    const primaryLight = PdfColor(0.310, 0.765, 0.969); // 4FC3F7
    const bgBlue = PdfColor(0.882, 0.961, 0.996); // E1F5FE

    await Printing.layoutPdf(
      name: 'QR_Attendance',
      format: PdfPageFormat.a4,
      onLayout: (format) async {
        final doc = pw.Document();

        doc.addPage(
          pw.Page(
            pageFormat: format,
            margin: pw.EdgeInsets.zero,
            build: (_) => pw.Column(
              children: [
                // ── هيدر متدرج ───────────────────────────────────
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 40,
                  ),
                  decoration: const pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [primaryDark, primaryLight],
                      begin: pw.Alignment.topLeft,
                      end: pw.Alignment.bottomRight,
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'كود حضور المعلمات',
                        textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 30,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        state.schoolName,
                        textDirection: pw.TextDirection.rtl,
                        style: pw.TextStyle(
                          font: fontLight,
                          fontSize: 16,
                          color: const PdfColor(1, 1, 1, 0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── محتوى ─────────────────────────────────────────
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 30,
                    ),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        // إطار QR
                        pw.Container(
                          padding: const pw.EdgeInsets.all(20),
                          decoration: pw.BoxDecoration(
                            color: bgBlue,
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(20),
                            ),
                            border: pw.Border.all(color: primaryDark, width: 2),
                          ),
                          child: pw.Image(qrImage, width: 280, height: 280),
                        ),

                        pw.SizedBox(height: 24),

                        // شريحة الكود
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          decoration: pw.BoxDecoration(
                            color: bgBlue,
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(14),
                            ),
                            border: pw.Border.all(
                              color: primaryLight,
                              width: 1.5,
                            ),
                          ),
                          child: pw.Text(
                            state.attendanceQR!.code,
                            textDirection: pw.TextDirection.ltr,
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 24,
                              color: primaryDark,
                              letterSpacing: 4,
                            ),
                          ),
                        ),

                        pw.SizedBox(height: 12),

                        if (date.isNotEmpty)
                          pw.Text(
                            'آخر تحديث: $date',
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 12,
                              color: PdfColors.grey600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── فوتر ──────────────────────────────────────────
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 40,
                  ),
                  color: bgBlue,
                  child: pw.Text(
                    'يُرجى مسح هذا الكود عند الحضور — روضة البراعم',
                    textDirection: pw.TextDirection.rtl,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: fontLight,
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        return doc.save();
      },
    );
  }

  Future<pw.ImageProvider> _buildQrPdfImage(String data, double size) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF0277BD),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF0277BD),
      ),
    );
    final imageBytes = await painter.toImageData(size);
    return pw.MemoryImage(imageBytes!.buffer.asUint8List());
  }

  // ── البناء ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state.error != null) SnackBarHelper.error(context, state.error!);
        if (state.success != null) {
          SnackBarHelper.success(context, state.success!);
        }
      },
      child: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) => Scaffold(
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AttendanceState state) {
    _codeController.text = state.attendanceQR?.code ?? '';
    _startTimeController.text = state.attendanceQR?.startTime.toString() ?? '';
    _endTimeController.text = state.attendanceQR?.endTime.toString() ?? '';
    return AppBackground(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                QrCodeCard(
                  state: state,
                  formattedDate: _formatDate(state.attendanceQR?.date),
                ),
                const SizedBox(height: 20),
                QrCodeEditorCard(
                  codeController: _codeController,
                  startTimeController: _startTimeController,
                  endTimeController: _endTimeController,
                  isLoadingQ: state.isLoadingQ,
                  user: widget.user,
                ),
                const SizedBox(height: 16),
                QrGradientButton(
                  label: 'طباعة كود QR',
                  icon: Icons.print_rounded,
                  gradientColors: const [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  onPressed: () => _printQR(state),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF0277BD),
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
                child: QrDecorativeCircle(size: 160, opacity: 0.08),
              ),
              Positioned(
                bottom: -20,
                right: -20,
                child: QrDecorativeCircle(size: 120, opacity: 0.12),
              ),
            ],
          ),
        ),
        title: const Text(
          'كود QR الحضور',
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    try {
      return '${date.year}/${date.month}/${date.day} - ${date.hour}:${date.minute}';
    } catch (_) {
      return 'تاريخ غير معروف';
    }
  }
}
