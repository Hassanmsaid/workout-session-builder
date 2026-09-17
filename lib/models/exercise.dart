enum TargetType { reps, time }

class Exercise {
  final String id;
  String name;
  String category;
  int targetSets;
  TargetType targetType;
  bool isCompleted;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.targetSets,
    required this.targetType,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'targetSets': targetSets,
      'targetType': targetType.name,
      'isCompleted': isCompleted,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      targetSets: json['targetSets'],
      targetType: TargetType.values.firstWhere(
        (e) => e.name == json['targetType'],
        orElse: () => TargetType.reps,
      ),
      isCompleted: json['isCompleted'],
    );
  }
}
