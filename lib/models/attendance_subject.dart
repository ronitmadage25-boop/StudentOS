class AttendanceSubject {
  const AttendanceSubject({
    required this.id,
    required this.name,
    required this.totalLectures,
    required this.attendedLectures,
  });

  final String id;
  final String name;
  final int totalLectures;
  final int attendedLectures;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalLectures': totalLectures,
        'attendedLectures': attendedLectures,
      };

  factory AttendanceSubject.fromJson(Map<String, dynamic> json) => AttendanceSubject(
        id: json['id'] as String,
        name: json['name'] as String,
        totalLectures: json['totalLectures'] as int,
        attendedLectures: json['attendedLectures'] as int,
      );

  AttendanceSubject copyWith({
    String? name,
    int? totalLectures,
    int? attendedLectures,
  }) =>
      AttendanceSubject(
        id: id,
        name: name ?? this.name,
        totalLectures: totalLectures ?? this.totalLectures,
        attendedLectures: attendedLectures ?? this.attendedLectures,
      );

  double get percentage {
    if (totalLectures <= 0) return 0.0;
    return (attendedLectures / totalLectures) * 100;
  }
}
