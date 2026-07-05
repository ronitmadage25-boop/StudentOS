import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../widgets/section_header.dart';
import '../../services/cgpa_service.dart';

/// CGPA Screen with history display, dynamic SGPA logs, and target calculator.
class CGPAScreen extends StatefulWidget {
  const CGPAScreen({super.key});

  @override
  State<CGPAScreen> createState() => _CGPAScreenState();
}

class _CGPAScreenState extends State<CGPAScreen> {
  final _targetController = TextEditingController();
  final _sgpaInputController = TextEditingController();

  List<SemesterModel> _semesters = [];
  bool _isLoading = true;
  double _currentCGPA = 0.0;
  double? _requiredSGPA;
  bool _isAchievable = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _targetController.addListener(_calculateRequiredSGPA);
  }

  @override
  void dispose() {
    _targetController.dispose();
    _sgpaInputController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final loaded = await CGPAService.load();
    setState(() {
      _semesters = loaded;
      _isLoading = false;
    });
    _recalculateCGPA();
  }

  void _recalculateCGPA() {
    setState(() {
      _currentCGPA = CGPAService.calculateCGPA(_semesters);
    });
    _calculateRequiredSGPA();
  }

  void _calculateRequiredSGPA() {
    final target = double.tryParse(_targetController.text);
    if (target == null || target <= 0 || target > 10.0) {
      setState(() {
        _requiredSGPA = null;
        _isAchievable = true;
      });
      return;
    }

    final result = CGPAService.calculateRequiredSGPA(
      currentCGPA: _currentCGPA,
      completedSemesters: _semesters.length,
      targetCGPA: target,
    );

    setState(() {
      _requiredSGPA = result.requiredSGPA;
      _isAchievable = result.isAchievable;
    });
  }

  Future<void> _addSemesterSGPA(double sgpa) async {
    final newSem = SemesterModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      semesterNumber: _semesters.length + 1,
      sgpa: sgpa,
    );
    final updated = await CGPAService.add(newSem);
    setState(() {
      _semesters = updated;
    });
    _recalculateCGPA();
  }

  Future<void> _removeSemesterSGPA(String id) async {
    final updated = await CGPAService.delete(id);
    setState(() {
      _semesters = updated;
    });
    _recalculateCGPA();
  }

  Color _getSGPADotColor(double sgpa) {
    if (sgpa >= 8.0) return AppColors.success;
    if (sgpa >= 7.0) return AppColors.primaryBlue;
    return AppColors.warning;
  }

  void _showAddSemesterDialog() {
    _sgpaInputController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Semester SGPA'),
          content: TextField(
            controller: _sgpaInputController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Semester SGPA',
              hintText: 'e.g. 8.5',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final val = double.tryParse(_sgpaInputController.text);
                if (val != null && val >= 0.0 && val <= 10.0) {
                  _addSemesterSGPA(val);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid SGPA between 0.0 and 10.0'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.cgpaTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimens.md),
                  // Overall CGPA Hero Card
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
                          'Cumulative GPA',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Text(
                          _currentCGPA.toStringAsFixed(2),
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 48,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sm),
                        Text(
                          '${_semesters.length} Semesters Completed',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.xxl),

                  // Target Calculator Section
                  const SectionHeader(title: 'Target CGPA Calculator'),
                  Container(
                    padding: const EdgeInsets.all(AppDimens.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _targetController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Desired Cumulative CGPA',
                            hintText: 'e.g. 8.5',
                            prefixIcon: Icon(Icons.stars_rounded, color: AppColors.primaryBlue),
                          ),
                        ),
                        if (_requiredSGPA != null) ...[
                          const SizedBox(height: AppDimens.lg),
                          const Divider(),
                          const SizedBox(height: AppDimens.lg),
                          if (_isAchievable)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Required SGPA in Sem ${_semesters.length + 1}:',
                                    style: AppTextStyles.labelLarge,
                                  ),
                                ),
                                Text(
                                  _requiredSGPA!.toStringAsFixed(2),
                                  style: AppTextStyles.heading2.copyWith(
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.error),
                                const SizedBox(width: AppDimens.sm),
                                Expanded(
                                  child: Text(
                                    'Target is mathematically unachievable (Required SGPA: ${_requiredSGPA!.toStringAsFixed(2)})',
                                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.xxl),

                  // Semester Wise History Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: SectionHeader(title: 'Semester Wise'),
                      ),
                      TextButton.icon(
                        onPressed: _showAddSemesterDialog,
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                        label: const Text('Add Sem'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xs),

                  if (_semesters.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimens.xl),
                      child: Center(
                        child: Text(
                          'No semesters added yet. Click Add Sem to start.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _semesters.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                      itemBuilder: (context, index) {
                        final semester = _semesters[index];
                        final sgpa = semester.sgpa;
                        final color = _getSGPADotColor(sgpa);
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
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppDimens.md),
                              Expanded(
                                child: Text(
                                  'Semester ${semester.semesterNumber}',
                                  style: AppTextStyles.labelLarge,
                                ),
                              ),
                              Text(
                                sgpa.toStringAsFixed(2),
                                style: AppTextStyles.heading4.copyWith(color: color),
                              ),
                              const SizedBox(width: AppDimens.md),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                                onPressed: () => _removeSemesterSGPA(semester.id),
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
