import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/feature/student_management/domain/entities/student_entity.dart';
import 'package:albra3m4/feature/student_management/presentation/cubit/student_cubit.dart';
import 'package:albra3m4/feature/student_management/presentation/widgets/student_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentGradesScreen extends StatefulWidget {
  final StudentEntity student;
  const StudentGradesScreen({super.key, required this.student});

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen>
    with SingleTickerProviderStateMixin {
  late List<SubjectGrades> _grades;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Deep copy so we can mutate locally
    _grades = widget.student.grades
        .map(
          (g) => SubjectGrades(
            subjectId: g.subjectId,
            subjectName: g.subjectName,
            firstSemester: _copySemester(g.firstSemester),
            secondSemester: _copySemester(g.secondSemester),
          ),
        )
        .toList();
    _tabController = TabController(length: 2, vsync: this);
  }

  SubjectSemesterGrade _copySemester(SubjectSemesterGrade s) =>
      SubjectSemesterGrade(
        semester: s.semester,
        items: s.items
            .map(
              (i) =>
                  GradeItem(name: i.name, maxScore: i.maxScore, score: i.score),
            )
            .toList(),
      );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onScoreChanged(
    int subjIdx,
    Semester semester,
    int itemIdx,
    String val,
  ) {
    final score = double.tryParse(val);
    setState(() {
      final subj = _grades[subjIdx];
      if (semester == Semester.first) {
        final items = List<GradeItem>.from(subj.firstSemester.items);
        items[itemIdx] = items[itemIdx].copyWith(score: score);
        _grades[subjIdx] = subj.copyWith(
          firstSemester: subj.firstSemester.copyWith(items: items),
        );
      } else {
        final items = List<GradeItem>.from(subj.secondSemester.items);
        items[itemIdx] = items[itemIdx].copyWith(score: score);
        _grades[subjIdx] = subj.copyWith(
          secondSemester: subj.secondSemester.copyWith(items: items),
        );
      }
    });
  }

  Future<void> _save() async {
    context.read<StudentCubit>().updateGrades(widget.student.id, _grades);
    Navigator.pop(context, _grades);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إدارة الدرجات',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              Text(
                widget.student.fullName,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: 'الفصل الأول'),
              Tab(text: 'الفصل الثاني'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header with overall average
            _buildAverageHeader(),
            // Grades
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _SemesterGradesTab(
                    grades: _grades,
                    semester: Semester.first,
                    onChanged: _onScoreChanged,
                  ),
                  _SemesterGradesTab(
                    grades: _grades,
                    semester: Semester.second,
                    onChanged: _onScoreChanged,
                  ),
                ],
              ),
            ),
          ],
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
              icon: const Icon(Icons.save_rounded),
              label: const Text('حفظ الدرجات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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

  Widget _buildAverageHeader() {
    // Compute live average
    double totalPct = 0;
    int count = 0;
    for (final g in _grades) {
      totalPct += g.yearlyAverage;
      count++;
    }
    final avg = count > 0 ? (totalPct / count * 100) : 0.0;
    final avgStr = avg.toStringAsFixed(1);

    Color c = avg >= 85
        ? AppColors.success
        : avg >= 60
        ? AppColors.warning
        : AppColors.danger;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          StudentAvatar(initials: widget.student.initials, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'المعدل السنوي العام: ',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                    Text(
                      '$avgStr%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: c,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Circular progress
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: avg / 100,
                  backgroundColor: AppColors.line,
                  valueColor: AlwaysStoppedAnimation<Color>(c),
                  strokeWidth: 4,
                ),
                Center(
                  child: Text(
                    '${avg.toInt()}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: c,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Semester tab ─────────────────────────────────────────────────────────────

class _SemesterGradesTab extends StatelessWidget {
  final List<SubjectGrades> grades;
  final Semester semester;
  final void Function(int subjIdx, Semester semester, int itemIdx, String val)
  onChanged;

  const _SemesterGradesTab({
    required this.grades,
    required this.semester,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: grades.length,
      itemBuilder: (_, subjIdx) {
        final subj = grades[subjIdx];
        final semGrade = semester == Semester.first
            ? subj.firstSemester
            : subj.secondSemester;

        return _SubjectGradeCard(
          subjectName: subj.subjectName,
          semGrade: semGrade,
          onItemChanged: (itemIdx, val) =>
              onChanged(subjIdx, semester, itemIdx, val),
        );
      },
    );
  }
}

class _SubjectGradeCard extends StatelessWidget {
  final String subjectName;
  final SubjectSemesterGrade semGrade;
  final void Function(int itemIdx, String val) onItemChanged;

  const _SubjectGradeCard({
    required this.subjectName,
    required this.semGrade,
    required this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pct = semGrade.percentage;
    Color c = pct >= 0.85
        ? AppColors.success
        : pct >= 0.60
        ? AppColors.warning
        : AppColors.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: c.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.book_outlined, size: 16, color: c),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subjectName,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: c,
                    ),
                  ),
                ),
                Text(
                  '${semGrade.totalScore.toStringAsFixed(0)} / ${semGrade.totalMaxScore.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: c,
                  ),
                ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: AppColors.line,
                valueColor: AlwaysStoppedAnimation<Color>(c),
                minHeight: 4,
              ),
            ),
          ),
          // Grade items
          ...semGrade.items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return _GradeItemRow(
              item: item,
              isLast: i == semGrade.items.length - 1,
              onChanged: (val) => onItemChanged(i, val),
            );
          }),
        ],
      ),
    );
  }
}

class _GradeItemRow extends StatefulWidget {
  final GradeItem item;
  final bool isLast;
  final ValueChanged<String> onChanged;

  const _GradeItemRow({
    required this.item,
    required this.isLast,
    required this.onChanged,
  });

  @override
  State<_GradeItemRow> createState() => _GradeItemRowState();
}

class _GradeItemRowState extends State<_GradeItemRow> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.item.score != null
          ? widget.item.score!.toStringAsFixed(
              widget.item.score! % 1 == 0 ? 0 : 1,
            )
          : '',
    );
  }

  @override
  void didUpdateWidget(_GradeItemRow old) {
    super.didUpdateWidget(old);
    if (old.item.score != widget.item.score) {
      final newText = widget.item.score != null
          ? widget.item.score!.toStringAsFixed(
              widget.item.score! % 1 == 0 ? 0 : 1,
            )
          : '';
      if (_ctrl.text != newText) _ctrl.text = newText;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.item.name,
                  style: const TextStyle(fontSize: 13, color: AppColors.ink),
                ),
              ),
              Text(
                '/ ${widget.item.maxScore.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 64,
                height: 36,
                child: TextField(
                  controller: _ctrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: '—',
                    hintStyle: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
            ],
          ),
        ),
        if (!widget.isLast) const Divider(height: 1, indent: 14, endIndent: 14),
      ],
    );
  }
}
