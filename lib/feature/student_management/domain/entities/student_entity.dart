import 'package:equatable/equatable.dart';

/// الصفوف الدراسية في الروضة
enum KindergartenClass {
  kg1,
  kg2,
  kg3;

  String get arabicLabel {
    switch (this) {
      case KindergartenClass.kg1:
        return 'KG1 — التمهيدي';
      case KindergartenClass.kg2:
        return 'KG2 — الأول';
      case KindergartenClass.kg3:
        return 'KG3 — الثاني';
    }
  }

  String get shortLabel {
    switch (this) {
      case KindergartenClass.kg1:
        return 'KG1';
      case KindergartenClass.kg2:
        return 'KG2';
      case KindergartenClass.kg3:
        return 'KG3';
    }
  }

  /// الصف التالي (للترقية)
  KindergartenClass? get next {
    switch (this) {
      case KindergartenClass.kg1:
        return KindergartenClass.kg2;
      case KindergartenClass.kg2:
        return KindergartenClass.kg3;
      case KindergartenClass.kg3:
        return null; // تخرج
    }
  }
}

/// الجنس
enum StudentGender {
  male,
  female;

  String get arabicLabel => this == StudentGender.male ? 'ذكر' : 'أنثى';
}

/// الفصول الدراسية
enum Semester {
  first,
  second;

  String get arabicLabel =>
      this == Semester.first ? 'الفصل الأول' : 'الفصل الثاني';
}

// ─── درجة الطالب في عنصر تقييم واحد ───────────────────────────────────────

class GradeItem extends Equatable {
  /// اسم عنصر التقييم (مثل: اختبار الشهر الأول)
  final String name;

  /// الدرجة التي حصل عليها الطالب (null = لم تُدخَل بعد)
  final double? score;

  /// الدرجة الكاملة
  final double maxScore;

  const GradeItem({required this.name, required this.maxScore, this.score});

  double get percentage => (score != null && maxScore > 0)
      ? (score! / maxScore).clamp(0.0, 1.0)
      : 0.0;

  GradeItem copyWith({String? name, double? score, double? maxScore}) {
    return GradeItem(
      name: name ?? this.name,
      maxScore: maxScore ?? this.maxScore,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
    'maxScore': maxScore,
  };

  factory GradeItem.fromJson(Map<String, dynamic> json) => GradeItem(
    name: json['name'] as String,
    maxScore: (json['maxScore'] as num).toDouble(),
    score: json['score'] != null ? (json['score'] as num).toDouble() : null,
  );

  @override
  List<Object?> get props => [name, score, maxScore];
}

// ─── درجات مادة دراسية في فصل واحد ─────────────────────────────────────────

class SubjectSemesterGrade extends Equatable {
  final Semester semester;

  /// عناصر التقييم الستة
  final List<GradeItem> items;

  const SubjectSemesterGrade({required this.semester, required this.items});

  double get totalScore =>
      items.fold(0, (sum, item) => sum + (item.score ?? 0));

  double get totalMaxScore => items.fold(0, (sum, item) => sum + item.maxScore);

  double get percentage =>
      totalMaxScore > 0 ? (totalScore / totalMaxScore).clamp(0.0, 1.0) : 0.0;

  SubjectSemesterGrade copyWith({Semester? semester, List<GradeItem>? items}) {
    return SubjectSemesterGrade(
      semester: semester ?? this.semester,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
    'semester': semester.index,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory SubjectSemesterGrade.fromJson(Map<String, dynamic> json) =>
      SubjectSemesterGrade(
        semester: Semester.values[json['semester'] as int],
        items: (json['items'] as List)
            .map((e) => GradeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [semester, items];
}

// ─── مادة دراسية بفصليها ────────────────────────────────────────────────────

class SubjectGrades extends Equatable {
  final String subjectId;
  final String subjectName;
  final SubjectSemesterGrade firstSemester;
  final SubjectSemesterGrade secondSemester;

  const SubjectGrades({
    required this.subjectId,
    required this.subjectName,
    required this.firstSemester,
    required this.secondSemester,
  });

  double get yearlyAverage =>
      (firstSemester.percentage + secondSemester.percentage) / 2;

  SubjectGrades copyWith({
    String? subjectId,
    String? subjectName,
    SubjectSemesterGrade? firstSemester,
    SubjectSemesterGrade? secondSemester,
  }) {
    return SubjectGrades(
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      firstSemester: firstSemester ?? this.firstSemester,
      secondSemester: secondSemester ?? this.secondSemester,
    );
  }

  Map<String, dynamic> toJson() => {
    'subjectId': subjectId,
    'subjectName': subjectName,
    'firstSemester': firstSemester.toJson(),
    'secondSemester': secondSemester.toJson(),
  };

  factory SubjectGrades.fromJson(Map<String, dynamic> json) => SubjectGrades(
    subjectId: json['subjectId'] as String,
    subjectName: json['subjectName'] as String,
    firstSemester: SubjectSemesterGrade.fromJson(
      json['firstSemester'] as Map<String, dynamic>,
    ),
    secondSemester: SubjectSemesterGrade.fromJson(
      json['secondSemester'] as Map<String, dynamic>,
    ),
  );

  @override
  List<Object?> get props => [
    subjectId,
    subjectName,
    firstSemester,
    secondSemester,
  ];
}

// ─── كيان الطالب الرئيسي ────────────────────────────────────────────────────

class StudentEntity extends Equatable {
  final String id;
  final String fullName;
  final StudentGender gender;
  final DateTime birthDate;
  final KindergartenClass classroom;
  final String? guardianPhone;
  final String? notes;

  /// الدرجات مرتبة حسب المادة الدراسية
  final List<SubjectGrades> grades;

  final DateTime createdAt;

  const StudentEntity({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.birthDate,
    required this.classroom,
    required this.createdAt,
    this.guardianPhone,
    this.notes,
    this.grades = const [],
  });

  /// متوسط الدرجات السنوية عبر جميع المواد
  double get overallAverage {
    if (grades.isEmpty) return 0.0;
    final sum = grades.fold(0.0, (s, g) => s + g.yearlyAverage);
    return sum / grades.length;
  }

  /// الحروف التلخيصية للأفاتار
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts.first.isNotEmpty ? parts.first[0] : '';
    return '${parts[0][0]}${parts[1][0]}';
  }

  StudentEntity copyWith({
    String? id,
    String? fullName,
    StudentGender? gender,
    DateTime? birthDate,
    KindergartenClass? classroom,
    String? guardianPhone,
    String? notes,
    List<SubjectGrades>? grades,
    DateTime? createdAt,
  }) {
    return StudentEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      classroom: classroom ?? this.classroom,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      notes: notes ?? this.notes,
      grades: grades ?? this.grades,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    gender,
    birthDate,
    classroom,
    guardianPhone,
    notes,
    grades,
    createdAt,
  ];
}

// ─── المواد الدراسية الافتراضية ─────────────────────────────────────────────

/// عناصر التقييم لكل فصل دراسي
List<GradeItem> defaultSemesterItems() => const [
  GradeItem(name: 'المواظبة', maxScore: 10),
  GradeItem(name: 'السلوك', maxScore: 10),
  GradeItem(name: 'الحضور', maxScore: 10),
  GradeItem(name: 'اختبار الشهر الأول', maxScore: 20),
  GradeItem(name: 'اختبار الشهر الثاني', maxScore: 20),
  GradeItem(name: 'اختبار نهاية الفصل', maxScore: 30),
];

/// المواد الافتراضية لطالب جديد
List<SubjectGrades> defaultSubjectGrades() {
  final defaultSubjects = [
    ('quran', 'القرآن الكريم'),
    ('arabic', 'اللغة العربية'),
    ('math', 'الرياضيات'),
    ('science', 'العلوم'),
    ('english', 'اللغة الإنجليزية'),
    ('islamic', 'التربية الإسلامية'),
    ('arts', 'الفنون والأنشطة'),
  ];

  return defaultSubjects.map((sub) {
    return SubjectGrades(
      subjectId: sub.$1,
      subjectName: sub.$2,
      firstSemester: SubjectSemesterGrade(
        semester: Semester.first,
        items: defaultSemesterItems(),
      ),
      secondSemester: SubjectSemesterGrade(
        semester: Semester.second,
        items: defaultSemesterItems(),
      ),
    );
  }).toList();
}
