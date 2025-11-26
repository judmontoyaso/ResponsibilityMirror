import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import '../utils/quotes.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  // Canal nativo para Android AlarmManager
  static const platform = MethodChannel('com.responsibilitymirror.app/alarm');

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@android:drawable/sym_def_app_icon');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canales de notificación
    const AndroidNotificationChannel motivationalChannel = AndroidNotificationChannel(
      'motivational_channel',
      'Motivational Notifications',
      description: 'Notificaciones motivacionales estilo David Goggins',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    const AndroidNotificationChannel checkinChannel = AndroidNotificationChannel(
      'checkin_channel',
      'Check-in Reminders',
      description: 'Recordatorios de check-in nocturno',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
        
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(motivationalChannel);
      await androidPlugin.createNotificationChannel(checkinChannel);
      
      // Solicitar permisos de notificaciones
      await androidPlugin.requestNotificationsPermission();
      
      // Solicitar permisos de alarmas exactas (Android 12+)
      final exactAlarmPermission = await androidPlugin.requestExactAlarmsPermission();
      print('🔔 Permiso de alarmas exactas: $exactAlarmPermission');
      
      if (exactAlarmPermission != true) {
        print('⚠️ ADVERTENCIA: Sin permiso de alarmas exactas. Las notificaciones pueden no funcionar.');
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Manejar tap en notificación
    // Aquí podrías navegar a una pantalla específica
  }

  Future<void> showMotivationalNotification() async {
    final quote = MotivationalQuotes.getRandomQuote('brutal');
    
    print('🔔 Intentando mostrar notificación: $quote');
    
    const androidDetails = AndroidNotificationDetails(
      'motivational_channel',
      'Motivational Notifications',
      channelDescription: 'Notificaciones motivacionales diarias',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@android:drawable/sym_def_app_icon',
      enableVibration: true,
      playSound: true,
      ticker: 'Responsibility Mirror',
      styleInformation: BigTextStyleInformation(''),
      visibility: NotificationVisibility.public,
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    try {
      await _notifications.show(
        0,
        '💪 Responsibility Mirror',
        quote,
        details,
      );
      print('✅ Notificación mostrada correctamente');
    } catch (e) {
      print('❌ Error al mostrar notificación: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    int minute = 0,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0, // segundos
      0, // milisegundos
    );

    // Si la hora ya pasó hoy, programar para mañana
    // Comparar solo hora y minutos, NO segundos
    final nowMinutes = now.hour * 60 + now.minute;
    final scheduledMinutes = hour * 60 + minute;
    
    if (scheduledMinutes < nowMinutes) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
      print('⏭️ Programando para mañana porque la hora ya pasó');
    } else if (scheduledMinutes == nowMinutes) {
      // Si es el mismo minuto, verificar si quedan al menos 10 segundos
      if (now.second > 50) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        print('⏭️ Programando para mañana porque el minuto casi termina');
      }
    }
    
    final difference = scheduledDate.difference(now);
    print('⏰ Diferencia de tiempo: ${difference.inMinutes} minutos (${difference.inSeconds} segundos)');
    
    // Usar una frase aleatoria del modo brutal
    final randomQuote = MotivationalQuotes.getRandomQuote('brutal');

    const androidDetails = AndroidNotificationDetails(
      'motivational_channel',
      'Motivational Notifications',
      channelDescription: 'Notificaciones motivacionales programadas',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      showWhen: true,
      when: null,
      usesChronometer: false,
      channelShowBadge: true,
      onlyAlertOnce: false,
      autoCancel: true,
      ongoing: false,
      visibility: NotificationVisibility.public,
      ticker: 'Nueva motivación',
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    final nowFormatted = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final scheduledFormatted = '${scheduledDate.hour.toString().padLeft(2, '0')}:${scheduledDate.minute.toString().padLeft(2, '0')}';
    
    print('🕐 Hora actual: $nowFormatted');
    print('📅 Programando notificación #$id para: $scheduledFormatted');
    print('📆 Fecha completa: ${scheduledDate.year}-${scheduledDate.month}-${scheduledDate.day} $scheduledFormatted');
    print('⏰ Segundos desde epoch: ${scheduledDate.millisecondsSinceEpoch}');
    print('⏰ Diferencia de tiempo: ${difference.inMinutes} minutos (${difference.inSeconds} segundos)');
    print('💬 Mensaje: $randomQuote');

    try {
      // NUEVO: Usar AlarmManager nativo de Android en lugar de flutter_local_notifications
      print('🔧 Usando AlarmManager nativo para programar alarma...');
      
      final result = await platform.invokeMethod('scheduleAlarm', {
        'hour': hour,
        'minute': minute,
        'title': title,
        'message': randomQuote,
        'notificationId': id,
      });
      
      if (result == true) {
        print('✅ Alarma programada exitosamente con AlarmManager nativo');
      } else {
        print('❌ Error: No se pudo programar la alarma (sin permisos?)');
      }
      
      // Verificar notificaciones pendientes
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      print('📋 Total de notificaciones pendientes: ${pendingNotifications.length}');
      for (var notif in pendingNotifications) {
        print('   - ID: ${notif.id}, Título: ${notif.title}');
      }
    } catch (e) {
      print('❌ ERROR programando notificación: $e');
      print('   Intentando con flutter_local_notifications como fallback...');
      
      // Fallback: intentar con el método original
      try {
        await _notifications.zonedSchedule(
          id,
          title,
          randomQuote,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        print('✅ Notificación programada con fallback');
      } catch (e2) {
        print('❌ ERROR en fallback: $e2');
      }
    }
  }
  
  // Método para probar notificación programada en 5 segundos
  Future<void> testScheduledNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(seconds: 5));
    
    print('⏰ PRUEBA: Programando notificación para dentro de 5 segundos');
    print('   Hora actual: ${now.hour}:${now.minute}:${now.second}');
    print('   Hora programada: ${scheduledDate.hour}:${scheduledDate.minute}:${scheduledDate.second}');
    
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Notificaciones de prueba',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
      ticker: 'Prueba de notificación',
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      await _notifications.zonedSchedule(
        999999,
        '🧪 PRUEBA',
        'Si ves esto, las notificaciones programadas SÍ funcionan',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      print('✅ Notificación de prueba programada');
    } catch (e) {
      print('❌ Error en notificación de prueba: $e');
    }
  }

  // Método nuevo para verificar permisos
  Future<bool> checkPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
        
    if (androidPlugin == null) {
      print('❌ No se pudo obtener el plugin de Android');
      return false;
    }
    
    // Verificar permiso de notificaciones
    final notifPermission = await androidPlugin.areNotificationsEnabled();
    print('🔔 Permisos de notificaciones: $notifPermission');
    
    return notifPermission ?? false;
  }

  Future<void> showCheckInReminder() async {
    final prompt = MotivationalQuotes.getCheckInPrompt();
    
    const androidDetails = AndroidNotificationDetails(
      'checkin_channel',
      'Check-in Reminders',
      channelDescription: 'Recordatorios de check-in nocturno',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@android:drawable/sym_def_app_icon',
    );
    
    const details = NotificationDetails(android: androidDetails);
    
    await _notifications.show(
      99999,
      '✅ Check-in del día',
      prompt,
      details,
    );
  }

  Future<void> scheduleCheckInReminder({int hour = 21}) async {
    await scheduleNotification(
      id: 99999,
      title: '✅ Check-in del día',
      body: MotivationalQuotes.getCheckInPrompt(),
      hour: hour,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
