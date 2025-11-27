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

  void _ensureDefaultNotifications() {
    // Si no hay notificaciones configuradas, agregar las por defecto (6am-9pm cada hora)
    print('🔔 Verificando notificaciones por defecto. Configs actuales: ${_configs.length}');
    
    // Verificar si ya existen notificaciones no personalizadas (por defecto)
    final hasDefaults = _configs.any((c) => !c.isCustom);
    
    if (_configs.isEmpty || !hasDefaults) {
      print('⚠️ No hay configs por defecto. Creando notificaciones por defecto...');
      final defaultHours = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21];
      
      // Limpiar notificaciones no personalizadas antiguas si existen
      _configs.removeWhere((c) => !c.isCustom);
      
      for (int hour in defaultHours) {
        _configs.add(NotificationConfig(
          id: _uuid.v4(),
          message: 'Recordatorio brutal',
          mode: NotificationMode.gogginsBrutal,
          hours: [hour],
          minutes: [0],
          isEnabled: true,
          isCustom: false,
        ));
      }
      
      print('✅ Creadas ${_configs.where((c) => !c.isCustom).length} notificaciones por defecto');
      saveConfigs();
      _scheduleAllNotifications();
      notifyListeners(); // Importante: notificar que cambió la lista
    } else {
      print('✅ Ya existen ${_configs.length} notificaciones configuradas');
      // IMPORTANTE: Reprogramar notificaciones al iniciar
      _scheduleAllNotifications();
    }
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
    
    // Solo crear defaults si es la primera vez (nunca se han guardado notificaciones)
    if (_configs.isEmpty && !_notificationsBox.containsKey('notifications_initialized')) {
      _createDefaultNotifications();
      _notificationsBox.put('notifications_initialized', true);
    } else {
      // Reprogramar notificaciones existentes
      _scheduleAllNotifications();
    }
    
    notifyListeners();
  }

  void _createDefaultNotifications() {
    print('🔔 Primera vez: Creando notificaciones por defecto...');
    final defaultHours = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21];
    
    for (int hour in defaultHours) {
      _configs.add(NotificationConfig(
        id: _uuid.v4(),
        message: 'Recordatorio brutal',
        mode: NotificationMode.gogginsBrutal,
        hours: [hour],
        minutes: [0],
        isEnabled: true,
        isCustom: false,
      ));
    }
    
    print('✅ Creadas ${_configs.length} notificaciones por defecto');
    saveConfigs();
    _scheduleAllNotifications();
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
    await _scheduleAllNotifications();
  }

  Future<void> updateNotification(NotificationConfig config) async {
    print('🔧 Actualizando notificación: ${config.id}');
    print('   Horas: ${config.hours}');
    print('   Minutos: ${config.minutes}');
    
    final index = _configs.indexWhere((c) => c.id == config.id);
    print('   Índice encontrado: $index');
    
    if (index != -1) {
      _configs[index] = config;
      print('   ✅ Configuración actualizada en lista');
      await saveConfigs();
      print('   ✅ Guardado en Hive');
      await _scheduleAllNotifications();
      print('   ✅ Notificaciones reprogramadas');
      notifyListeners();
      print('   ✅ Listeners notificados');
    } else {
      print('   ❌ No se encontró la notificación');
    }
  }

  Future<void> deleteNotification(String id) async {
    _configs.removeWhere((c) => c.id == id);
    await saveConfigs();
    await _scheduleAllNotifications();
  }

  Future<void> toggleNotification(String id) async {
    final index = _configs.indexWhere((c) => c.id == id);
    if (index != -1) {
      _configs[index] = _configs[index].copyWith(
        isEnabled: !_configs[index].isEnabled
      );
      await saveConfigs();
      await _scheduleAllNotifications();
    }
  }

  Future<void> setMode(NotificationMode mode) async {
    _currentMode = mode;
    await _notificationsBox.put('notificationMode', mode.index);
    await _scheduleAllNotifications();
    notifyListeners();
  }

  Future<void> _scheduleAllNotifications() async {
    print('🔄 Reprogramando TODAS las notificaciones...');
    print('   Total de configs: ${_configs.length}');
    print('   Configs habilitadas: ${_configs.where((c) => c.isEnabled).length}');
    
    await _notificationService.cancelAllNotifications();
    
    int totalScheduled = 0;
    for (var config in _configs.where((c) => c.isEnabled)) {
      for (int i = 0; i < config.hours.length; i++) {
        final hour = config.hours[i];
        final minute = (config.minutes != null && i < config.minutes!.length) 
            ? config.minutes![i] 
            : 0;
        
        print('   📅 Programando: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} - ${config.message}');
        
        await _notificationService.scheduleNotification(
          id: config.id.hashCode + hour * 100 + minute,
          title: _getModeTitle(config.mode),
          body: config.message,
          hour: hour,
          minute: minute,
        );
        totalScheduled++;
      }
    }
    
    print('✅ Total de notificaciones programadas: $totalScheduled');
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
}
