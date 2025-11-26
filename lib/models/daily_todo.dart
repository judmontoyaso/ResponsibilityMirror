import 'package:hive/hive.dart';

part 'daily_todo.g.dart';

@HiveType(typeId: 5)
class DailyTodo extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String task;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  final DateTime createdAt;

  DailyTodo({
    required this.id,
    required this.task,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  DailyTodo copyWith({
    String? task,
    bool? isCompleted,
  }) {
    return DailyTodo(
      id: id,
      task: task ?? this.task,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }
}
