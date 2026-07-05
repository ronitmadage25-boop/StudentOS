import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';

/// Represents the calculated attendance details and status.
class AttendanceResult {
  const AttendanceResult({
    required this.percentage,
    required this.status,
    required this.statusColor,
    required this.lecturesNeeded,
    required this.lecturesCanMiss,
  });

  /// The attendance percentage (0.0 to 100.0).
  final double percentage;

  /// The descriptive attendance status label.
  final String status;

  /// The color associated with the status.
  final Color statusColor;

  /// The number of consecutive lectures the user must attend to reach 75%.
  final int lecturesNeeded;

  /// The number of lectures the user can miss before falling below 75%.
  final int lecturesCanMiss;
}

/// Service layer managing persistence, CRUD operations, and calculations for attendance.
class AttendanceService {
  AttendanceService._();

  static const String _storageKey = 'studentos_attendance';

  /// Calculates all attendance metrics given the attended and total lectures.
  ///
  /// Handles validation, division-by-zero, and returns an [AttendanceResult].
  static AttendanceResult calculate({
    required int totalLectures,
    required int attendedLectures,
  }) {
    // 1. Validation & Safety checks
    if (totalLectures <= 0 || attendedLectures < 0 || attendedLectures > totalLectures) {
      return const AttendanceResult(
        percentage: 0.0,
        status: 'Invalid Inputs',
        statusColor: AppColors.textTertiary,
        lecturesNeeded: 0,
        lecturesCanMiss: 0,
      );
    }

    // 2. Attendance percentage calculation
    final percentage = (attendedLectures / totalLectures) * 100;

    // 3. Status determination & Color mapping
    final String status;
    final Color statusColor;
    if (percentage >= 75.0) {
      status = 'Excellent';
      statusColor = AppColors.success;
    } else if (percentage >= 60.0) {
      status = 'Warning';
      statusColor = AppColors.warning;
    } else {
      status = 'Critical';
      statusColor = AppColors.error;
    }

    // 4. Calculate lectures needed to reach 75%
    int lecturesNeeded = 0;
    if (percentage < 75.0) {
      // Formula: (attended + x) / (total + x) >= 0.75
      // attended + x >= 0.75 * total + 0.75 * x
      // 0.25 * x >= 0.75 * total - attended
      // x >= (0.75 * total - attended) / 0.25
      lecturesNeeded = ((0.75 * totalLectures - attendedLectures) / 0.25).ceil();
      if (lecturesNeeded < 0) lecturesNeeded = 0;
    }

    // 5. Calculate lectures can be missed to stay at/above 75%
    int lecturesCanMiss = 0;
    if (percentage >= 75.0) {
      // Formula: attended / (total + x) >= 0.75
      // attended >= 0.75 * total + 0.75 * x
      // 0.75 * x <= attended - 0.75 * total
      // x <= (attended - 0.75 * total) / 0.75
      lecturesCanMiss = ((attendedLectures - 0.75 * totalLectures) / 0.75).floor();
      if (lecturesCanMiss < 0) lecturesCanMiss = 0;
    }

    return AttendanceResult(
      percentage: percentage,
      status: status,
      statusColor: statusColor,
      lecturesNeeded: lecturesNeeded,
      lecturesCanMiss: lecturesCanMiss,
    );
  }

  /// Saves the list of attendance subjects to SharedPreferences.
  static Future<void> save(List<AttendanceSubject> subjects) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = subjects.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Loads the list of attendance subjects from SharedPreferences.
  static Future<List<AttendanceSubject>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);
    if (jsonList == null || jsonList.isEmpty) {
      return _getMockSubjects();
    }
    return jsonList
        .map((str) => AttendanceSubject.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  /// Adds a new attendance subject and returns the updated list.
  static Future<List<AttendanceSubject>> add(AttendanceSubject subject) async {
    final subjects = await load();
    subjects.add(subject);
    await save(subjects);
    return subjects;
  }

  /// Updates an existing attendance subject and returns the updated list.
  static Future<List<AttendanceSubject>> update(AttendanceSubject subject) async {
    final subjects = await load();
    final index = subjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) {
      subjects[index] = subject;
      await save(subjects);
    }
    return subjects;
  }

  /// Deletes an attendance subject and returns the updated list.
  static Future<List<AttendanceSubject>> delete(String id) async {
    final subjects = await load();
    subjects.removeWhere((s) => s.id == id);
    await save(subjects);
    return subjects;
  }

  /// Calculates overall attendance stats across a list of subjects.
  static AttendanceResult calculateOverall(List<AttendanceSubject> subjects) {
    if (subjects.isEmpty) {
      return const AttendanceResult(
        percentage: 0.0,
        status: 'No Subjects',
        statusColor: AppColors.textTertiary,
        lecturesNeeded: 0,
        lecturesCanMiss: 0,
      );
    }

    int total = 0;
    int attended = 0;
    for (final s in subjects) {
      total += s.totalLectures;
      attended += s.attendedLectures;
    }

    return calculate(totalLectures: total, attendedLectures: attended);
  }

  /// Default mock subjects for fresh installs.
  static List<AttendanceSubject> _getMockSubjects() {
    return const [
      AttendanceSubject(
        id: 'att_1',
        name: 'Analysis of Algorithms (AOA)',
        totalLectures: 30,
        attendedLectures: 26,
      ),
      AttendanceSubject(
        id: 'att_2',
        name: 'Computer Organisation (COA)',
        totalLectures: 28,
        attendedLectures: 22,
      ),
      AttendanceSubject(
        id: 'att_3',
        name: 'Database Management (DBMS)',
        totalLectures: 32,
        attendedLectures: 28,
      ),
      AttendanceSubject(
        id: 'att_4',
        name: 'Operating Systems (OS)',
        totalLectures: 26,
        attendedLectures: 14,
      ),
    ];
  }
}
