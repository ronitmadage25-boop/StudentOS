import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../models/models.dart';
import '../../services/timetable_service.dart';

/// Interactive Timetable Manager Screen.
///
/// Features Day-by-Day scheduling, dialog forms, time picker integrations,
/// and local storage persistence.
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TimetableEntry> _entries = [];
  bool _isLoading = true;

  final constDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: constDays.length, vsync: this);
    _loadTimetable();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTimetable() async {
    final loaded = await TimetableService.load();
    setState(() {
      _entries = TimetableService.sort(loaded);
      _isLoading = false;
    });
  }

  Future<void> _addOrUpdateEntry({
    required String subjectName,
    required String day,
    required String startTime,
    required String endTime,
    String? editId,
  }) async {
    List<TimetableEntry> updated;
    if (editId != null) {
      final existing = _entries.firstWhere((e) => e.id == editId);
      final updatedEntry = existing.copyWith(
        subjectName: subjectName,
        day: day,
        startTime: startTime,
        endTime: endTime,
      );
      updated = await TimetableService.update(updatedEntry);
    } else {
      final newEntry = TimetableEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subjectName: subjectName,
        day: day,
        startTime: startTime,
        endTime: endTime,
      );
      updated = await TimetableService.add(newEntry);
    }

    setState(() {
      _entries = updated;
    });
    
    // Auto switch tab to the day where the class was added
    final dayIndex = constDays.indexOf(day);
    if (dayIndex != -1) {
      _tabController.animateTo(dayIndex);
    }
  }

  Future<void> _deleteEntry(String id) async {
    final updated = await TimetableService.delete(id);
    if (!mounted) return;
    setState(() {
      _entries = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timetable entry deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  void _showEntryFormDialog({TimetableEntry? editEntry}) {
    final nameController = TextEditingController(text: editEntry?.subjectName);
    String selectedDay = editEntry?.day ?? constDays[_tabController.index];
    
    TimeOfDay selectedStartTime = editEntry != null
        ? TimeOfDay(
            hour: int.parse(editEntry.startTime.split(':')[0]),
            minute: int.parse(editEntry.startTime.split(':')[1]),
          )
        : const TimeOfDay(hour: 9, minute: 0);

    TimeOfDay selectedEndTime = editEntry != null
        ? TimeOfDay(
            hour: int.parse(editEntry.endTime.split(':')[0]),
            minute: int.parse(editEntry.endTime.split(':')[1]),
          )
        : const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String formatTime(TimeOfDay tod) {
              final hrs = tod.hour.toString().padLeft(2, '0');
              final mins = tod.minute.toString().padLeft(2, '0');
              return '$hrs:$mins';
            }

            return AlertDialog(
              title: Text(editEntry == null ? 'Add Class Slot' : 'Edit Class Slot'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Subject Name',
                        hintText: 'e.g. Operating Systems',
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    DropdownButtonFormField<String>(
                      initialValue: selectedDay,
                      decoration: const InputDecoration(
                        labelText: 'Day of Week',
                      ),
                      items: constDays
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedDay = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: AppDimens.lg),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Start Time', style: AppTextStyles.caption),
                              const SizedBox(height: 4),
                              OutlinedButton(
                                onPressed: () async {
                                  final tod = await showTimePicker(
                                    context: context,
                                    initialTime: selectedStartTime,
                                  );
                                  if (tod != null) {
                                    setDialogState(() {
                                      selectedStartTime = tod;
                                    });
                                  }
                                },
                                child: Text(formatTime(selectedStartTime)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('End Time', style: AppTextStyles.caption),
                              const SizedBox(height: 4),
                              OutlinedButton(
                                onPressed: () async {
                                  final tod = await showTimePicker(
                                    context: context,
                                    initialTime: selectedEndTime,
                                  );
                                  if (tod != null) {
                                    setDialogState(() {
                                      selectedEndTime = tod;
                                    });
                                  }
                                },
                                child: Text(formatTime(selectedEndTime)),
                              ),
                            ],
                          ),
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
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a subject name'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    
                    final startMin = selectedStartTime.hour * 60 + selectedStartTime.minute;
                    final endMin = selectedEndTime.hour * 60 + selectedEndTime.minute;
                    if (startMin >= endMin) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('End time must be after start time'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    _addOrUpdateEntry(
                      subjectName: nameController.text.trim(),
                      day: selectedDay,
                      startTime: formatTime(selectedStartTime),
                      endTime: formatTime(selectedEndTime),
                      editId: editEntry?.id,
                    );
                    Navigator.pop(context);
                  },
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.timetableTitle),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: constDays.map((d) => Tab(text: d.substring(0, 3))).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: constDays.map((day) {
                final dayEntries = _entries.where((e) => e.day == day).toList();

                if (dayEntries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: AppDimens.iconHuge,
                          color: AppColors.textTertiary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppDimens.md),
                        Text(
                          'No classes scheduled',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppDimens.xs),
                        Text(
                          'Tap + to add a subject entry',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppDimens.screenPadding),
                  itemCount: dayEntries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                  itemBuilder: (context, index) {
                    final entry = dayEntries[index];
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
                            padding: const EdgeInsets.all(AppDimens.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: AppDimens.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.subjectName,
                                  style: AppTextStyles.labelLarge,
                                ),
                                const SizedBox(height: AppDimens.xs),
                                Text(
                                  '${entry.startTime} – ${entry.endTime}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 20),
                            onPressed: () => _showEntryFormDialog(editEntry: entry),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                            onPressed: () => _deleteEntry(entry.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEntryFormDialog(),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textOnPrimary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
