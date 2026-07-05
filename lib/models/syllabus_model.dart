class SyllabusUnit {
  const SyllabusUnit({
    required this.id,
    required this.name,
    required this.isCompleted,
  });

  final String id;
  final String name;
  final bool isCompleted;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isCompleted': isCompleted,
      };

  factory SyllabusUnit.fromJson(Map<String, dynamic> json) => SyllabusUnit(
        id: json['id'] as String,
        name: json['name'] as String,
        isCompleted: json['isCompleted'] as bool,
      );

  SyllabusUnit copyWith({
    String? name,
    bool? isCompleted,
  }) =>
      SyllabusUnit(
        id: id,
        name: name ?? this.name,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

class SyllabusSubject {
  const SyllabusSubject({
    required this.id,
    required this.name,
    required this.units,
  });

  final String id;
  final String name;
  final List<SyllabusUnit> units;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'units': units.map((u) => u.toJson()).toList(),
      };

  factory SyllabusSubject.fromJson(Map<String, dynamic> json) {
    final list = json['units'] as List<dynamic>;
    final units = list
        .map((u) => SyllabusUnit.fromJson(u as Map<String, dynamic>))
        .toList();
    return SyllabusSubject(
      id: json['id'] as String,
      name: json['name'] as String,
      units: units,
    );
  }

  SyllabusSubject copyWith({
    String? name,
    List<SyllabusUnit>? units,
  }) =>
      SyllabusSubject(
        id: id,
        name: name ?? this.name,
        units: units ?? this.units,
      );

  /// Computes completion progress percentage.
  double get progressPercentage {
    if (units.isEmpty) return 0.0;
    final completedCount = units.where((u) => u.isCompleted).length;
    return (completedCount / units.length) * 100;
  }

  int get completedUnitsCount => units.where((u) => u.isCompleted).length;
}
