import 'package:hive/hive.dart';

part 'ai_generated_phrase.g.dart';

@HiveType(typeId: 10)
class AIGeneratedPhrase extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  bool isActive;

  @HiveField(3)
  String? relatedGoal; // Meta relacionada

  @HiveField(4)
  bool isEdited; // Si fue editada manualmente

  @HiveField(5)
  String? originalText; // Texto original antes de editar

  AIGeneratedPhrase({
    required this.text,
    required this.createdAt,
    this.isActive = true,
    this.relatedGoal,
    this.isEdited = false,
    this.originalText,
  });
}
