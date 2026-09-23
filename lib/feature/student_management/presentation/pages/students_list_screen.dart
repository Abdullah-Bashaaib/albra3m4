import 'package:albra3m4/core/constants/app_colors.dart';
import 'package:albra3m4/core/utils/widgets/custom_snack_bar.dart';
import 'package:albra3m4/feature/student_management/domain/entities/student_entity.dart';
import 'package:albra3m4/feature/student_management/presentation/cubit/student_cubit.dart';
import 'package:albra3m4/feature/student_management/presentation/pages/student_details_screen.dart';
import 'package:albra3m4/feature/student_management/presentation/pages/student_form_screen.dart';
import 'package:albra3m4/feature/student_management/presentation/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  static const _tabs = [
    (null, 'الكل'),
    (KindergartenClass.kg1, 'KG1'),
    (KindergartenClass.kg2, 'KG2'),
    (KindergartenClass.kg3, 'KG3'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChange);
    context.read<StudentCubit>().loadStudents();
  }

  void _onTabChange() {
    if (!_tabController.indexIsChanging) return;
    final cls = _tabs[_tabController.index].$1;
    context.read<StudentCubit>().filterByClass(cls);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAdd() async {
    final result = await Navigator.push<StudentEntity>(
      context,
      MaterialPageRoute(builder: (_) => const StudentFormScreen()),
    );
    if (result != null && mounted) {
      context.read<StudentCubit>().saveStudent(result);
    }
  }

  Future<void> _openDetails(StudentEntity student) async {
    final cubit = context.read<StudentCubit>();
    final rank = cubit.rankInClass(student);

    final result = await Navigator.push<_StudentListResult>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: StudentDetailsScreen(student: student, rankInClass: rank),
        ),
      ),
    );

    if (result == null || !mounted) return;
    if (result.deleted) {
      cubit.deleteStudent(student.id);
    } else if (result.updated != null) {
      cubit.saveStudent(result.updated!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentCubit, StudentState>(
      listener: (ctx, state) {
        if (state.error != null) CustomSnackBar.showError(ctx, state.error!);
        if (state.success != null) {
          CustomSnackBar.showSuccess(ctx, state.success!);
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (ctx, innerBoxScrolled) => [
              _buildSliverAppBar(),
              _buildTabBar(),
            ],
            body: Column(
              children: [
                _buildSearchBar(),
                Expanded(child: _buildList()),
              ],
            ),
          ),
          floatingActionButton: _buildFab(),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.apricot,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE65100), Color(0xFFFFB74D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                left: -30,
                child: _DecorCircle(size: 160, opacity: 0.08),
              ),
              Positioned(
                bottom: -20,
                right: -20,
                child: _DecorCircle(size: 120, opacity: 0.12),
              ),
            ],
          ),
        ),
        title: const Text(
          'إدارة الطلاب',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        BlocBuilder<StudentCubit, StudentState>(
          buildWhen: (p, c) => p.students.length != c.students.length,
          builder: (_, state) {
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: Text(
                  '${state.students.length} طالب',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  SliverPersistentHeader _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: AppColors.apricot,
          indicatorWeight: 3,
          labelColor: AppColors.apricot,
          unselectedLabelColor: AppColors.muted,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          tabs: _tabs.map((t) => Tab(text: t.$2)).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: TextField(
        controller: _searchController,
        onChanged: context.read<StudentCubit>().search,
        decoration: InputDecoration(
          hintText: 'ابحث عن طالب...',
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.muted,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 18,
                    color: AppColors.muted,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<StudentCubit>().search('');
                  },
                )
              : null,
          fillColor: AppColors.card,
          filled: true,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.apricot, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<StudentCubit, StudentState>(
      builder: (_, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.displayedStudents.isEmpty) {
          return _EmptyView(
            hasQuery: state.query.isNotEmpty,
            hasFilter: state.selectedClass != null,
          );
        }

        // ترتيب الطلاب للحصول على الـ rank
        final ranked = context.read<StudentCubit>().rankedStudents;

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: state.displayedStudents.length,
          itemBuilder: (_, i) {
            final student = state.displayedStudents[i];
            final globalRank = ranked.indexWhere((s) => s.id == student.id) + 1;
            return StudentCard(
              student: student,
              rankInClass: globalRank,
              onTap: () => _openDetails(student),
            );
          },
        );
      },
    );
  }

  Widget _buildFab() {
    return BlocBuilder<StudentCubit, StudentState>(
      builder: (_, state) {
        if (state.isLoadingSave) {
          return const FloatingActionButton(
            onPressed: null,
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        return FloatingActionButton.extended(
          onPressed: _openAdd,
          backgroundColor: AppColors.apricot,
          icon: const Icon(Icons.person_add_rounded),
          label: const Text(
            'إضافة طالب',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        );
      },
    );
  }
}

// ─── Result model ────────────────────────────────────────────────────────────

class _StudentListResult {
  final StudentEntity? updated;
  final bool deleted;
  const _StudentListResult({this.updated, this.deleted = false});
}

// ─── Decorative circle ───────────────────────────────────────────────────────

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final bool hasQuery;
  final bool hasFilter;
  const _EmptyView({required this.hasQuery, required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off_rounded : Icons.child_care_rounded,
            size: 64,
            color: AppColors.line,
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery
                ? 'لا توجد نتائج مطابقة'
                : hasFilter
                ? 'لا يوجد طلاب في هذا الصف'
                : 'لا يوجد طلاب مضافون بعد',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!hasQuery) ...[
            const SizedBox(height: 8),
            const Text(
              'اضغط على + لإضافة طالب جديد',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tab bar delegate ─────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}
