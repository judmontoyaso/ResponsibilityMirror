package com.responsibilitymirror.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.responsibilitymirror.app/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val hour = call.argument<Int>("hour") ?: 0
                    val minute = call.argument<Int>("minute") ?: 0
                    val title = call.argument<String>("title") ?: "Motivación"
                    val message = call.argument<String>("message") ?: "¡Es hora de actuar!"
                    val notificationId = call.argument<Int>("notificationId") ?: 0
                    
                    val success = scheduleAlarm(hour, minute, title, message, notificationId)
                    result.success(success)
                }
                "cancelAlarm" -> {
                    val notificationId = call.argument<Int>("notificationId") ?: 0
                    cancelAlarm(notificationId)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleAlarm(hour: Int, minute: Int, title: String, message: String, notificationId: Int): Boolean {
        try {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            
            // Verificar permiso en Android 12+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (!alarmManager.canScheduleExactAlarms()) {
                    return false
                }
            }

            val intent = Intent(this, AlarmReceiver::class.java).apply {
                putExtra("title", title)
                putExtra("message", message)
                putExtra("notificationId", notificationId)
            }

            val pendingIntent = PendingIntent.getBroadcast(
                this,
                notificationId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Configurar hora de la alarma
            val calendar = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, hour)
                set(Calendar.MINUTE, minute)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
                
                // Si ya pasó, programar para mañana
                if (timeInMillis <= System.currentTimeMillis()) {
                    add(Calendar.DAY_OF_MONTH, 1)
                }
            }

            // Programar alarma exacta
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                calendar.timeInMillis,
                pendingIntent
            )

            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    private fun cancelAlarm(notificationId: Int) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            notificationId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
    }
}
