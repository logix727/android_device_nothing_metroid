package com.android.euicc.partner

import android.content.Context
import android.content.Intent
import android.util.Log

object SimModeController {
    fun requestMode(context: Context, simType: Int) {
        require(simType == SIM_TYPE_PSIM || simType == SIM_TYPE_ESIM)
        context.sendBroadcast(Intent(SIM_TYPE_UPDATE_ACTION).apply {
            setPackage(QTI_PHONE_PACKAGE)
            putExtra(EXTRA_SLOT_ID, MUX_SLOT_ID)
            putExtra(EXTRA_SIM_TYPE, simType)
        })
        Log.i(TAG, "Requested SIM type $simType for mux slot $MUX_SLOT_ID")
    }

    private const val TAG = "MetroidEuiccPartner"
    private const val SIM_TYPE_UPDATE_ACTION = "com.android.euicc.service.SIM_TYPE_UPDATE_ACTION"
    private const val EXTRA_SLOT_ID = "com.android.euicc.service.extra_slot_id"
    private const val EXTRA_SIM_TYPE = "com.android.euicc.service.extra_sim_type"
    private const val QTI_PHONE_PACKAGE = "com.qti.phone"
    private const val MUX_SLOT_ID = 1

    const val SIM_TYPE_PSIM = 0
    const val SIM_TYPE_ESIM = 1
}
