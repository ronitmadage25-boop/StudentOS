import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../attendance/attendance_screen.dart';
import '../cgpa/cgpa_screen.dart';
import '../exams/exams_screen.dart';
import '../syllabus/syllabus_screen.dart';
import '../timetable/timetable_screen.dart';
import '../../services/attendance_service.dart';
import '../../services/cgpa_service.dart';
import '../../services/exam_service.dart';
import '../../services/syllabus_service.dart';
import '../../services/timetable_service.dart';

/// StudentOS Home Dashboard Screen.
///
/// Displays a professional dashboard pulling live data in parallel using
/// [Future.wait] from Attendance, CGPA, Syllabus, Timetable, and Exams services.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  bool _hasLoadedOnce = false;

  double _attendanceProgress = 0.0;
  double _cgpa = 0.0;
  int _completedSemesters = 0;
  int _classesToday = 0;
  int _remainingClassesToday = 0;
  int _pendingSyllabusUnitsCount = 0;
  double _syllabusProgress = 0.0;
  int _completedSyllabusUnits = 0;
  int _totalSyllabusUnits = 0;

  List<ExamModel> _upcomingExams = [];
  List<TimetableEntry> _todayClassesList = [];
    final List<Map<String, dynamic>> _pendingSyllabusList = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all services in parallel using Future.wait
      final results = await Future.wait([
        AttendanceService.load(),
        CGPAService.load(),
        SyllabusService.load(),
        TimetableService.load(),
        ExamService.load(),
      ]);

      final attendanceSubjects = results[0] as List<AttendanceSubject>;
      final semesters = results[1] as List<SemesterModel>;
      final syllabusSubjects = results[2] as List<SyllabusSubject>;
      final timetableEntries = results[3] as List<TimetableEntry>;
      final exams = results[4] as List<ExamModel>;

      // 1. Calculate overall attendance
      final attendanceResult = AttendanceService.calculateOverall(attendanceSubjects);
      _attendanceProgress = attendanceResult.percentage;

      // 2. Calculate CGPA
      _cgpa = CGPAService.calculateCGPA(semesters);
      _completedSemesters = semesters.length;

      // 3. Calculate Syllabus Progress
      _syllabusProgress = SyllabusService.calculateOverallProgress(syllabusSubjects);
      _totalSyllabusUnits = 0;
      _completedSyllabusUnits = 0;
      _pendingSyllabusList.clear();
      for (final s in syllabusSubjects) {
        _totalSyllabusUnits += s.units.length;
        _completedSyllabusUnits += s.completedUnitsCount;
        for (final u in s.units) {
          if (!u.isCompleted) {
            _pendingSyllabusList.add({
              'subject': s.name,
              'unit': u.name,
            });
          }
        }
      }
      _pendingSyllabusUnitsCount = _totalSyllabusUnits - _completedSyllabusUnits;

      // 4. Calculate Timetable Stats
      final now = DateTime.now();
      const weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final todayName = weekdays[now.weekday - 1];
      _todayClassesList = timetableEntries.where((e) => e.day == todayName).toList();
      _classesToday = _todayClassesList.length;

      final currentMinutes = now.hour * 60 + now.minute;
      _remainingClassesToday = _todayClassesList.where((e) => e.endTimeMinutes > currentMinutes).length;

      // 5. Sort Exams
      _upcomingExams = ExamService.getUpcomingSorted(exams);

    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
        _hasLoadedOnce = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLoadedOnce && _isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          child: CustomScrollView(
            slivers: [
              // ── Greeting Header ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.screenPadding,
                    AppDimens.xxl,
                    AppDimens.screenPadding,
                    AppDimens.lg,
                  ),
                  child: _GreetingHeader(),
                ),
              ),
  
              // ── Quick Stats Section ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                  ),
                  child: const SectionHeader(
                    title: AppStrings.quickStats,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                  ),
                  child: _QuickStatsGrid(
                    attendanceProgress: _attendanceProgress,
                    cgpa: _cgpa,
                    completedSemesters: _completedSemesters,
                    classesToday: _classesToday,
                    remainingClassesToday: _remainingClassesToday,
                    pendingUnits: _pendingSyllabusUnitsCount,
                    onReload: _loadAllData,
                  ),
                ),
              ),
  
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimens.xxl),
              ),
  
              // ── Syllabus Progress ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                  ),
                  child: const SectionHeader(title: 'Progress'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                  ),
                  child: ProgressCard(
                    label: 'Syllabus Progress',
                    percentage: _syllabusProgress,
                    subtitle: '$_completedSyllabusUnits of $_totalSyllabusUnits units completed',
                    icon: Icons.menu_book_rounded,
                    progressColor: AppColors.secondaryPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SyllabusScreen(),
                        ),
                      ).then((_) => _loadAllData());
                    },
                  ),
                ),
              ),
  
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimens.xxl),
              ),
  
              // ── Upcoming Exams ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                  ),
                  child: SectionHeader(
                    title: AppStrings.upcomingExams,
                    actionLabel: AppStrings.seeAll,
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExamsScreen(),
                        ),
                      ).then((_) => _loadAllData());
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                  ),
                  child: _UpcomingExamsList(
                    exams: _upcomingExams,
                    onReload: _loadAllData,
                  ),
                ),
              ),
  
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimens.xxl),
              ),
  
              // ── Today's Reminders ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                  ),
                  child: const SectionHeader(
                    title: AppStrings.reminders,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPadding,
                  ),
                  child: _RemindersList(
                    todayClasses: _todayClassesList,
                    upcomingExams: _upcomingExams,
                    pendingSyllabus: _pendingSyllabusList,
                    onReload: _loadAllData,
                  ),
                ),
              ),
  
              // Bottom spacing for navigation bar
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimens.huge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Private Sub-Widgets ──────────────────────────────────────────────────────

class _GreetingHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.greeting,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimens.xs),
              Text(AppStrings.greetingName, style: AppTextStyles.heading1),
            ],
          ),
        ),
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: const Center(
            child: Text(
              'R',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickStatsGrid extends StatelessWidget {
  const _QuickStatsGrid({
    required this.attendanceProgress,
    required this.cgpa,
    required this.completedSemesters,
    required this.classesToday,
    required this.remainingClassesToday,
    required this.pendingUnits,
    required this.onReload,
  });

  final double attendanceProgress;
  final double cgpa;
  final int completedSemesters;
  final int classesToday;
  final int remainingClassesToday;
  final int pendingUnits;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Attendance',
                value: '${attendanceProgress.toStringAsFixed(1)}%',
                subtitle: 'Overall Average',
                icon: Icons.fact_check_rounded,
                accentColor: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AttendanceScreen(),
                    ),
                  ).then((_) => onReload());
                },
              ),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: StatCard(
                label: 'CGPA',
                value: cgpa.toStringAsFixed(2),
                subtitle: completedSemesters == 1
                    ? '1 Semester'
                    : '$completedSemesters Semesters',
                icon: Icons.school_rounded,
                accentColor: AppColors.primaryBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CGPAScreen(),
                    ),
                  ).then((_) => onReload());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Classes Today',
                value: '$classesToday',
                subtitle: '$remainingClassesToday remaining',
                icon: Icons.calendar_today_rounded,
                accentColor: AppColors.secondaryPurple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TimetableScreen(),
                    ),
                  ).then((_) => onReload());
                },
              ),
            ),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: StatCard(
                label: 'Tasks Due',
                value: '$pendingUnits',
                subtitle: 'Syllabus units',
                icon: Icons.task_alt_rounded,
                accentColor: AppColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SyllabusScreen(),
                    ),
                  ).then((_) => onReload());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UpcomingExamsList extends StatelessWidget {
  const _UpcomingExamsList({
    required this.exams,
    required this.onReload,
  });

  final List<ExamModel> exams;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.xl),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Text(
            'No upcoming exams 🎉',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Limit to top 3 upcoming exams
    final displayExams = exams.take(3).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayExams.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
      itemBuilder: (context, index) {
        final exam = displayExams[index];
        return InfoCard(
          title: exam.examName,
          subtitle: '${exam.subjectName} · ${exam.daysLeft} Days Left',
          icon: Icons.timer_rounded,
          iconColor: exam.daysLeft <= 7 ? AppColors.error : AppColors.warning,
          trailing: _CountdownBadge(daysLeft: exam.daysLeft),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ExamsScreen(),
              ),
            ).then((_) => onReload());
          },
        );
      },
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.daysLeft});

  final int daysLeft;

  Color get _color {
    if (daysLeft <= 7) return AppColors.error;
    if (daysLeft <= 14) return AppColors.warning;
    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.md,
        vertical: AppDimens.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      ),
      child: Text(
        '$daysLeft d',
        style: AppTextStyles.labelMedium.copyWith(color: _color),
      ),
    );
  }
}

class _RemindersList extends StatelessWidget {
  const _RemindersList({
    required this.todayClasses,
    required this.upcomingExams,
    required this.pendingSyllabus,
    required this.onReload,
  });

  final List<TimetableEntry> todayClasses;
  final List<ExamModel> upcomingExams;
  final List<Map<String, dynamic>> pendingSyllabus;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final List<Widget> reminderCards = [];
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    // 1. Next Remaining Class today
    final remainingClasses = todayClasses.where((e) => e.endTimeMinutes > currentMinutes).toList()
      ..sort((a, b) => a.startTimeMinutes.compareTo(b.startTimeMinutes));

    if (remainingClasses.isNotEmpty) {
      final nextClass = remainingClasses.first;
      reminderCards.add(
        InfoCard(
          title: 'Next Class: ${nextClass.subjectName}',
          subtitle: '${nextClass.startTime} – ${nextClass.endTime} · Today',
          icon: Icons.notifications_active_rounded,
          iconColor: AppColors.warning,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TimetableScreen()),
            ).then((_) => onReload());
          },
        ),
      );
    }

    // 2. Next Upcoming Exam reminder
    final nextUpcoming = ExamService.getUpcomingSorted(upcomingExams);
    if (nextUpcoming.isNotEmpty) {
      final nextExam = nextUpcoming.first;
      reminderCards.add(
        InfoCard(
          title: '${nextExam.examName} Countdown',
          subtitle: '${nextExam.subjectName} · ${nextExam.daysLeft} days left',
          icon: Icons.assignment_rounded,
          iconColor: nextExam.daysLeft <= 7 ? AppColors.error : AppColors.primaryBlue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExamsScreen()),
            ).then((_) => onReload());
          },
        ),
      );
    }

    // 3. Pending syllabus unit study reminder
    if (pendingSyllabus.isNotEmpty) {
      final pending = pendingSyllabus.first;
      reminderCards.add(
        InfoCard(
          title: 'Study: ${pending['unit']}',
          subtitle: '${pending['subject']} · Pending',
          icon: Icons.menu_book_rounded,
          iconColor: AppColors.secondaryPurple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SyllabusScreen()),
            ).then((_) => onReload());
          },
        ),
      );
    }

    // fallback if completely clean
    if (reminderCards.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.xl),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Center(
          child: Text(
            'All caught up! 🎉 No remaining classes, exams, or syllabus units today.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reminderCards.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
      itemBuilder: (context, index) => reminderCards[index],
    );
  }
}
