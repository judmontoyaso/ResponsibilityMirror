import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 2)
class StickyNote {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String content;
  
  @HiveField(2)
  DateTime createdAt;
  
  @HiveField(3)
  NoteColor color;
  
  @HiveField(4)
  double? positionX;
  
  @HiveField(5)
  double? positionY;

  StickyNote({
    required this.id,
    required this.content,
    required this.createdAt,
    this.color = NoteColor.yellow,
    this.positionX,
    this.positionY,
  });

  StickyNote copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    NoteColor? color,
    double? positionX,
    double? positionY,
  }) {
    return StickyNote(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
    );
  }
}

@HiveType(typeId: 3)
enum NoteColor {
  @HiveField(0)
  yellow,
  
  @HiveField(1)
  pink,
  
  @HiveField(2)
  blue,
  
  @HiveField(3)
  green,
}
