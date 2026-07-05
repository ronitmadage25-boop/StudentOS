class SemesterModel {
  const SemesterModel({
    required this.id,
    required this.semesterNumber,
    required this.sgpa,
  });

  final String id;
  final int semesterNumber;
  final double sgpa;

  Map<String, dynamic> toJson() => {
        'id': id,
        'semesterNumber': semesterNumber,
        'sgpa': sgpa,
      };

  factory SemesterModel.fromJson(Map<String, dynamic> json) => SemesterModel(
        id: json['id'] as String,
        semesterNumber: json['semesterNumber'] as int,
        sgpa: (json['sgpa'] as num).toDouble(),
      );

  SemesterModel copyWith({
    int? semesterNumber,
    double? sgpa,
  }) =>
      SemesterModel(
        id: id,
        semesterNumber: semesterNumber ?? this.semesterNumber,
        sgpa: sgpa ?? this.sgpa,
      );
}
