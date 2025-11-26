import 'package:hive/hive.dart';

part 'custom_phrase.g.dart';

@HiveType(typeId: 3)
class CustomPhrase extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  bool isActive;

  CustomPhrase({
    required this.text,
    required this.createdAt,
    this.isActive = true,
  });
}
