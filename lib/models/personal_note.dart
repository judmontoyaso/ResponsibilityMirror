import 'package:hive/hive.dart';

part 'personal_note.g.dart';

@HiveType(typeId: 4)
class PersonalNote extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime createdAt;

  @HiveField(3)
  int colorIndex; // Para diferentes colores de post-it

  PersonalNote({
    required this.id,
    required this.content,
    required this.createdAt,
    this.colorIndex = 0,
  });
}
