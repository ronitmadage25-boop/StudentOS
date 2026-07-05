class TimetableEntry {
  const TimetableEntry({
    required this.id,
    required this.subjectName,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  final String id;
  final String subjectName;
  final String day; // 'Monday', 'Tuesday', etc.
  final String startTime; // 'HH:mm' format
  final String endTime; // 'HH:mm' format

  Map<String, dynamic> toJson() => {
        'id': id,
        'subjectName': subjectName,
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
      };

  factory TimetableEntry.fromJson(Map<String, dynamic> json) => TimetableEntry(
        id: json['id'] as String,
        subjectName: json['subjectName'] as String,
        day: json['day'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
      );

  TimetableEntry copyWith({
    String? subjectName,
    String? day,
    String? startTime,
    String? endTime,
  }) =>
      TimetableEntry(
        id: id,
        subjectName: subjectName ?? this.subjectName,
        day: day ?? this.day,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
      );

  /// Helper to convert Day string to sorting index.
  int get dayIndex {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days.indexOf(day);
  }

  /// Helper to convert HH:mm to minutes for time comparisons.
  int get startTimeMinutes {
    final parts = startTime.split(':');
    if (parts.length < 2) return 0;
    final hrs = int.tryParse(parts[0]) ?? 0;
    final mins = int.tryParse(parts[1]) ?? 0;
    return hrs * 60 + mins;
  }

  /// Helper to convert HH:mm to minutes for end time comparison.
  int get endTimeMinutes {
    final parts = endTime.split(':');
    if (parts.length < 2) return 0;
    final hrs = int.tryParse(parts[0]) ?? 0;
    final mins = int.tryParse(parts[1]) ?? 0;
    return hrs * 60 + mins;
  }
}
