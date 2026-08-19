/// دوال التحقق (Validators) لحقول المصادقة — تسجيل الدخول والتسجيل.
/// القواعد مطابقة لجدول Validation Rules في UC-001 من وثيقة حالات الاستخدام.
class AuthValidators {
  const AuthValidators._();

  // نمط بريد إلكتروني قياسي: user@domain.com
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  // اسم لا يحتوي أرقاماً (يدعم الحروف العربية والإنجليزية والمسافات)
  static final RegExp _nameRegex = RegExp(r'^[\p{L}\s]+$', unicode: true);

  static final RegExp _phoneRegex = RegExp(r'^[0-9+\s-]{7,15}$');

  /// التحقق من البريد الإلكتروني.
  static String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';

    if (trimmed.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }

    return null;
  }

  /// التحقق من كلمة المرور عند التسجيل (UC-001 — E2). 8 أحرف على الأقل.
  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }

    if (password.length < 8) {
      return 'يجب أن تحتوي على 8 أحرف على الأقل';
    }

    return null;
  }

  /// التحقق من كلمة المرور عند تسجيل الدخول فقط — بدون فرض طول معيّن.
  static String? validateLoginPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }

    return null;
  }

  /// التحقق من تطابق كلمة المرور وتأكيدها (UC-001 — E3).
  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    if ((value ?? '').isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }

    if (value != originalPassword) {
      return 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }

  /// التحقق من الاسم الكامل — 3 أحرف على الأقل ولا يحتوي أرقاماً.
  static String? validateFullName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'يرجى إدخال الاسم الكامل';
    }

    if (name.length < 3) {
      return 'الاسم يجب ألا يقل عن 3 أحرف';
    }

    if (!_nameRegex.hasMatch(name)) {
      return 'الاسم يجب ألا يحتوي على أرقام أو رموز';
    }

    return null;
  }

  /// التحقق من رقم الهاتف — اختياري (UC-001، شاشة التسجيل العادي).
  static String? validatePhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return null; // حقل اختياري
    }

    if (!_phoneRegex.hasMatch(phone)) {
      return 'رقم الهاتف غير صحيح';
    }

    return null;
  }

  /// التحقق من رقم الهاتف — إلزامي (شاشة إكمال الملف الشخصي بعد Google).
  static String? validateRequiredPhone(String? value) {
    final phone = value?.trim() ?? '';

    if (phone.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }

    if (!_phoneRegex.hasMatch(phone)) {
      return 'رقم الهاتف غير صحيح';
    }

    return null;
  }

  /// التحقق من نوع المستخدم (Dropdown) — يجب اختيار قيمة (UC-001).
  static String? validateUserType(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى اختيار نوع المستخدم';
    }

    return null;
  }

  /// التحقق من رمز OTP المكوّن من 6 أرقام (UC-002).
  static String? validateOtp(String? value) {
    final otp = value?.trim() ?? '';

    if (otp.isEmpty) {
      return 'يرجى إدخال رمز التحقق';
    }

    if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      return 'الرمز يجب أن يتكوّن من 6 أرقام';
    }

    return null;
  }
}