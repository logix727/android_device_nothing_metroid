package com.android.euicc.partner

import android.app.Activity
import android.app.AlertDialog
import android.content.Intent
import android.os.Bundle
import android.telephony.euicc.EuiccManager
import android.widget.Toast

class SimModeActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AlertDialog.Builder(this)
            .setTitle(R.string.sim_mode_title)
            .setMessage(R.string.sim_mode_message)
            .setPositiveButton(R.string.sim_mode_physical) { _, _ ->
                confirmMode(SimModeController.SIM_TYPE_PSIM, R.string.sim_mode_physical_warning)
            }
            .setNeutralButton(R.string.sim_mode_esim) { _, _ ->
                confirmMode(SimModeController.SIM_TYPE_ESIM, R.string.sim_mode_esim_warning)
            }
            .setNegativeButton(android.R.string.cancel) { _, _ -> finish() }
            .setOnCancelListener { finish() }
            .show()
    }

    private fun confirmMode(simType: Int, warning: Int) {
        val block = SimModeController.getRequestBlock(this, simType)
        if (block != SimModeController.RequestBlock.NONE) {
            showBlocked(block)
            return
        }
        AlertDialog.Builder(this)
            .setTitle(R.string.sim_mode_confirm_title)
            .setMessage(warning)
            .setPositiveButton(R.string.sim_mode_switch) { _, _ ->
                SimModeController.requestMode(this, simType)
                Toast.makeText(this, R.string.sim_mode_request_sent, Toast.LENGTH_LONG).show()
                finish()
            }
            .setNegativeButton(android.R.string.cancel) { _, _ -> finish() }
            .setOnCancelListener { finish() }
            .show()
    }

    private fun showBlocked(block: SimModeController.RequestBlock) {
        val message = when (block) {
            SimModeController.RequestBlock.ACTIVE_ESIM -> R.string.sim_mode_blocked_active_esim
            SimModeController.RequestBlock.ACTIVE_PSIM2 -> R.string.sim_mode_blocked_active_psim
            SimModeController.RequestBlock.NOT_ADMIN,
            SimModeController.RequestBlock.USER_RESTRICTED -> R.string.sim_mode_blocked_admin
            SimModeController.RequestBlock.NONE -> error("Unexpected unblocked request")
        }
        AlertDialog.Builder(this)
            .setTitle(R.string.sim_mode_blocked_title)
            .setMessage(message)
            .setPositiveButton(android.R.string.ok) { _, _ -> finish() }
            .apply {
                if (block == SimModeController.RequestBlock.ACTIVE_ESIM) {
                    setNeutralButton(R.string.sim_mode_manage_esims) { _, _ ->
                        startActivity(Intent(EuiccManager.ACTION_MANAGE_EMBEDDED_SUBSCRIPTIONS))
                        finish()
                    }
                }
            }
            .setOnCancelListener { finish() }
            .show()
    }
}
