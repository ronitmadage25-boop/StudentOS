import '../models/library_folder_model.dart';

/// Represents a single PDF file imported into a Library category.
///
/// Stores metadata only — the actual PDF bytes remain on the device
/// at [filePath]. No cloud storage is used.
class LibraryFileModel {
  const LibraryFileModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.category,
    required this.subjectId,
    required this.subjectName,
    required this.semesterId,
    required this.createdAt,
  });

  /// Unique identifier (epoch milliseconds as String).
  final String id;

  /// Display name of the file (e.g. 'AOA_MSE_2024.pdf').
  final String fileName;

  /// Absolute path on the local filesystem returned by FilePicker.
  final String filePath;

  /// The category this file belongs to (PYQs / Notes / Important Questions).
  final LibraryCategory category;

  /// ID of the parent [LibrarySubject].
  final String subjectId;

  /// Name of the parent subject (for display in search / snackbars).
  final String subjectName;

  /// ID of the parent [LibrarySemester] (for lookup).
  final String semesterId;

  /// Timestamp when the file was imported.
  final DateTime createdAt;

  // ─── Serialisation ───────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'filePath': filePath,
        'category': category.name,
        'subjectId': subjectId,
        'subjectName': subjectName,
        'semesterId': semesterId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LibraryFileModel.fromJson(Map<String, dynamic> json) =>
      LibraryFileModel(
        id: json['id'] as String,
        fileName: json['fileName'] as String,
        filePath: json['filePath'] as String,
        category: LibraryCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => LibraryCategory.pyqs,
        ),
        subjectId: json['subjectId'] as String,
        subjectName: json['subjectName'] as String,
        semesterId: json['semesterId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  LibraryFileModel copyWith({String? fileName, String? filePath}) =>
      LibraryFileModel(
        id: id,
        fileName: fileName ?? this.fileName,
        filePath: filePath ?? this.filePath,
        category: category,
        subjectId: subjectId,
        subjectName: subjectName,
        semesterId: semesterId,
        createdAt: createdAt,
      );
}
