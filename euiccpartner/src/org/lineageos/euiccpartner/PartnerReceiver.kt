package com.android.euicc.partner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class PartnerReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Received partner customization request")
        EuiccMuxReceiver.requestIfSlotAbsent(context)
    }

    private companion object {
        const val TAG = "MetroidEuiccPartner"
    }
}
