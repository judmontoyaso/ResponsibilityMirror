import 'package:hive/hive.dart';

part 'notification_config.g.dart';

@HiveType(typeId: 6)
class NotificationConfig {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  String message;
  
  @HiveField(2)
  NotificationMode mode;
  
  @HiveField(3)
  List<int> hours; // Horas del día (0-23)
  
  @HiveField(4)
  bool isEnabled;
  
  @HiveField(5)
  bool isCustom; // true = mensaje del usuario, false = automático
  
  @HiveField(6)
  List<int>? minutes; // Minutos correspondientes a cada hora

  NotificationConfig({
    required this.id,
    required this.message,
    required this.mode,
    required this.hours,
    this.isEnabled = true,
    this.isCustom = false,
    this.minutes,
  });

  NotificationConfig copyWith({
    String? id,
    String? message,
    NotificationMode? mode,
    List<int>? hours,
    bool? isEnabled,
    bool? isCustom,
    List<int>? minutes,
  }) {
    return NotificationConfig(
      id: id ?? this.id,
      message: message ?? this.message,
      mode: mode ?? this.mode,
      hours: hours ?? this.hours,
      isEnabled: isEnabled ?? this.isEnabled,
      isCustom: isCustom ?? this.isCustom,
      minutes: minutes ?? this.minutes,
    );
  }
}

@HiveType(typeId: 7)
enum NotificationMode {
  @HiveField(0)
  gogginsBrutal, // Modo directo estilo Goggins
  
  @HiveField(1)
  motivationalSoft, // Motivación suave
  
  @HiveField(2)
  balanced, // Equilibrado
}
