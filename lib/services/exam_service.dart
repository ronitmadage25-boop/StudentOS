import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service layer containing core business logic and persistence for exam events.
class ExamService {
  ExamService._();

  static const String _storageKey = 'studentos_exams';

  /// Filters and returns only future/upcoming exams sorted by the nearest date first.
  static List<ExamModel> getUpcomingSorted(List<ExamModel> exams) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Keep exams scheduled for today or in the future
    return exams.where((exam) {
      final target = DateTime(exam.examDate.year, exam.examDate.month, exam.examDate.day);
      return !target.isBefore(today);
    }).toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  /// Saves the list of exam events to SharedPreferences.
  static Future<void> save(List<ExamModel> exams) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = exams.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Loads the list of exam events from SharedPreferences.
  static Future<List<ExamModel>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);
    if (jsonList == null || jsonList.isEmpty) {
      return _getMockExams();
    }
    return jsonList
        .map((str) => ExamModel.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  /// Adds a new exam and returns the updated list.
  static Future<List<ExamModel>> add(ExamModel exam) async {
    final exams = await load();
    exams.add(exam);
    await save(exams);
    return exams;
  }

  /// Updates an existing exam and returns the updated list.
  static Future<List<ExamModel>> update(ExamModel exam) async {
    final exams = await load();
    final index = exams.indexWhere((e) => e.id == exam.id);
    if (index != -1) {
      exams[index] = exam;
      await save(exams);
    }
    return exams;
  }

  /// Deletes an exam and returns the updated list.
  static Future<List<ExamModel>> delete(String id) async {
    final exams = await load();
    exams.removeWhere((e) => e.id == id);
    await save(exams);
    return exams;
  }

  /// Default mock exams.
  static List<ExamModel> _getMockExams() {
    final now = DateTime.now();
    return [
      ExamModel(
        id: 'exam_1',
        examName: 'AOA MSE',
        subjectName: 'Analysis of Algorithms',
        examDate: now.add(const Duration(days: 5)),
        examType: 'MSE',
      ),
      ExamModel(
        id: 'exam_2',
        examName: 'OS MSE',
        subjectName: 'Operating Systems',
        examDate: now.add(const Duration(days: 8)),
        examType: 'MSE',
      ),
      ExamModel(
        id: 'exam_3',
        examName: 'COA ISE',
        subjectName: 'Computer Organization',
        examDate: now.add(const Duration(days: 12)),
        examType: 'ISE',
      ),
      ExamModel(
        id: 'exam_4',
        examName: 'SE ISE',
        subjectName: 'Software Engineering',
        examDate: now.add(const Duration(days: 20)),
        examType: 'ISE',
      ),
      ExamModel(
        id: 'exam_5',
        examName: 'DBMS ESE',
        subjectName: 'Database Management Systems',
        examDate: now.add(const Duration(days: 45)),
        examType: 'ESE',
      ),
    ];
  }
}
