import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service layer managing persistence and CRUD for the Library folder system.
///
/// Hierarchy: LibrarySemester → LibrarySubject → LibraryCategoryModel → LibraryFileModel
///
/// Designed to be Firebase-migration-ready — swap SharedPreferences for
/// Firestore inside this service only; the UI requires no changes.
class LibraryService {
  LibraryService._();

  static const String _foldersKey = 'studentos_library';
  static const String _filesKey = 'studentos_library_files';

  // ─── Folder Persistence ──────────────────────────────────────────────────

  /// Saves the current list of semesters to SharedPreferences.
  static Future<void> save(List<LibrarySemester> semesters) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = semesters.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_foldersKey, jsonList);
  }

  /// Loads all semesters from SharedPreferences.
  ///
  /// Returns an empty list on first launch (clean slate, no mock data).
  static Future<List<LibrarySemester>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_foldersKey);
    if (jsonList == null || jsonList.isEmpty) return [];
    return jsonList
        .map((str) =>
            LibrarySemester.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  // ─── Semester Operations ─────────────────────────────────────────────────

  /// Creates a new semester and returns the updated list.
  ///
  /// Throws [ArgumentError] if [name] is blank.
  static Future<List<LibrarySemester>> createSemester({
    required String name,
    required List<LibrarySemester> current,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Semester name cannot be empty.');

    final semester = LibrarySemester(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: trimmed,
    );
    final updated = List<LibrarySemester>.from(current)..add(semester);
    await save(updated);
    return updated;
  }

  /// Renames an existing semester and returns the updated list.
  ///
  /// Throws [ArgumentError] if [newName] is blank.
  static Future<List<LibrarySemester>> renameSemester({
    required String semesterId,
    required String newName,
    required List<LibrarySemester> current,
  }) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) throw ArgumentError('Semester name cannot be empty.');

    final updated = current.map((s) {
      if (s.id == semesterId) return s.copyWith(name: trimmed);
      return s;
    }).toList();
    await save(updated);
    return updated;
  }

  /// Deletes a semester, its subjects, and all associated PDF files.
  static Future<List<LibrarySemester>> deleteSemester({
    required String semesterId,
    required List<LibrarySemester> current,
  }) async {
    final updated = current.where((s) => s.id != semesterId).toList();
    await save(updated);
    // Cascade-delete all PDF files belonging to this semester.
    final files = await loadFiles();
    final remainingFiles =
        files.where((f) => f.semesterId != semesterId).toList();
    await saveFiles(remainingFiles);
    return updated;
  }

  // ─── Subject Operations ──────────────────────────────────────────────────

  /// Creates a new subject inside a semester with auto-created categories.
  ///
  /// Throws [ArgumentError] if [name] is blank.
  static Future<List<LibrarySemester>> createSubject({
    required String semesterId,
    required String name,
    required List<LibrarySemester> current,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Subject name cannot be empty.');

    final subject = LibrarySubject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: trimmed,
    );

    final updated = current.map((s) {
      if (s.id == semesterId) {
        return s.copyWith(
            subjects: List<LibrarySubject>.from(s.subjects)..add(subject));
      }
      return s;
    }).toList();
    await save(updated);
    return updated;
  }

  /// Renames an existing subject. Returns the updated list.
  ///
  /// Throws [ArgumentError] if [newName] is blank.
  static Future<List<LibrarySemester>> renameSubject({
    required String semesterId,
    required String subjectId,
    required String newName,
    required List<LibrarySemester> current,
  }) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) throw ArgumentError('Subject name cannot be empty.');

    final updated = current.map((sem) {
      if (sem.id != semesterId) return sem;
      final updatedSubjects = sem.subjects.map((sub) {
        if (sub.id == subjectId) return sub.copyWith(name: trimmed);
        return sub;
      }).toList();
      return sem.copyWith(subjects: updatedSubjects);
    }).toList();
    await save(updated);
    return updated;
  }

  /// Deletes a subject, its categories, and all associated PDF files.
  static Future<List<LibrarySemester>> deleteSubject({
    required String semesterId,
    required String subjectId,
    required List<LibrarySemester> current,
  }) async {
    final updated = current.map((sem) {
      if (sem.id != semesterId) return sem;
      return sem.copyWith(
        subjects: sem.subjects.where((sub) => sub.id != subjectId).toList(),
      );
    }).toList();
    await save(updated);
    // Cascade-delete all PDF files belonging to this subject.
    final files = await loadFiles();
    final remainingFiles =
        files.where((f) => f.subjectId != subjectId).toList();
    await saveFiles(remainingFiles);
    return updated;
  }

  // ─── PDF File Persistence ─────────────────────────────────────────────────

  /// Saves all [LibraryFileModel] entries to SharedPreferences.
  static Future<void> saveFiles(List<LibraryFileModel> files) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = files.map((f) => jsonEncode(f.toJson())).toList();
    await prefs.setStringList(_filesKey, jsonList);
  }

  /// Loads all [LibraryFileModel] entries from SharedPreferences.
  static Future<List<LibraryFileModel>> loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_filesKey);
    if (jsonList == null || jsonList.isEmpty) return [];
    return jsonList
        .map((str) =>
            LibraryFileModel.fromJson(jsonDecode(str) as Map<String, dynamic>))
        .toList();
  }

  // ─── PDF File CRUD ────────────────────────────────────────────────────────

  /// Opens the system file picker filtered to PDF files only.
  ///
  /// Returns the [PlatformFile] on success, or `null` if the user cancelled.
  /// Throws [StateError] if the user picks a non-PDF file (defensive guard).
  static Future<PlatformFile?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    if (file.extension?.toLowerCase() != 'pdf') {
      throw StateError('Only PDF files are allowed.');
    }
    return file;
  }

  /// Adds a [PlatformFile] to the given category of a subject.
  ///
  /// Throws [StateError] if a file with the same name already exists in
  /// this category (duplicate guard).
  ///
  /// Returns the updated list of all files.
  static Future<List<LibraryFileModel>> addPdf({
    required PlatformFile platformFile,
    required String semesterId,
    required String subjectId,
    required String subjectName,
    required LibraryCategory category,
    required List<LibraryFileModel> current,
  }) async {
    final path = platformFile.path;
    if (path == null) throw StateError('Could not access file path.');

    // Duplicate guard — same fileName + same category + same subject
    final isDuplicate = current.any(
      (f) =>
          f.fileName == platformFile.name &&
          f.category == category &&
          f.subjectId == subjectId,
    );
    if (isDuplicate) {
      throw StateError(
          '"${platformFile.name}" already exists in this category.');
    }

    final file = LibraryFileModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: platformFile.name,
      filePath: path,
      category: category,
      subjectId: subjectId,
      subjectName: subjectName,
      semesterId: semesterId,
      createdAt: DateTime.now(),
    );

    final updated = List<LibraryFileModel>.from(current)..add(file);
    await saveFiles(updated);
    return updated;
  }

  /// Deletes a PDF file entry by [fileId] and returns the updated list.
  static Future<List<LibraryFileModel>> deletePdf({
    required String fileId,
    required List<LibraryFileModel> current,
  }) async {
    final updated = current.where((f) => f.id != fileId).toList();
    await saveFiles(updated);
    return updated;
  }

  /// Returns only the files matching the given subject + category.
  static List<LibraryFileModel> filesForCategory({
    required List<LibraryFileModel> all,
    required String subjectId,
    required LibraryCategory category,
  }) =>
      all
          .where((f) => f.subjectId == subjectId && f.category == category)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // ─── Search ──────────────────────────────────────────────────────────────

  /// Returns [LibrarySearchResult] matching [query] across semesters and subjects.
  static List<LibrarySearchResult> search({
    required String query,
    required List<LibrarySemester> semesters,
  }) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    final results = <LibrarySearchResult>[];

    for (final sem in semesters) {
      if (sem.name.toLowerCase().contains(q)) {
        results.add(LibrarySearchResult(
          type: LibrarySearchResultType.semester,
          semesterName: sem.name,
          semesterId: sem.id,
        ));
      }
      for (final sub in sem.subjects) {
        if (sub.name.toLowerCase().contains(q)) {
          results.add(LibrarySearchResult(
            type: LibrarySearchResultType.subject,
            semesterName: sem.name,
            semesterId: sem.id,
            subjectName: sub.name,
            subjectId: sub.id,
          ));
        }
      }
    }

    return results;
  }

  /// Searches PDF files by name, subject, or category.
  ///
  /// Returns matching [LibraryFileModel] entries sorted by relevance.
  /// Searches across: file name, subject name, category name.
  static List<LibraryFileModel> searchPdfs({
    required String query,
    required List<LibraryFileModel> allFiles,
  }) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    return allFiles
        .where((f) {
          final nameMatch = f.fileName.toLowerCase().contains(q);
          final subjectMatch = f.subjectName.toLowerCase().contains(q);
          final categoryMatch = f.category.label.toLowerCase().contains(q);
          return nameMatch || subjectMatch || categoryMatch;
        })
        .toList()
      ..sort((a, b) {
        // Prioritize file name matches
        final aNameMatch = a.fileName.toLowerCase().contains(q);
        final bNameMatch = b.fileName.toLowerCase().contains(q);
        if (aNameMatch && !bNameMatch) return -1;
        if (!aNameMatch && bNameMatch) return 1;
        // Then sort by date (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });
  }
}

/// Type of a search result.
enum LibrarySearchResultType { semester, subject }

/// A single search result from [LibraryService.search].
class LibrarySearchResult {
  const LibrarySearchResult({
    required this.type,
    required this.semesterName,
    required this.semesterId,
    this.subjectName,
    this.subjectId,
  });

  final LibrarySearchResultType type;
  final String semesterName;
  final String semesterId;
  final String? subjectName;
  final String? subjectId;
}
