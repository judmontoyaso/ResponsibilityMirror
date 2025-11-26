import 'package:hive/hive.dart';

part 'checkin.g.dart';

@HiveType(typeId: 4)
class DailyCheckIn {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  DateTime date;
  
  @HiveField(2)
  bool completed; // ¿Cumpliste tus promesas?
  
  @HiveField(3)
  String? notes; // Reflexión del día
  
  @HiveField(4)
  int goalsCompleted;
  
  @HiveField(5)
  int goalsTotal;
  
  @HiveField(6)
  CheckInMood mood;

  DailyCheckIn({
    required this.id,
    required this.date,
    required this.completed,
    this.notes,
    required this.goalsCompleted,
    required this.goalsTotal,
    this.mood = CheckInMood.neutral,
  });

  double get completionRate => 
      goalsTotal > 0 ? goalsCompleted / goalsTotal : 0.0;

  DailyCheckIn copyWith({
    String? id,
    DateTime? date,
    bool? completed,
    String? notes,
    int? goalsCompleted,
    int? goalsTotal,
    CheckInMood? mood,
  }) {
    return DailyCheckIn(
      id: id ?? this.id,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
      goalsCompleted: goalsCompleted ?? this.goalsCompleted,
      goalsTotal: goalsTotal ?? this.goalsTotal,
      mood: mood ?? this.mood,
    );
  }
}

@HiveType(typeId: 5)
enum CheckInMood {
  @HiveField(0)
  great,
  
  @HiveField(1)
  good,
  
  @HiveField(2)
  neutral,
  
  @HiveField(3)
  struggled,
  
  @HiveField(4)
  failed,
}
