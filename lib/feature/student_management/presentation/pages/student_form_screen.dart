import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/utils/widgets/custom_text_form_field.dart';
import 'package:albra3m4/feature/student_management/domain/entities/student_entity.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class StudentFormScreen extends StatefulWidget {
  final StudentEntity? existing;
  const StudentFormScreen({super.key, this.existing});
  bool get isEdit => existing != null;

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _notesCtrl;

  DateTime? _birthDate;
  late StudentGender _gender;
  late KindergartenClass _classroom;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameCtrl = TextEditingController(text: s?.fullName ?? '');
    _phoneCtrl = TextEditingController(text: s?.guardianPhone ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _birthDate = s?.birthDate;
    _gender = s?.gender ?? StudentGender.male;
    _classroom = s?.classroom ?? KindergartenClass.kg1;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2020),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار تاريخ الميلاد'),
          backgroundColor: AppColors.dangerFg,
        ),
      );
      return;
    }

    final student = StudentEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      fullName: _nameCtrl.text.trim(),
      gender: _gender,
      birthDate: _birthDate!,
      classroom: _classroom,
      guardianPhone: _phoneCtrl.text.trim().isEmpty
          ? null
          : _phoneCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      grades: widget.existing?.grades ?? defaultSubjectGrades(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, student);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.apricot,
          foregroundColor: Colors.white,
          title: Text(
            widget.isEdit ? 'تعديل بيانات الطالب' : 'إضافة طالب جديد',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
            children: [
              _SectionTitle('البيانات الأساسية'),
              const SizedBox(height: 14),
              CustomTextFormField(
                controller: _nameCtrl,
                label: 'اسم الطالب',
                hintText: 'مثال: يوسف أحمد ناصر',
                icon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 16),

              // ─── الجنس ───
              _FieldLabel('الجنس'),
              const SizedBox(height: 8),
              Row(
                children: StudentGender.values.map((g) {
                  final sel = _gender == g;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: g == StudentGender.values.last ? 0 : 8,
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _gender = g),
                        icon: Icon(
                          g == StudentGender.male
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          size: 18,
                        ),
                        label: Text(
                          g.arabicLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: sel
                                ? AppColors.primaryDark
                                : AppColors.muted,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: sel
                              ? AppColors.primaryLight
                              : AppColors.cream,
                          side: BorderSide(
                            color: sel ? AppColors.primary : AppColors.line,
                            width: 1.4,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // ─── تاريخ الميلاد ───
              _FieldLabel('تاريخ الميلاد'),
              const SizedBox(height: 8),
              _DatePickerTile(
                value: _birthDate,
                hint: 'اختر تاريخ الميلاد',
                onTap: _pickBirthDate,
              ),
              const SizedBox(height: 24),

              _SectionTitle('الصف الدراسي'),
              const SizedBox(height: 14),
              _ClassroomSelector(
                selected: _classroom,
                onChanged: (c) => setState(() => _classroom = c),
              ),
              const SizedBox(height: 24),

              _SectionTitle('بيانات التواصل'),
              const SizedBox(height: 14),
              CustomTextFormField(
                controller: _phoneCtrl,
                label: 'هاتف ولي الأمر',
                hintText: '777000000',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: _notesCtrl,
                label: 'ملاحظات',
                hintText: 'أي ملاحظات خاصة بالطالب...',
                icon: Icons.notes_rounded,
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            decoration: const BoxDecoration(
              color: AppColors.cream,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(widget.isEdit ? 'حفظ التعديلات' : 'إضافة الطالب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.apricot,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Classroom selector ──────────────────────────────────────────────────────

class _ClassroomSelector extends StatelessWidget {
  final KindergartenClass selected;
  final ValueChanged<KindergartenClass> onChanged;
  const _ClassroomSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: KindergartenClass.values.map((cls) {
        final sel = selected == cls;
        final color = _color(cls);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(cls),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: sel ? color.withValues(alpha: 0.08) : AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? color : AppColors.line,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icon(cls), color: color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cls.shortLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: sel ? color : AppColors.ink,
                          ),
                        ),
                        Text(
                          _subtitle(cls),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sel)
                    Icon(Icons.check_circle_rounded, color: color, size: 22),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _color(KindergartenClass cls) {
    switch (cls) {
      case KindergartenClass.kg1:
        return const Color(0xFF26A69A);
      case KindergartenClass.kg2:
        return AppColors.primary;
      case KindergartenClass.kg3:
        return const Color(0xFF7E57C2);
    }
  }

  IconData _icon(KindergartenClass cls) {
    switch (cls) {
      case KindergartenClass.kg1:
        return Icons.looks_one_rounded;
      case KindergartenClass.kg2:
        return Icons.looks_two_rounded;
      case KindergartenClass.kg3:
        return Icons.looks_3_rounded;
    }
  }

  String _subtitle(KindergartenClass cls) {
    switch (cls) {
      case KindergartenClass.kg1:
        return 'المرحلة التمهيدية';
      case KindergartenClass.kg2:
        return 'الصف الأول';
      case KindergartenClass.kg3:
        return 'الصف الثاني';
    }
  }
}

// ─── Date picker tile ────────────────────────────────────────────────────────

class _DatePickerTile extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final VoidCallback onTap;
  const _DatePickerTile({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: value != null ? AppColors.apricot : AppColors.primary,
            width: value != null ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: value != null ? AppColors.apricot : AppColors.muted,
            ),
            const SizedBox(width: 10),
            Text(
              value == null ? hint : _fmt(value!),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: value == null ? AppColors.muted : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// ─── _SectionTitle ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

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
          text,
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: AppColors.muted,
      ),
    );
  }
}
