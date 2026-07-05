import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../widgets/section_header.dart';
import '../../widgets/subject_card.dart';
import '../../services/attendance_service.dart';

/// Full attendance tracking screen with a smart calculator and dynamic subject list.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _totalController = TextEditingController();
  final _attendedController = TextEditingController();

  List<AttendanceSubject> _subjects = [];
  bool _isLoading = true;
  AttendanceResult? _calcResult;

  @override
  void initState() {
    super.initState();
    _loadData();
    _totalController.addListener(_calculateCalculatorAttendance);
    _attendedController.addListener(_calculateCalculatorAttendance);
  }

  @override
  void dispose() {
    _totalController.dispose();
    _attendedController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final loaded = await AttendanceService.load();
    setState(() {
      _subjects = loaded;
      _isLoading = false;
    });
  }

  void _calculateCalculatorAttendance() {
    final total = int.tryParse(_totalController.text);
    final attended = int.tryParse(_attendedController.text);

    if (total == null || attended == null || total <= 0 || attended < 0 || attended > total) {
      setState(() {
        _calcResult = null;
      });
      return;
    }

    setState(() {
      _calcResult = AttendanceService.calculate(
        totalLectures: total,
        attendedLectures: attended,
      );
    });
  }

  Future<void> _addSubject(String name, int total, int attended) async {
    final newSubject = AttendanceSubject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      totalLectures: total,
      attendedLectures: attended,
    );
    final updated = await AttendanceService.add(newSubject);
    setState(() {
      _subjects = updated;
    });
  }

  Future<void> _updateSubject(AttendanceSubject subject) async {
    final updated = await AttendanceService.update(subject);
    setState(() {
      _subjects = updated;
    });
  }

  Future<void> _deleteSubject(String id) async {
    final updated = await AttendanceService.delete(id);
    setState(() {
      _subjects = updated;
    });
  }

  void _showAddSubjectDialog() {
    final nameCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final attendedCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    hintText: 'e.g. Computer Networks',
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                TextField(
                  controller: totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Lectures',
                    hintText: 'e.g. 30',
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                TextField(
                  controller: attendedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Attended Lectures',
                    hintText: 'e.g. 25',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final total = int.tryParse(totalCtrl.text);
                final attended = int.tryParse(attendedCtrl.text);

                if (name.isEmpty) {
                  _showError('Subject name cannot be empty');
                  return;
                }
                if (total == null || total <= 0) {
                  _showError('Total lectures must be greater than 0');
                  return;
                }
                if (attended == null || attended < 0) {
                  _showError('Attended lectures must be 0 or more');
                  return;
                }
                if (attended > total) {
                  _showError('Attended lectures cannot exceed total lectures');
                  return;
                }

                _addSubject(name, total, attended);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSubjectDialog(AttendanceSubject subject) {
    final nameCtrl = TextEditingController(text: subject.name);
    final totalCtrl = TextEditingController(text: subject.totalLectures.toString());
    final attendedCtrl = TextEditingController(text: subject.attendedLectures.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Subject'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                TextField(
                  controller: totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Total Lectures',
                  ),
                ),
                const SizedBox(height: AppDimens.md),
                TextField(
                  controller: attendedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Attended Lectures',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _deleteSubject(subject.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final total = int.tryParse(totalCtrl.text);
                final attended = int.tryParse(attendedCtrl.text);

                if (name.isEmpty) {
                  _showError('Subject name cannot be empty');
                  return;
                }
                if (total == null || total <= 0) {
                  _showError('Total lectures must be greater than 0');
                  return;
                }
                if (attended == null || attended < 0) {
                  _showError('Attended lectures must be 0 or more');
                  return;
                }
                if (attended > total) {
                  _showError('Attended lectures cannot exceed total lectures');
                  return;
                }

                _updateSubject(subject.copyWith(
                  name: name,
                  totalLectures: total,
                  attendedLectures: attended,
                ));
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overall = AttendanceService.calculateOverall(_subjects);

    // Sum overall statistics
    int totalLecturesSum = 0;
    int attendedLecturesSum = 0;
    for (final s in _subjects) {
      totalLecturesSum += s.totalLectures;
      attendedLecturesSum += s.attendedLectures;
    }
    final absentLecturesSum = totalLecturesSum - attendedLecturesSum;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.attendanceTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimens.md),
                  // Overall Stats Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.xxl),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Overall Attendance',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Text(
                          '${overall.percentage.toStringAsFixed(1)}%',
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 48,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimens.xl),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.lg,
                            vertical: AppDimens.md,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildHeroStat('Total', '$totalLecturesSum'),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              _buildHeroStat('Present', '$attendedLecturesSum'),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              _buildHeroStat('Absent', '$absentLecturesSum'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.xxl),

                  // Calculator Section
                  const SectionHeader(title: 'Attendance Calculator'),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _totalController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Total Lectures',
                                  hintText: 'e.g. 40',
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.md),
                            Expanded(
                              child: TextField(
                                controller: _attendedController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Attended',
                                  hintText: 'e.g. 32',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_calcResult != null) ...[
                          const SizedBox(height: AppDimens.lg),
                          const Divider(),
                          const SizedBox(height: AppDimens.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Calculated Attendance:', style: AppTextStyles.labelLarge),
                              Text(
                                '${_calcResult!.percentage.toStringAsFixed(1)}%',
                                style: AppTextStyles.heading3.copyWith(
                                  color: _calcResult!.statusColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Status:', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                              Text(
                                _calcResult!.status,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: _calcResult!.statusColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.md),
                          if (_calcResult!.percentage < 75.0)
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: _calcResult!.statusColor),
                                const SizedBox(width: AppDimens.sm),
                                Expanded(
                                  child: Text(
                                    'You need to attend ${_calcResult!.lecturesNeeded} more lectures straight to reach 75%.',
                                    style: AppTextStyles.bodyMedium.copyWith(color: _calcResult!.statusColor),
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Icon(Icons.check_circle_outline_rounded, color: _calcResult!.statusColor),
                                const SizedBox(width: AppDimens.sm),
                                Expanded(
                                  child: Text(
                                    'You can safely miss ${_calcResult!.lecturesCanMiss} more lectures while keeping 75%+.',
                                    style: AppTextStyles.bodyMedium.copyWith(color: _calcResult!.statusColor),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.xxl),

                  // Subject List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: SectionHeader(title: 'Your Subjects'),
                      ),
                      TextButton.icon(
                        onPressed: _showAddSubjectDialog,
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text('Add Subject'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xs),

                  if (_subjects.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimens.xl),
                      child: Center(
                        child: Text(
                          'No subjects added yet. Tap Add Subject to begin.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subjects.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        return SubjectCard(
                          subjectName: subject.name,
                          totalLectures: subject.totalLectures,
                          attendedLectures: subject.attendedLectures,
                          onTap: () => _showEditSubjectDialog(subject),
                        );
                      },
                    ),
                  const SizedBox(height: AppDimens.xxxl),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textOnPrimary.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
