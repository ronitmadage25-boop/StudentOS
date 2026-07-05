import 'package:flutter/material.dart';

/// Categories automatically created for every subject.
enum LibraryCategory {
  pyqs('PYQs', Icons.description_rounded),
  notes('Notes', Icons.note_rounded),
  importantQuestions('Important Questions', Icons.star_rounded);

  const LibraryCategory(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Represents a category folder (PYQs / Notes / Important Questions) inside a subject.
class LibraryCategoryModel {
  const LibraryCategoryModel({
    required this.category,
  });

  final LibraryCategory category;

  String get id => category.name;
  String get name => category.label;
  IconData get icon => category.icon;

  Map<String, dynamic> toJson() => {'category': category.name};

  factory LibraryCategoryModel.fromJson(Map<String, dynamic> json) {
    final cat = LibraryCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => LibraryCategory.pyqs,
    );
    return LibraryCategoryModel(category: cat);
  }
}

/// Represents a subject folder inside a semester.
class LibrarySubject {
  LibrarySubject({
    required this.id,
    required this.name,
    List<LibraryCategoryModel>? categories,
  }) : categories = categories ?? _defaultCategories();

  final String id;
  final String name;
  final List<LibraryCategoryModel> categories;

  /// Creates the three default category folders for a new subject.
  static List<LibraryCategoryModel> _defaultCategories() => [
        const LibraryCategoryModel(category: LibraryCategory.pyqs),
        const LibraryCategoryModel(category: LibraryCategory.notes),
        const LibraryCategoryModel(category: LibraryCategory.importantQuestions),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'categories': categories.map((c) => c.toJson()).toList(),
      };

  factory LibrarySubject.fromJson(Map<String, dynamic> json) => LibrarySubject(
        id: json['id'] as String,
        name: json['name'] as String,
        categories: (json['categories'] as List<dynamic>)
            .map((c) => LibraryCategoryModel.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  LibrarySubject copyWith({String? name, List<LibraryCategoryModel>? categories}) => LibrarySubject(
        id: id,
        name: name ?? this.name,
        categories: categories ?? this.categories,
      );
}

/// Represents a semester folder at the root of the library.
class LibrarySemester {
  LibrarySemester({
    required this.id,
    required this.name,
    List<LibrarySubject>? subjects,
  }) : subjects = subjects ?? [];

  final String id;
  final String name;
  final List<LibrarySubject> subjects;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'subjects': subjects.map((s) => s.toJson()).toList(),
      };

  factory LibrarySemester.fromJson(Map<String, dynamic> json) => LibrarySemester(
        id: json['id'] as String,
        name: json['name'] as String,
        subjects: (json['subjects'] as List<dynamic>)
            .map((s) => LibrarySubject.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  LibrarySemester copyWith({String? name, List<LibrarySubject>? subjects}) => LibrarySemester(
        id: id,
        name: name ?? this.name,
        subjects: subjects ?? this.subjects,
      );
}
