import 'package:albra3m4/core/utils/validators/validators.dart';
import 'package:albra3m4/core/utils/widgets/custom_text_form_field.dart';
import 'package:albra3m4/feature/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:albra3m4/feature/attendance/presentation/widgets/qr_gradient_button.dart';
import 'package:albra3m4/feature/attendance/presentation/widgets/qr_white_card.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// بطاقة تغيير كود الحضور مع زر الحفظ وزر الكود العشوائي
class QrCodeEditorCard extends StatefulWidget {
  final UserEntity user;
  final TextEditingController codeController;
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;

  final bool isLoadingQ;

  const QrCodeEditorCard({
    super.key,
    required this.codeController,
    required this.startTimeController,
    required this.endTimeController,
    required this.isLoadingQ,
    required this.user,
  });

  @override
  State<QrCodeEditorCard> createState() => _QrCodeEditorCardState();
}

class _QrCodeEditorCardState extends State<QrCodeEditorCard> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return QrWhiteCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit_rounded, color: Color(0xFF0277BD), size: 20),
                SizedBox(width: 8),
                Text(
                  'تغيير كود الحضور',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.codeController,
              decoration: InputDecoration(
                hintText: 'أدخل الكود الجديد...',
                filled: true,
                fillColor: const Color(0xFFE1F5FE),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.key_rounded,
                  color: Color(0xFF4FC3F7),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  color: Color(0xFF0277BD),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'وقت الحضور',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0277BD),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    label: 'وقت الحضور',
                    controller: widget.startTimeController,
                    validator: Validators.global,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextFormField(
                    label: 'وقت الإنصراف',
                    controller: widget.endTimeController,
                    validator: Validators.global,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: widget.isLoadingQ
                      ? const Center(child: CircularProgressIndicator())
                      : QrGradientButton(
                          label: 'حفظ الكود',
                          icon: Icons.save_rounded,
                          gradientColors: const [
                            Color(0xFF0277BD),
                            Color(0xFF4FC3F7),
                          ],
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context
                                  .read<AttendanceCubit>()
                                  .saveAttendanceCode(
                                    widget.user,
                                    widget.codeController.text,
                                    int.parse(widget.startTimeController.text),
                                    int.parse(widget.endTimeController.text),
                                  );
                              context.read<AttendanceCubit>().clearMessage();
                            }
                          },
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QrGradientButton(
                    label: 'كود عشوائي',
                    icon: Icons.shuffle_rounded,
                    gradientColors: const [
                      Color(0xFFE65100),
                      Color(0xFFFFB74D),
                    ],
                    onPressed: () {
                      context.read<AttendanceCubit>().generateNewCode(
                        widget.user,
                      );
                    },
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
