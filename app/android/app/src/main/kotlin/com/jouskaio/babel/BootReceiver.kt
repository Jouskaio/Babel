package com.jouskaio.babel

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log

/**
 * "Open KOReader when the e-reader starts": when the device has booted and the reader switched
 * it on in Babel, KOReader is brought to the front.
 *
 * Since Android 10 an app may start an activity from the background only in a few cases; being
 * allowed to "display over other apps" is one, so Babel asks for it when the option is switched on.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action !in BOOT_ACTIONS || !BootKoreader.isOn(context)) return
        val launch = BootKoreader.launchIntent(context) ?: return
        try {
            context.startActivity(launch)
        } catch (error: Exception) {
            Log.w(TAG, "KOReader not opened at boot", error)
        }
    }

    companion object {
        private const val TAG = "BabelBoot"
        private val BOOT_ACTIONS = setOf(
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
        )
    }
}

/** The reader's choice (native preferences: read at boot, before Flutter runs) and KOReader. */
object BootKoreader {
    private const val PREFS = "babel_boot"
    private const val KEY = "open_koreader"

    /** KOReader's packages: the Play/GitHub build and the F-Droid one. */
    private val PACKAGES = listOf("org.koreader.launcher", "org.koreader.launcher.fdroid")

    fun isOn(context: Context): Boolean =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getBoolean(KEY, false)

    fun setOn(context: Context, on: Boolean) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putBoolean(KEY, on).apply()
    }

    fun launchIntent(context: Context): Intent? {
        val pm: PackageManager = context.packageManager
        for (name in PACKAGES) {
            val launch = pm.getLaunchIntentForPackage(name) ?: continue
            return launch.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
        }
        return null
    }

    fun koreaderInstalled(context: Context): Boolean = launchIntent(context) != null

    /** Whether Babel may open KOReader from the background (Android 10+). */
    fun canOpenFromBackground(context: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.Q || Settings.canDrawOverlays(context)

    /** Babel's "Display over other apps" page in the system settings. */
    fun overlaySettings(context: Context): Intent =
        Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:${context.packageName}"))
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

    fun state(context: Context): Map<String, Boolean> = mapOf(
        "on" to isOn(context),
        "installed" to koreaderInstalled(context),
        "allowed" to canOpenFromBackground(context),
    )
}
