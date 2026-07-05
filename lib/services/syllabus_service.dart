import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service layer managing persistence, CRUD operations, and progress calculations for syllabus.
class SyllabusService {
  SyllabusService._();

  static const String _storageKey = 'studentos_syllabus';

  /// Saves the list of syllabus subjects to SharedPreferences.
  static Future<void> save(List<SyllabusSubject> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = subjects.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Loads the list of syllabus subjects from SharedPreferences.
  static Future<List<SyllabusSubject>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);
    if (jsonList == null || jsonList.isEmpty) {
      return _getMockSubjects();
    }
    return jsonList
        .map((str) => SyllabusSubject.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  /// Adds a new syllabus subject and returns the updated list.
  static Future<List<SyllabusSubject>> add(SyllabusSubject subject) async {
    final subjects = await load();
    subjects.add(subject);
    await save(subjects);
    return subjects;
  }

  /// Updates an existing syllabus subject and returns the updated list.
  static Future<List<SyllabusSubject>> update(SyllabusSubject subject) async {
    final subjects = await load();
    final index = subjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) {
      subjects[index] = subject;
      await save(subjects);
    }
    return subjects;
  }

  /// Deletes a syllabus subject and returns the updated list.
  static Future<List<SyllabusSubject>> delete(String id) async {
    final subjects = await load();
    subjects.removeWhere((s) => s.id == id);
    await save(subjects);
    return subjects;
  }

  /// Calculates the overall cumulative progress across all subjects.
  static double calculateOverallProgress(List<SyllabusSubject> subjects) {
    if (subjects.isEmpty) return 0.0;
    int totalUnits = 0;
    int completedUnits = 0;
    for (final sub in subjects) {
      totalUnits += sub.units.length;
      completedUnits += sub.completedUnitsCount;
    }
    if (totalUnits == 0) return 0.0;
    return (completedUnits / totalUnits) * 100;
  }

  /// Returns the mock syllabus subjects data.
  static List<SyllabusSubject> _getMockSubjects() {
    return [
      const SyllabusSubject(
        id: 'mock_sub_1',
        name: 'Analysis of Algorithms (AOA)',
        units: [
          SyllabusUnit(id: 'u1_1', name: 'Unit 1: Introduction to Algorithms', isCompleted: true),
          SyllabusUnit(id: 'u1_2', name: 'Unit 2: Divide & Conquer', isCompleted: true),
          SyllabusUnit(id: 'u1_3', name: 'Unit 3: Greedy Approach', isCompleted: false),
          SyllabusUnit(id: 'u1_4', name: 'Unit 4: Dynamic Programming', isCompleted: false),
        ],
      ),
      const SyllabusSubject(
        id: 'mock_sub_2',
        name: 'Database Management (DBMS)',
        units: [
          SyllabusUnit(id: 'u2_1', name: 'Unit 1: Entity Relationship Model', isCompleted: true),
          SyllabusUnit(id: 'u2_2', name: 'Unit 2: Relational Algebra & SQL', isCompleted: true),
          SyllabusUnit(id: 'u2_3', name: 'Unit 3: Normalization & Indexing', isCompleted: true),
          SyllabusUnit(id: 'u2_4', name: 'Unit 4: Transaction & Recovery', isCompleted: false),
        ],
      ),
      const SyllabusSubject(
        id: 'mock_sub_3',
        name: 'Operating Systems (OS)',
        units: [
          SyllabusUnit(id: 'u3_1', name: 'Unit 1: Process Management & Scheduling', isCompleted: true),
          SyllabusUnit(id: 'u3_2', name: 'Unit 2: Memory Management & Paging', isCompleted: true),
          SyllabusUnit(id: 'u3_3', name: 'Unit 3: File Systems & Storage', isCompleted: true),
          SyllabusUnit(id: 'u3_4', name: 'Unit 4: Deadlocks & Security', isCompleted: false),
        ],
      ),
      const SyllabusSubject(
        id: 'mock_sub_4',
        name: 'Computer Organisation (COA)',
        units: [
          SyllabusUnit(id: 'u4_1', name: 'Unit 1: Basic Computer Structures', isCompleted: true),
          SyllabusUnit(id: 'u4_2', name: 'Unit 2: Processor Organization', isCompleted: true),
          SyllabusUnit(id: 'u4_3', name: 'Unit 3: Memory Organization', isCompleted: false),
          SyllabusUnit(id: 'u4_4', name: 'Unit 4: Input-Output Organization', isCompleted: false),
        ],
      ),
    ];
  }
}
