import 'package:hive/hive.dart';

part 'daily_habit.g.dart';

@HiveType(typeId: 8)
class DailyHabit {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final HabitType type;
  
  @HiveField(2)
  bool isCompletedToday;
  
  @HiveField(3)
  int currentStreak;
  
  @HiveField(4)
  int longestStreak;
  
  @HiveField(5)
  DateTime? lastCompletedDate;
  
  @HiveField(6)
  int totalCompletions;
  
  @HiveField(7)
  List<DateTime> completionHistory;

  DailyHabit({
    required this.id,
    required this.type,
    this.isCompletedToday = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    this.totalCompletions = 0,
    List<DateTime>? completionHistory,
  }) : completionHistory = completionHistory ?? [];

  DailyHabit copyWith({
    String? id,
    HabitType? type,
    bool? isCompletedToday,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCompletedDate,
    int? totalCompletions,
    List<DateTime>? completionHistory,
  }) {
    return DailyHabit(
      id: id ?? this.id,
      type: type ?? this.type,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      completionHistory: completionHistory ?? this.completionHistory,
    );
  }
}

@HiveType(typeId: 9)
enum HabitType {
  @HiveField(0)
  workout, // Ejercicio físico
  
  @HiveField(1)
  diet, // Alimentación saludable
  
  @HiveField(2)
  water, // Hidratación (2L+)
  
  @HiveField(3)
  noSocialMedia, // Sin redes sociales
  
  @HiveField(4)
  reading, // Lectura o estudio
  
  @HiveField(5)
  journal, // Diario o espiritualidad
  
  @HiveField(6)
  sleep, // Sueño consistente (7-8h)
}

extension HabitTypeExtension on HabitType {
  String get name {
    switch (this) {
      case HabitType.workout:
        return 'Workout';
      case HabitType.diet:
        return 'Dieta Saludable';
      case HabitType.water:
        return 'Hidratación';
      case HabitType.noSocialMedia:
        return 'Sin Redes Sociales';
      case HabitType.reading:
        return 'Lectura/Estudio';
      case HabitType.journal:
        return 'Diario/Espiritualidad';
      case HabitType.sleep:
        return 'Sueño 7-8h';
    }
  }

  String get icon {
    switch (this) {
      case HabitType.workout:
        return '💪';
      case HabitType.diet:
        return '🥗';
      case HabitType.water:
        return '💧';
      case HabitType.noSocialMedia:
        return '📵';
      case HabitType.reading:
        return '📚';
      case HabitType.journal:
        return '📝';
      case HabitType.sleep:
        return '😴';
    }
  }

  String get description {
    switch (this) {
      case HabitType.workout:
        return 'Entrena duro, sin excusas';
      case HabitType.diet:
        return 'Come como un campeón';
      case HabitType.water:
        return 'Mínimo 2 litros de agua';
      case HabitType.noSocialMedia:
        return 'Enfócate en lo que importa';
      case HabitType.reading:
        return 'Alimenta tu mente';
      case HabitType.journal:
        return 'Reflexiona y crece';
      case HabitType.sleep:
        return 'Descansa bien para dominar';
    }
  }
}
