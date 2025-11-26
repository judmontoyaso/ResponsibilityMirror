import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 0)
class Goal {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String title;
  
  @HiveField(2)
  String? description;
  
  @HiveField(3)
  bool isCompleted;
  
  @HiveField(4)
  DateTime createdAt;
  
  @HiveField(5)
  DateTime? completedAt;
  
  @HiveField(6)
  GoalType type;
  
  @HiveField(7)
  int priority; // 1-3, 3 = más importante
  
  @HiveField(8)
  List<String> steps; // Pasos para lograr la meta
  
  @HiveField(9)
  List<bool> stepsCompleted; // Estado de cada paso

  Goal({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.type = GoalType.daily,
    this.priority = 1,
    this.steps = const [],
    List<bool>? stepsCompleted,
  }) : stepsCompleted = stepsCompleted ?? List.filled(steps.length, false);

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    GoalType? type,
    int? priority,
    List<String>? steps,
    List<bool>? stepsCompleted,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      steps: steps ?? this.steps,
      stepsCompleted: stepsCompleted ?? this.stepsCompleted,
    );
  }
}

@HiveType(typeId: 1)
enum GoalType {
  @HiveField(0)
  daily,
  
  @HiveField(1)
  weekly,
  
  @HiveField(2)
  personal, // Regla personal permanente
}
