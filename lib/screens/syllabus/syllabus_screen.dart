import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../widgets/section_header.dart';
import '../../services/syllabus_service.dart';

/// Syllabus Screen showing completion progress details per subject.
///
/// Fully integrated with [SyllabusService] to calculate dynamic progress percentages,
/// toggle unit completion, add subjects, and add units dynamically.
class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  List<SyllabusSubject> _subjects = [];
  bool _isLoading = true;

  final _subjectNameController = TextEditingController();
  final _unitNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSyllabus();
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    _unitNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSyllabus() async {
    final loaded = await SyllabusService.load();
    setState(() {
      _subjects = loaded;
      _isLoading = false;
    });
  }

  Future<void> _toggleUnitCompletion(String subjectId, String unitId, bool completed) async {
    final targetSubject = _subjects.firstWhere((sub) => sub.id == subjectId);
    final updatedUnits = targetSubject.units.map((unit) {
      if (unit.id == unitId) {
        return unit.copyWith(isCompleted: completed);
      }
      return unit;
    }).toList();
    final updatedSubject = targetSubject.copyWith(units: updatedUnits);
    final updated = await SyllabusService.update(updatedSubject);

    setState(() {
      _subjects = updated;
    });
  }

  Future<void> _addSubject(String name) async {
    if (name.trim().isEmpty) return;

    final newSubject = SyllabusSubject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      units: [
        SyllabusUnit(
          id: '${DateTime.now().millisecondsSinceEpoch}_u1',
          name: 'Unit 1: Introduction',
          isCompleted: false,
        ),
        SyllabusUnit(
          id: '${DateTime.now().millisecondsSinceEpoch}_u2',
          name: 'Unit 2: Core Concepts',
          isCompleted: false,
        ),
      ],
    );

    final updated = await SyllabusService.add(newSubject);
    setState(() {
      _subjects = updated;
    });
  }

  Future<void> _addUnit(String subjectId, String unitName) async {
    if (unitName.trim().isEmpty) return;

    final targetSubject = _subjects.firstWhere((sub) => sub.id == subjectId);
    final updatedUnits = List<SyllabusUnit>.from(targetSubject.units)
      ..add(
        SyllabusUnit(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: unitName.trim(),
          isCompleted: false,
        ),
      );
    final updatedSubject = targetSubject.copyWith(units: updatedUnits);
    final updated = await SyllabusService.update(updatedSubject);

    setState(() {
      _subjects = updated;
    });
  }

  Future<void> _deleteSubject(String subjectId) async {
    final updated = await SyllabusService.delete(subjectId);
    if (!mounted) return;
    setState(() {
      _subjects = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subject deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  void _showAddSubjectDialog() {
    _subjectNameController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subject'),
          content: TextField(
            controller: _subjectNameController,
            decoration: const InputDecoration(
              labelText: 'Subject Name',
              hintText: 'e.g. Software Engineering',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_subjectNameController.text.trim().isNotEmpty) {
                  _addSubject(_subjectNameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddUnitDialog(String subjectId) {
    _unitNameController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Syllabus Unit'),
          content: TextField(
            controller: _unitNameController,
            decoration: const InputDecoration(
              labelText: 'Unit / Chapter Name',
              hintText: 'e.g. Unit 3: Advanced Topics',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_unitNameController.text.trim().isNotEmpty) {
                  _addUnit(subjectId, _unitNameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final overallProgress = SyllabusService.calculateOverallProgress(_subjects);
    
    // Count total units vs completed
    int totalUnits = 0;
    int completedUnits = 0;
    for (final s in _subjects) {
      totalUnits += s.units.length;
      completedUnits += s.completedUnitsCount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.syllabusTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimens.md),
                  // Overall Progress Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimens.xxl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.secondaryPurple, Color(0xFF6D28D9)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryPurple.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Completion',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Text(
                          '${overallProgress.round()}%',
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 48,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimens.lg),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                          child: LinearProgressIndicator(
                            value: totalUnits == 0 ? 0.0 : (completedUnits / totalUnits),
                            minHeight: AppDimens.progressBarHeight,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: AppDimens.xs),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$completedUnits of $totalUnits units completed',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.xxl),

                  // Subject Cards Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: SectionHeader(title: 'Subjects'),
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
                          'No subjects added. Tap Add Subject to begin.',
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
                        final progress = subject.progressPercentage;

                        return Container(
                          padding: const EdgeInsets.all(AppDimens.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                            border: Border.all(color: AppColors.divider),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      subject.name,
                                      style: AppTextStyles.heading4,
                                    ),
                                  ),
                                  Text(
                                    '${progress.round()}%',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.secondaryPurple,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimens.sm),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    onPressed: () => _deleteSubject(subject.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimens.sm),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                                child: LinearProgressIndicator(
                                  value: subject.units.isEmpty ? 0.0 : (subject.completedUnitsCount / subject.units.length),
                                  minHeight: AppDimens.progressBarHeight - 2,
                                  backgroundColor: AppColors.secondaryPurple.withValues(alpha: 0.12),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryPurple),
                                ),
                              ),
                              const SizedBox(height: AppDimens.md),
                              const Divider(),
                              const SizedBox(height: AppDimens.sm),
                              
                              if (subject.units.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
                                  child: Text(
                                    'No units added to this subject yet.',
                                    style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
                                  ),
                                )
                              else
                                ...subject.units.map((unit) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: AppDimens.xs),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _toggleUnitCompletion(
                                            subject.id,
                                            unit.id,
                                            !unit.isCompleted,
                                          ),
                                          child: Icon(
                                            unit.isCompleted
                                                ? Icons.check_circle_rounded
                                                : Icons.radio_button_unchecked_rounded,
                                            color: unit.isCompleted
                                                ? AppColors.success
                                                : AppColors.textTertiary,
                                            size: AppDimens.iconLg,
                                          ),
                                        ),
                                        const SizedBox(width: AppDimens.md),
                                        Expanded(
                                          child: Text(
                                            unit.name,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: unit.isCompleted
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary,
                                              decoration: unit.isCompleted
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          unit.isCompleted ? 'Completed' : 'Pending',
                                          style: AppTextStyles.caption.copyWith(
                                            color: unit.isCompleted
                                                ? AppColors.success
                                                : AppColors.textTertiary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              
                              const SizedBox(height: AppDimens.sm),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _showAddUnitDialog(subject.id),
                                  icon: const Icon(Icons.add_rounded, size: 16),
                                  label: const Text('Add Unit'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryBlue,
                                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: AppDimens.huge),
                ],
              ),
            ),
    );
  }
}
