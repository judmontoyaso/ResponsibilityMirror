package com.responsibilitymirror.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Dispositivo reiniciado - se deben reprogramar las alarmas")
            
            // Iniciar la MainActivity para que Flutter reprograme las alarmas
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                putExtra("reschedule_alarms", true)
            }
            context.startActivity(launchIntent)
        }
    }
}
