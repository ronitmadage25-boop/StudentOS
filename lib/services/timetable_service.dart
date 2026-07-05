import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service layer managing persistence, CRUD operations, and sorting of timetable entries.
class TimetableService {
  TimetableService._();

  static const String _storageKey = 'studentos_timetable';

  /// Saves the list of timetable entries to SharedPreferences.
  static Future<void> save(List<TimetableEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Loads the list of timetable entries from SharedPreferences.
  static Future<List<TimetableEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey);
    if (jsonList == null || jsonList.isEmpty) {
      return _getMockEntries();
    }
    return jsonList
        .map((str) => TimetableEntry.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  /// Adds a new entry and returns the updated list.
  static Future<List<TimetableEntry>> add(TimetableEntry entry) async {
    final entries = await load();
    entries.add(entry);
    final sorted = sort(entries);
    await save(sorted);
    return sorted;
  }

  /// Updates an existing entry and returns the updated list.
  static Future<List<TimetableEntry>> update(TimetableEntry entry) async {
    final entries = await load();
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      entries[index] = entry;
      final sorted = sort(entries);
      await save(sorted);
      return sorted;
    }
    return sort(entries);
  }

  /// Deletes an entry and returns the updated list.
  static Future<List<TimetableEntry>> delete(String id) async {
    final entries = await load();
    entries.removeWhere((e) => e.id == id);
    await save(entries);
    return sort(entries);
  }

  /// Returns sorted timetable entries: Day first, then start time.
  static List<TimetableEntry> sort(List<TimetableEntry> entries) {
    return List<TimetableEntry>.from(entries)
      ..sort((a, b) {
        final dayDiff = a.dayIndex.compareTo(b.dayIndex);
        if (dayDiff != 0) return dayDiff;
        return a.startTimeMinutes.compareTo(b.startTimeMinutes);
      });
  }

  /// Default mock entries for fresh installs.
  static List<TimetableEntry> _getMockEntries() {
    return [
      const TimetableEntry(
        id: 'mock_1',
        subjectName: 'Analysis of Algorithms (AOA)',
        day: 'Monday',
        startTime: '09:00',
        endTime: '10:00',
      ),
      const TimetableEntry(
        id: 'mock_2',
        subjectName: 'Computer Organisation (COA)',
        day: 'Monday',
        startTime: '10:15',
        endTime: '11:15',
      ),
      const TimetableEntry(
        id: 'mock_3',
        subjectName: 'Database Management (DBMS)',
        day: 'Tuesday',
        startTime: '09:00',
        endTime: '10:00',
      ),
      const TimetableEntry(
        id: 'mock_4',
        subjectName: 'Operating Systems (OS)',
        day: 'Wednesday',
        startTime: '11:30',
        endTime: '12:30',
      ),
      const TimetableEntry(
        id: 'mock_5',
        subjectName: 'Software Engineering (SE)',
        day: 'Thursday',
        startTime: '14:00',
        endTime: '15:00',
      ),
    ];
  }
}
