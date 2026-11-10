package com.jouskaio.babel

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.UserManager
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
        if (intent.action == LOCKED_BOOT) {
            // Early (the BOOX launcher may come up long before BOOT_COMPLETED), but the launcher can
            // also come up after it and cover KOReader: BOOT_COMPLETED opens it again.
            open(context, intent.action)
            return
        }
        // Once more a few seconds later, in case the launcher comes up just after.
        open(context, intent.action)
        val pending = goAsync()
        Handler(Looper.getMainLooper()).postDelayed({
            open(context, intent.action)
            pending.finish()
        }, AGAIN_AFTER_MS)
    }

    private fun open(context: Context, action: String?) {
        val launch = BootKoreader.launchIntent(context) ?: return
        try {
            context.startActivity(launch)
        } catch (error: Exception) {
            // Too early (storage still locked) at LOCKED_BOOT_COMPLETED: BOOT_COMPLETED tries again.
            Log.w(TAG, "KOReader not opened at $action", error)
        }
    }

    companion object {
        private const val TAG = "BabelBoot"
        private const val LOCKED_BOOT = "android.intent.action.LOCKED_BOOT_COMPLETED"
        private const val AGAIN_AFTER_MS = 4000L
        private val BOOT_ACTIONS = setOf(
            LOCKED_BOOT,
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
        )
    }
}

/**
 * The reader's choice and KOReader. The choice is kept in device-protected storage: readable at
 * boot before the e-reader is unlocked, and before Flutter runs.
 */
object BootKoreader {
    private const val PREFS = "babel_boot"
    private const val KEY = "open_koreader"

    /** KOReader's packages: the Play/GitHub build and the F-Droid one. */
    private val PACKAGES = listOf("org.koreader.launcher", "org.koreader.launcher.fdroid")

    private fun prefs(context: Context): SharedPreferences {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            return context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        }
        val protected = context.createDeviceProtectedStorageContext()
        val prefs = protected.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        // Chosen with an earlier build, which kept it in the ordinary (credential) storage.
        if (!prefs.contains(KEY) && context.getSystemService(UserManager::class.java)?.isUserUnlocked == true) {
            protected.moveSharedPreferencesFrom(context, PREFS)
            return protected.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        }
        return prefs
    }

    fun isOn(context: Context): Boolean = prefs(context).getBoolean(KEY, false)

    fun setOn(context: Context, on: Boolean) {
        prefs(context).edit().putBoolean(KEY, on).apply()
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
