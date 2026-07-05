import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Represents the result of a required SGPA calculation.
class TargetCGPAResult {
  const TargetCGPAResult({
    required this.requiredSGPA,
    required this.isAchievable,
  });

  /// The SGPA needed in the next semester to hit the target.
  final double requiredSGPA;

  /// Whether the target is mathematically achievable (i.e. between 0.0 and 10.0).
  final bool isAchievable;
}

/// Service layer managing persistence, CRUD operations, and calculations for CGPA.
class CGPAService {
  CGPAService._();

  static const String _storageKey = 'studentos_cgpa_semesters';

  /// Calculates the cumulative CGPA from a list of semester models.
  ///
  /// Handles empty lists and input validation.
  static double calculateCGPA(List<SemesterModel> semesters) {
    if (semesters.isEmpty) return 0.0;

    double total = 0.0;
    int validCount = 0;

    for (final s in semesters) {
      if (s.sgpa >= 0.0 && s.sgpa <= 10.0) {
        total += s.sgpa;
        validCount++;
      }
    }

    if (validCount == 0) return 0.0;
    return total / validCount;
  }

  /// Calculates the required SGPA in the next semester to achieve a target CGPA.
  ///
  /// Formula: required = (target * (completed + 1)) - (current * completed)
  static TargetCGPAResult calculateRequiredSGPA({
    required double currentCGPA,
    required int completedSemesters,
    required double targetCGPA,
  }) {
    if (completedSemesters < 0 ||
        currentCGPA < 0.0 ||
        currentCGPA > 10.0 ||
        targetCGPA < 0.0 ||
        targetCGPA > 10.0) {
      return const TargetCGPAResult(requiredSGPA: 0.0, isAchievable: false);
    }

    final nextSemCount = completedSemesters + 1;
    final requiredSGPA = (targetCGPA * nextSemCount) - (currentCGPA * completedSemesters);

    final isAchievable = requiredSGPA >= 0.0 && requiredSGPA <= 10.0;

    return TargetCGPAResult(
      requiredSGPA: requiredSGPA,
      isAchievable: isAchievable,
    );
  }

  /// Saves the list of semester SGPA models to SharedPreferences.
  static Future<void> save(List<SemesterModel> semesters) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = semesters.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Loads the list of semester SGPA models from SharedPreferences.
  static Future<List<SemesterModel>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);
    if (jsonList == null || jsonList.isEmpty) {
      return _getMockSemesters();
    }
    return jsonList
        .map((str) => SemesterModel.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  /// Adds a new semester and returns the updated list.
  static Future<List<SemesterModel>> add(SemesterModel semester) async {
    final semesters = await load();
    semesters.add(semester);
    await save(semesters);
    return semesters;
  }

  /// Updates an existing semester and returns the updated list.
  static Future<List<SemesterModel>> update(SemesterModel semester) async {
    final semesters = await load();
    final index = semesters.indexWhere((s) => s.id == semester.id);
    if (index != -1) {
      semesters[index] = semester;
      await save(semesters);
    }
    return semesters;
  }

  /// Deletes a semester and returns the updated list.
  static Future<List<SemesterModel>> delete(String id) async {
    final semesters = await load();
    semesters.removeWhere((s) => s.id == id);
    // Maintain sequential semester numbers after deletion
    for (int i = 0; i < semesters.length; i++) {
      semesters[i] = semesters[i].copyWith(semesterNumber: i + 1);
    }
    await save(semesters);
    return semesters;
  }

  /// Default mock semesters for fresh installs.
  static List<SemesterModel> _getMockSemesters() {
    return const [
      SemesterModel(id: 'cgpa_sem_1', semesterNumber: 1, sgpa: 8.10),
      SemesterModel(id: 'cgpa_sem_2', semesterNumber: 2, sgpa: 8.40),
      SemesterModel(id: 'cgpa_sem_3', semesterNumber: 3, sgpa: 7.90),
      SemesterModel(id: 'cgpa_sem_4', semesterNumber: 4, sgpa: 8.10),
    ];
  }
}
