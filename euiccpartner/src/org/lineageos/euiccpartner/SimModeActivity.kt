package com.android.euicc.partner

import android.app.Activity
import android.app.AlertDialog
import android.os.Bundle
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
        AlertDialog.Builder(this)
            .setTitle(R.string.sim_mode_confirm_title)
            .setMessage(warning)
            .setPositiveButton(R.string.sim_mode_switch) { _, _ ->
                SimModeController.requestMode(this, simType)
                Toast.makeText(this, R.string.sim_mode_restart, Toast.LENGTH_LONG).show()
                finish()
            }
            .setNegativeButton(android.R.string.cancel) { _, _ -> finish() }
            .setOnCancelListener { finish() }
            .show()
    }
}
