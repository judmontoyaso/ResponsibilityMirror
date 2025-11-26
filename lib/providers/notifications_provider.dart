import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/notification_config.dart';
import '../services/notification_service.dart';
import 'package:uuid/uuid.dart';

class NotificationsProvider extends ChangeNotifier {
  final Box _notificationsBox = Hive.box('settings');
  final NotificationService _notificationService = NotificationService();
  final _uuid = const Uuid();
  
  List<NotificationConfig> _configs = [];
  NotificationMode _currentMode = NotificationMode.balanced;
  
  List<NotificationConfig> get configs => _configs;
  NotificationMode get currentMode => _currentMode;

  NotificationsProvider() {
    loadConfigs();
  }

  void loadConfigs() {
    final data = _notificationsBox.get('notifications', defaultValue: []);
    _configs = (data as List).map((e) => NotificationConfig(
      id: e['id'],
      message: e['message'],
      mode: NotificationMode.values[e['mode']],
      hours: List<int>.from(e['hours']),
      minutes: e['minutes'] != null ? List<int>.from(e['minutes']) : null,
      isEnabled: e['isEnabled'] ?? true,
      isCustom: e['isCustom'] ?? false,
    )).toList();
    
    final mode = _notificationsBox.get('notificationMode', defaultValue: 1);
    _currentMode = NotificationMode.values[mode];
    
    notifyListeners();
  }

  Future<void> saveConfigs() async {
    await _notificationsBox.put('notifications', 
      _configs.map((c) => {
        'id': c.id,
        'message': c.message,
        'mode': c.mode.index,
        'hours': c.hours,
        'minutes': c.minutes,
        'isEnabled': c.isEnabled,
        'isCustom': c.isCustom,
      }).toList()
    );
    notifyListeners();
  }

  Future<void> addNotification(NotificationConfig config) async {
    _configs.add(config);
    await saveConfigs();
    await _scheduleNotifications();
  }

  Future<void> updateNotification(NotificationConfig config) async {
    final index = _configs.indexWhere((c) => c.id == config.id);
    if (index != -1) {
      _configs[index] = config;
      await saveConfigs();
      await _scheduleNotifications();
    }
  }

  Future<void> deleteNotification(String id) async {
    _configs.removeWhere((c) => c.id == id);
    await saveConfigs();
    await _scheduleNotifications();
  }

  Future<void> toggleNotification(String id) async {
    final index = _configs.indexWhere((c) => c.id == id);
    if (index != -1) {
      _configs[index] = _configs[index].copyWith(
        isEnabled: !_configs[index].isEnabled
      );
      await saveConfigs();
      await _scheduleNotifications();
    }
  }

  Future<void> setMode(NotificationMode mode) async {
    _currentMode = mode;
    await _notificationsBox.put('notificationMode', mode.index);
    await _scheduleNotifications();
    notifyListeners();
  }

  Future<void> _scheduleNotifications() async {
    await _notificationService.cancelAllNotifications();
    
    for (var config in _configs.where((c) => c.isEnabled)) {
      for (int i = 0; i < config.hours.length; i++) {
        final hour = config.hours[i];
        final minute = (config.minutes != null && i < config.minutes!.length) 
            ? config.minutes![i] 
            : 0;
        
        await _notificationService.scheduleNotification(
          id: config.id.hashCode + hour * 100 + minute,
          title: _getModeTitle(config.mode),
          body: config.message,
          hour: hour,
          minute: minute,
        );
      }
    }
  }

  String _getModeTitle(NotificationMode mode) {
    switch (mode) {
      case NotificationMode.gogginsBrutal:
        return '💪 Sin excusas';
      case NotificationMode.motivationalSoft:
        return '✨ Recordatorio';
      case NotificationMode.balanced:
        return '🎯 Responsibility Mirror';
    }
  }

  String createNewId() => _uuid.v4();

  // Crear notificaciones por defecto
  Future<void> initializeDefaultNotifications() async {
    if (_configs.isEmpty) {
      final defaults = [
        NotificationConfig(
          id: _uuid.v4(),
          message: "Haz lo que dijiste, no lo que sientes.",
          mode: NotificationMode.gogginsBrutal,
          hours: [7, 12, 18],
          isCustom: false,
        ),
        NotificationConfig(
          id: _uuid.v4(),
          message: "Avanza aunque sea un paso.",
          mode: NotificationMode.motivationalSoft,
          hours: [9, 15, 20],
          isCustom: false,
        ),
      ];
      
      for (var config in defaults) {
        await addNotification(config);
      }
    }
  }
}
