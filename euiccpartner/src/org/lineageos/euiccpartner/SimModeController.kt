package com.android.euicc.partner

import android.content.Context
import android.content.Intent
import android.os.UserManager
import android.telephony.SubscriptionManager
import android.util.Log

object SimModeController {
    enum class RequestBlock {
        NONE,
        NOT_ADMIN,
        USER_RESTRICTED,
        ACTIVE_ESIM,
        ACTIVE_PSIM2,
    }

    fun getRequestBlock(context: Context, simType: Int): RequestBlock {
        require(simType == SIM_TYPE_PSIM || simType == SIM_TYPE_ESIM)
        val userManager = context.getSystemService(UserManager::class.java)
        if (!userManager.isAdminUser) return RequestBlock.NOT_ADMIN
        if (userManager.hasUserRestriction(UserManager.DISALLOW_CONFIG_MOBILE_NETWORKS)) {
            return RequestBlock.USER_RESTRICTED
        }

        val subscriptions = context.getSystemService(SubscriptionManager::class.java)
            .activeSubscriptionInfoList.orEmpty()
            .filter { it.simSlotIndex == MUX_SLOT_ID }
        if (simType == SIM_TYPE_PSIM && subscriptions.any { it.isEmbedded }) {
            return RequestBlock.ACTIVE_ESIM
        }
        if (simType == SIM_TYPE_ESIM && subscriptions.any { !it.isEmbedded }) {
            return RequestBlock.ACTIVE_PSIM2
        }
        return RequestBlock.NONE
    }

    fun requestMode(context: Context, simType: Int) {
        require(simType == SIM_TYPE_PSIM || simType == SIM_TYPE_ESIM)
        check(getRequestBlock(context, simType) == RequestBlock.NONE)
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
