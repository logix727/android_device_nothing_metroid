package com.android.euicc.partner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.telephony.TelephonyManager
import android.util.Log

class EuiccMuxReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        requestIfSlotAbsent(context)
    }

    companion object {
        fun requestIfSlotAbsent(context: Context) {
            val telephony = context.getSystemService(TelephonyManager::class.java)
            if (telephony.getSimState(ESIM_SLOT_ID) != TelephonyManager.SIM_STATE_ABSENT) return

            val now = SystemClock.elapsedRealtime()
            if (now - lastSwitchRequestMillis < SWITCH_REQUEST_COOLDOWN_MILLIS) return
            lastSwitchRequestMillis = now

            context.sendBroadcast(Intent(SIM_TYPE_UPDATE_ACTION).apply {
                setPackage(QTI_PHONE_PACKAGE)
                putExtra(EXTRA_SLOT_ID, ESIM_SLOT_ID)
                putExtra(EXTRA_SIM_TYPE, SIM_TYPE_ESIM)
            })
            Log.i(TAG, "Requested eSIM mode for empty slot $ESIM_SLOT_ID")
        }

        const val TAG = "MetroidEuiccPartner"
        const val SIM_TYPE_UPDATE_ACTION = "com.android.euicc.service.SIM_TYPE_UPDATE_ACTION"
        const val EXTRA_SLOT_ID = "com.android.euicc.service.extra_slot_id"
        const val EXTRA_SIM_TYPE = "com.android.euicc.service.extra_sim_type"
        const val QTI_PHONE_PACKAGE = "com.qti.phone"
        const val ESIM_SLOT_ID = 1
        const val SIM_TYPE_ESIM = 1
        const val SWITCH_REQUEST_COOLDOWN_MILLIS = 5_000L

        @Volatile
        var lastSwitchRequestMillis = 0L
    }
}
