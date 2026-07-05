class ExamModel {
  const ExamModel({
    required this.id,
    required this.examName,
    required this.subjectName,
    required this.examDate,
    required this.examType,
  });

  final String id;
  final String examName;
  final String subjectName;
  final DateTime examDate;
  final String examType;

  /// Calculates the number of days remaining until the exam.
  ///
  /// Compares only the date components (ignores time) to return
  /// an accurate daily relative count.
  int get daysLeft {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(examDate.year, examDate.month, examDate.day);
    return target.difference(today).inDays;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'examName': examName,
        'subjectName': subjectName,
        'examDate': examDate.toIso8601String(),
        'examType': examType,
      };

  factory ExamModel.fromJson(Map<String, dynamic> json) => ExamModel(
        id: json['id'] as String,
        examName: json['examName'] as String,
        subjectName: json['subjectName'] as String,
        examDate: DateTime.parse(json['examDate'] as String),
        examType: json['examType'] as String,
      );

  ExamModel copyWith({
    String? examName,
    String? subjectName,
    DateTime? examDate,
    String? examType,
  }) =>
      ExamModel(
        id: id,
        examName: examName ?? this.examName,
        subjectName: subjectName ?? this.subjectName,
        examDate: examDate ?? this.examDate,
        examType: examType ?? this.examType,
      );
}
