import 'package:albra3m4/core/constants/app_font.dart';
import 'package:albra3m4/core/utils/validators/validators.dart';
import 'package:albra3m4/core/utils/widgets/custom_text_form_field.dart';
import 'package:albra3m4/feature/teachers_management/presentation/cubit/teacher_cubit.dart';
import 'package:flutter/material.dart';

import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/feature/auth/domain/entities/user.dart';
import 'package:albra3m4/feature/teachers_management/domain/entities/teacher_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class TeacherFormScreen extends StatefulWidget {
  final UserEntity? existing;

  const TeacherFormScreen({super.key, this.existing});

  bool get isEdit => existing != null;

  @override
  State<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends State<TeacherFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;

  late final TextEditingController _mobileCtrl;

  late final TextEditingController _birthPlaceCtrl;

  late final TextEditingController _qualificationCtrl;

  late final TextEditingController _specializationCtrl;

  late final TextEditingController _childrenCtrl;

  late final TextEditingController _homePhoneCtrl;

  DateTime? _birthDate;

  DateTime? _qualificationDate;

  late SocialStatus _selectedSocialStatus;

  @override
  void initState() {
    super.initState();

    final user = widget.existing;
    final teacher = user?.tDetails;

    _nameCtrl = TextEditingController(text: user?.fullName ?? '');

    _mobileCtrl = TextEditingController(text: user?.phone ?? '');

    _birthPlaceCtrl = TextEditingController(text: teacher?.birthPlace ?? '');

    _qualificationCtrl = TextEditingController(
      text: teacher?.academicQualification ?? '',
    );

    _specializationCtrl = TextEditingController(
      text: teacher?.specialization ?? '',
    );

    _childrenCtrl = TextEditingController(
      text: teacher?.childrenCount.toString() ?? '0',
    );

    _homePhoneCtrl = TextEditingController(
      text: teacher?.homePhone.toString() ?? '',
    );

    _birthDate = teacher?.birthDate;

    _qualificationDate = teacher?.qualificationDate;

    _selectedSocialStatus = teacher?.socialStatus ?? SocialStatus.single;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _birthPlaceCtrl.dispose();
    _qualificationCtrl.dispose();
    _specializationCtrl.dispose();
    _childrenCtrl.dispose();
    _homePhoneCtrl.dispose();

    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      // locale:
      //     const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _pickQualificationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _qualificationDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      // locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        _qualificationDate = picked;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthDate == null) {
      _showError('يرجى اختيار تاريخ الميلاد');
      return;
    }

    if (_qualificationDate == null) {
      _showError('يرجى اختيار تاريخ المؤهل');
      return;
    }
    final Uuid uuid = Uuid();
    final newTId = uuid.v4();

    final userId = widget.existing?.uid;

    final teacherId = widget.existing?.tDetails?.id ?? newTId;

    final teacher = TeacherEntity(
      id: teacherId,
      userId: userId!,
      birthDate: _birthDate!,
      birthPlace: _birthPlaceCtrl.text.trim(),
      academicQualification: _qualificationCtrl.text.trim(),
      qualificationDate: _qualificationDate!,
      specialization: _specializationCtrl.text.trim(),
      socialStatus: _selectedSocialStatus,
      childrenCount: int.tryParse(_childrenCtrl.text.trim()) ?? 0,
      homePhone: _homePhoneCtrl.text.trim(),
    );
    final user = widget.existing?.copyWith(
      fullName: _nameCtrl.text.trim(),
      phone: _mobileCtrl.text.trim(),
      tDetails: teacher,
    );

    widget.isEdit
        ? context.read<TeacherCubit>().saveTeacher(user!)
        : context.read<TeacherCubit>().saveTeacher(user!);
    Navigator.pop(context, user);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.dangerFg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,

      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEdit ? 'تعديل بيانات المعلمة' : 'إضافة معلمة جديدة',
          ),
        ),

        body: Form(
          key: _formKey,

          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),

            children: [
              const _SectionTitle(title: 'البيانات الأساسية'),

              const SizedBox(height: 12),

              // _Label('الاسم الكامل'),
              CustomTextFormField(
                controller: _nameCtrl,

                hintText: 'مثال: منى عبدالله السالم',

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الاسم مطلوب';
                  }

                  return null;
                },
                label: 'الإسم الكامل',
              ),

              // CustomTextFormField(
              //   hintText: widget.existing?.email,
              //   enabled: false,
              //   keyboardType: TextInputType.emailAddress,
              //   validator: Validators.email,
              //   label: '',
              // ),
              const SizedBox(height: 16),

              // _Label('رقم الجوال'),
              CustomTextFormField(
                controller: _mobileCtrl,

                keyboardType: TextInputType.phone,
                hintText: '777000000',

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'رقم الجوال مطلوب';
                  }

                  if (int.tryParse(value.trim()) == null) {
                    return 'صيغة الرقم غير صحيحة';
                  }

                  return null;
                },
                label: 'رقم الجوال',
              ),

              const SizedBox(height: 20),

              const _SectionTitle(title: 'بيانات الميلاد'),

              const SizedBox(height: 12),

              _Label('تاريخ الميلاد'),

              _DateField(
                value: _birthDate,
                hint: 'اختاري تاريخ الميلاد',
                onTap: _pickBirthDate,
              ),

              const SizedBox(height: 16),

              // _Label('مكان الميلاد'),
              CustomTextFormField(
                controller: _birthPlaceCtrl,

                hintText: 'مثال: سيئون',

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'مكان الميلاد مطلوب';
                  }

                  return null;
                },
                label: 'مكان الميلاد',
              ),

              const SizedBox(height: 16),

              _Label('الحالة الاجتماعية'),

              _SocialStatusSelector(
                selected: _selectedSocialStatus,

                onChanged: (value) {
                  setState(() {
                    _selectedSocialStatus = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // _Label('عدد الأبناء'),
              CustomTextFormField(
                controller: _childrenCtrl,

                keyboardType: TextInputType.number,

                hintText: '0',
                label: 'عدد الأبناء',
              ),

              const SizedBox(height: 20),

              const _SectionTitle(title: 'البيانات المهنية'),

              const SizedBox(height: 12),

              // _Label('المؤهل العلمي'),
              CustomTextFormField(
                controller: _qualificationCtrl,

                hintText: 'مثال: بكالوريوس',
                label: 'المؤهل العلمي',
              ),

              const SizedBox(height: 16),

              // _Label('التخصص'),
              CustomTextFormField(
                controller: _specializationCtrl,

                hintText: 'مثال: لغة عربية',
                label: 'التخصص',
              ),

              const SizedBox(height: 16),

              _Label('تاريخ الحصول على المؤهل'),

              _DateField(
                value: _qualificationDate,
                hint: 'اختاري التاريخ',
                onTap: _pickQualificationDate,
              ),

              const SizedBox(height: 20),

              const _SectionTitle(title: 'بيانات التواصل'),

              const SizedBox(height: 12),

              // _Label('هاتف المنزل'),
              CustomTextFormField(
                controller: _homePhoneCtrl,

                keyboardType: TextInputType.phone,

                hintText: '050000000',
                label: 'هاتف المنزل',
              ),

              const SizedBox(height: 20),

              // const _SectionTitle(title: 'إعدادات الحساب'),

              // SwitchListTile(
              //   contentPadding: EdgeInsets.zero,

              //   title: const Text(
              //     'الحساب نشط',
              //     style: TextStyle(
              //       fontSize: 13.5,
              //       fontWeight: FontWeight.w700,
              //       color: AppColors.ink,
              //     ),
              //   ),

              //   value: _isActive,

              //   onChanged: (value) {
              //     setState(() {
              //       _isActive = value;
              //     });
              //   },
              // ),

              // SwitchListTile(
              //   contentPadding: EdgeInsets.zero,

              //   title: const Text(
              //     'تم التحقق من الحساب',
              //     style: TextStyle(
              //       fontSize: 13.5,
              //       fontWeight: FontWeight.w700,
              //       color: AppColors.ink,
              //     ),
              //   ),

              //   value: _isVerified,

              //   onChanged: (value) {
              //     setState(() {
              //       _isVerified = value;
              //     });
              //   },
              // ),
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

              icon: const Icon(Icons.check),

              label: Text(widget.isEdit ? 'حفظ التعديلات' : 'إضافة المعلمة'),

              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? value;
  final String hint;
  final VoidCallback onTap;

  const _DateField({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: InputDecorator(
        decoration: const InputDecoration(
          floatingLabelStyle: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: AppFont.primary,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),

        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.muted,
            ),

            const SizedBox(width: 8),

            Text(
              value == null ? hint : _formatDate(value!),

              style: TextStyle(
                color: value == null ? AppColors.muted : AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class _SocialStatusSelector extends StatelessWidget {
  final SocialStatus selected;
  final ValueChanged<SocialStatus> onChanged;

  const _SocialStatusSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: SocialStatus.values.map((status) {
        final selected = this.selected == status;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: status == SocialStatus.values.last ? 0 : 6,
            ),

            child: OutlinedButton(
              onPressed: () => onChanged(status),

              style: OutlinedButton.styleFrom(
                backgroundColor: selected
                    ? AppColors.primaryLight
                    : const Color(0xFFFDFCF8),

                side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.line,
                  width: 1.4,
                ),

                padding: const EdgeInsets.symmetric(vertical: 10),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: Text(
                _label(status),

                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.primaryDark : AppColors.muted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(SocialStatus status) {
    switch (status) {
      case SocialStatus.single:
        return 'عزباء';
      case SocialStatus.married:
        return 'متزوجة';
      case SocialStatus.divorced:
        return 'مطلقة';
      case SocialStatus.widowed:
        return 'أرملة';
    }
  }
}
