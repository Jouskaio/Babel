package com.jouskaio.babel

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
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
        // LOCKED_BOOT_COMPLETED comes first (the e-reader's launcher may be up for a while before
        // BOOT_COMPLETED): open KOReader then, and only once per boot.
        if (BootKoreader.openedThisBoot(context)) return
        val launch = BootKoreader.launchIntent(context) ?: return
        try {
            context.startActivity(launch)
            BootKoreader.markOpened(context)
        } catch (error: Exception) {
            // Too early (storage still locked): BOOT_COMPLETED tries again.
            Log.w(TAG, "KOReader not opened at ${intent.action}", error)
        }
    }

    companion object {
        private const val TAG = "BabelBoot"
        private val BOOT_ACTIONS = setOf(
            "android.intent.action.LOCKED_BOOT_COMPLETED",
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
    private const val OPENED_BOOT = "opened_boot"

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

    /** This boot, told apart from the others by Android's boot count. */
    private fun bootCount(context: Context): Int =
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            -1
        } else {
            Settings.Global.getInt(context.contentResolver, Settings.Global.BOOT_COUNT, -1)
        }

    fun openedThisBoot(context: Context): Boolean {
        val count = bootCount(context)
        return count >= 0 && prefs(context).getInt(OPENED_BOOT, -2) == count
    }

    fun markOpened(context: Context) {
        prefs(context).edit().putInt(OPENED_BOOT, bootCount(context)).apply()
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
