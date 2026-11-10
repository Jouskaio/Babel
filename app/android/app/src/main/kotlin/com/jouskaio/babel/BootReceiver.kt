package com.jouskaio.babel

import android.app.AlarmManager
import android.app.AppOpsManager
import android.app.PendingIntent
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Process
import android.os.SystemClock
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
        if (intent.action == WATCH_AGAIN) {
            // The watch again, in case BOOX killed Babel's process (it does early in the boot).
            val end = intent.getLongExtra(EXTRA_UNTIL, 0L)
            if (BootKoreader.isOn(context) && SystemClock.elapsedRealtime() < end) {
                watch(context, intent.action, end, openFirst = false)
            }
            return
        }
        if (intent.action !in BOOT_ACTIONS || !BootKoreader.isOn(context)) return
        if (BootKoreader.canSeeForeground(context)) {
            val end = SystemClock.elapsedRealtime() + WATCH_MS
            watch(context, intent.action, end, openFirst = true)
            scheduleAgain(context, end)
            return
        }
        // Without usage access Babel cannot see what is in front: open KOReader at each broadcast,
        // and once more a little later in case the BOOX launcher comes up just after.
        open(context, intent.action)
        if (intent.action == LOCKED_BOOT) return
        val pending = goAsync()
        Handler(Looper.getMainLooper()).postDelayed({
            open(context, intent.action)
            pending.finish()
        }, AGAIN_AFTER_MS)
    }

    /**
     * The BOOX launcher comes up at no fixed moment of the boot (7 to 20 s after the first
     * broadcast) and covers KOReader. So KOReader is opened at each broadcast, then for a while
     * Babel looks once a second at which app is in front and opens KOReader again only when the
     * launcher is: it is not opened again and again while already in front, and comes back within
     * a second. Each broadcast starts the watch again (the process may be new, and the launchers
     * cannot be listed before the device is unlocked).
     */
    private fun watch(context: Context, action: String?, end: Long, openFirst: Boolean) {
        val app = context.applicationContext
        Log.i(TAG, "watch from $action (already watching: $watching)")
        if (openFirst) open(app, action)
        until = maxOf(until, end)
        val pending = goAsync()
        handler.postDelayed({ pending.finish() }, end - SystemClock.elapsedRealtime())
        if (watching) return
        watching = true
        val tick = object : Runnable {
            override fun run() {
                val front = BootKoreader.foreground(app)
                val home = BootKoreader.homePackages(app)
                Log.i(TAG, "watch: front=$front home=$home")
                if (front != null && front in home) open(app, "watch")
                if (SystemClock.elapsedRealtime() < until) {
                    handler.postDelayed(this, WATCH_EVERY_MS)
                } else {
                    Log.i(TAG, "watch: done")
                    watching = false
                }
            }
        }
        handler.postDelayed(tick, WATCH_EVERY_MS)
    }

    /**
     * BOOX kills the apps it has just started a few seconds into the boot, Babel included, which
     * stops the watch before its launcher comes up. A few alarms bring Babel back to carry on.
     */
    private fun scheduleAgain(context: Context, end: Long) {
        val alarms = context.getSystemService(AlarmManager::class.java) ?: return
        val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()
        AGAIN_AT_MS.forEachIndexed { i, delay ->
            val again = Intent(context, BootReceiver::class.java)
                .setAction(WATCH_AGAIN)
                .putExtra(EXTRA_UNTIL, end)
            val operation = PendingIntent.getBroadcast(
                context, i, again, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            val at = SystemClock.elapsedRealtime() + delay
            try {
                if (exact) {
                    alarms.setExactAndAllowWhileIdle(AlarmManager.ELAPSED_REALTIME_WAKEUP, at, operation)
                } else {
                    alarms.setAndAllowWhileIdle(AlarmManager.ELAPSED_REALTIME_WAKEUP, at, operation)
                }
            } catch (error: SecurityException) {
                Log.w(TAG, "watch alarm not set", error)
            }
        }
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
        private const val AGAIN_AFTER_MS = 3000L
        private const val WATCH_EVERY_MS = 1000L
        private const val WATCH_AGAIN = "com.jouskaio.babel.BOOT_WATCH_AGAIN"
        private const val EXTRA_UNTIL = "until"
        private val AGAIN_AT_MS = listOf(4_000L, 8_000L, 14_000L, 22_000L)

        // Under the minute Android gives a boot broadcast.
        private const val WATCH_MS = 40_000L
        private val BOOT_ACTIONS = setOf(
            LOCKED_BOOT,
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON",
        )

        private val handler = Handler(Looper.getMainLooper())

        // On the main thread only.
        private var watching = false
        private var until = 0L
    }
}

/**
 * The reader's choice and KOReader. The choice is kept in device-protected storage: readable at
 * boot before the e-reader is unlocked, and before Flutter runs.
 */
object BootKoreader {
    private const val PREFS = "babel_boot"
    private const val KEY = "open_koreader"

    /** The BOOX launcher, in case it is not listed yet early in the boot. */
    private const val BOOX_HOME = "com.onyx"

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

    /** Whether Babel may see which app is in front ("Usage access"). */
    fun canSeeForeground(context: Context): Boolean {
        val ops = context.getSystemService(AppOpsManager::class.java) ?: return false
        @Suppress("DEPRECATION")
        val mode = ops.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), context.packageName)
        return mode == AppOpsManager.MODE_ALLOWED
    }

    /** Babel's "Usage access" page in the system settings. */
    fun usageSettings(context: Context): Intent =
        Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

    /** The launchers (the apps that answer the Home button). */
    fun homePackages(context: Context): Set<String> {
        val home = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_HOME)
        // Both flags: before the device is unlocked, only direct-boot apps would be listed.
        val flags = PackageManager.MATCH_DIRECT_BOOT_AWARE or PackageManager.MATCH_DIRECT_BOOT_UNAWARE
        return context.packageManager.queryIntentActivities(home, flags)
            .mapNotNull { it.activityInfo?.packageName }
            .toSet() + BOOX_HOME
    }

    /**
     * The app in front, from the activities moved to the front since boot; null when there is
     * none yet (nothing shown, or the data still locked).
     */
    fun foreground(context: Context): String? {
        val usage = context.getSystemService(UsageStatsManager::class.java) ?: return null
        val now = System.currentTimeMillis()
        val since = now - SystemClock.elapsedRealtime()
        val events = try {
            usage.queryEvents(since, now) ?: return null
        } catch (error: Exception) {
            return null
        }
        var front: String? = null
        val event = UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            @Suppress("DEPRECATION")
            if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) front = event.packageName
        }
        return front
    }

    fun state(context: Context): Map<String, Boolean> = mapOf(
        "on" to isOn(context),
        "installed" to koreaderInstalled(context),
        "allowed" to canOpenFromBackground(context),
        "watch" to canSeeForeground(context),
    )
}
