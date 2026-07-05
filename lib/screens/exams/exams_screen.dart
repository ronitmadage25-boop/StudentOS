import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../widgets/section_header.dart';
import '../../widgets/exam_card.dart';
import '../../services/exam_service.dart';

/// Full Exam Countdown screen with countdown widgets and a list of upcoming exams.
class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final _examNameController = TextEditingController();
  final _subjectNameController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedExamType = 'MSE';

  List<ExamModel> _exams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _examNameController.dispose();
    _subjectNameController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final loaded = await ExamService.load();
    setState(() {
      _exams = loaded;
      _isLoading = false;
    });
  }

  List<ExamModel> get _upcomingSortedExams => ExamService.getUpcomingSorted(_exams);

  Future<void> _addNewExam() async {
    if (_examNameController.text.trim().isEmpty ||
        _subjectNameController.text.trim().isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a date'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newExam = ExamModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      examName: _examNameController.text.trim(),
      subjectName: _subjectNameController.text.trim(),
      examDate: _selectedDate!,
      examType: _selectedExamType,
    );

    final updated = await ExamService.add(newExam);
    if (!mounted) return;
    setState(() {
      _exams = updated;
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exam added successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteExam(String id) async {
    final updated = await ExamService.delete(id);
    if (!mounted) return;
    setState(() {
      _exams = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exam deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteConfirmation(ExamModel exam) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Exam'),
          content: Text('Are you sure you want to delete ${exam.examName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteExam(exam.id);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddExamDialog() {
    _examNameController.clear();
    _subjectNameController.clear();
    _selectedDate = null;
    _selectedExamType = 'MSE';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Upcoming Exam'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _examNameController,
                      decoration: const InputDecoration(
                        labelText: 'Exam Name',
                        hintText: 'e.g. AOA MSE',
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    TextField(
                      controller: _subjectNameController,
                      decoration: const InputDecoration(
                        labelText: 'Subject Name',
                        hintText: 'e.g. Analysis of Algorithms',
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedExamType,
                      decoration: const InputDecoration(
                        labelText: 'Exam Type',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'MSE', child: Text('Mid Sem (MSE)')),
                        DropdownMenuItem(value: 'ESE', child: Text('End Sem (ESE)')),
                        DropdownMenuItem(value: 'ISE', child: Text('Internal (ISE)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            _selectedExamType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppDimens.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'No date selected'
                                : 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: const Text('Select Date'),
                        ),
                      ],
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
                  onPressed: _addNewExam,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedExams = _upcomingSortedExams;
    final hasExams = sortedExams.isNotEmpty;
    final nextExam = hasExams ? sortedExams.first : null;

    String getShortMonth(int month) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[month - 1];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.examsTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppDimens.md),
                  
                  // Next Exam Hero Card
                  if (nextExam != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimens.xxl),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.error, Color(0xFFDC2626)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => _showDeleteConfirmation(nextExam),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Next Exam',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimens.md,
                                  vertical: AppDimens.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                                ),
                                child: Text(
                                  nextExam.examType,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textOnPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.lg),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${nextExam.daysLeft}',
                                style: AppTextStyles.heading1.copyWith(
                                  fontSize: 64,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                              const SizedBox(width: AppDimens.xs),
                              Text(
                                nextExam.daysLeft == 1 ? 'Day Left' : 'Days Left',
                                style: AppTextStyles.heading4.copyWith(
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.md),
                          Text(
                            nextExam.examName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${getShortMonth(nextExam.examDate.month)} ${nextExam.examDate.day}, ${nextExam.examDate.year}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimens.xxl),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Center(
                        child: Text(
                          'No upcoming exams scheduled 🎉',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: AppDimens.xxl),

                  // All Exams Section
                  const SectionHeader(title: 'All Exams'),
                  
                  if (!hasExams)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimens.xl),
                      child: Center(
                        child: Text(
                          'Tap + to schedule your first exam.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedExams.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                      itemBuilder: (context, index) {
                        final exam = sortedExams[index];
                        return ExamCard(
                          examName: exam.examName,
                          subjectName: exam.subjectName,
                          daysLeft: exam.daysLeft,
                          examType: exam.examType,
                          onTap: () => _showDeleteConfirmation(exam),
                        );
                      },
                    ),
                  const SizedBox(height: AppDimens.huge),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExamDialog,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
