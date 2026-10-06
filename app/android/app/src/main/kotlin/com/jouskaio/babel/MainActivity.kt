package com.jouskaio.babel

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.OpenableColumns
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/**
 * Receives "Share → Babel" (links and book files) and "Open with Babel" (book files), and
 * hands them to Flutter on the `babel/share` channel as `{text: …}` or `{file: path}`.
 */
class MainActivity : AudioServiceActivity() {
    private var channel: MethodChannel? = null
    private var pending: Map<String, String>? = null
    private var flutterReady = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                if (call.method == "initial") {
                    flutterReady = true
                    result.success(pending)
                    pending = null
                } else {
                    result.notImplemented()
                }
            }
        }
        // Lets Flutter recognize e-readers (BOOX, PocketBook…) and adapt to e-ink.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "babel/device")
            .setMethodCallHandler { call, result ->
                if (call.method == "info") {
                    result.success(
                        mapOf(
                            "manufacturer" to Build.MANUFACTURER,
                            "brand" to Build.BRAND,
                            "model" to Build.MODEL,
                            "device" to Build.DEVICE,
                        ),
                    )
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // A recreated activity already handed its intent over.
        if (savedInstanceState == null) receive(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        receive(intent)
    }

    private fun receive(intent: Intent?) {
        intent ?: return
        when (intent.action) {
            Intent.ACTION_SEND -> {
                val text = intent.getStringExtra(Intent.EXTRA_TEXT)
                val stream = streamOf(intent)
                when {
                    stream != null -> copyThenDeliver(stream, intent.type)
                    !text.isNullOrBlank() -> deliver(mapOf("text" to text))
                }
            }
            Intent.ACTION_VIEW -> intent.data?.let { uri ->
                if (uri.scheme == "babel") {
                    uri.getQueryParameter("url")?.let { deliver(mapOf("text" to it)) }
                } else {
                    copyThenDeliver(uri, intent.type)
                }
            }
        }
    }

    private fun deliver(share: Map<String, String>) {
        val target = channel
        if (flutterReady && target != null) target.invokeMethod("shared", share) else pending = share
    }

    /** Copies a shared file into the app's cache (off the main thread), then delivers it. */
    private fun copyThenDeliver(uri: Uri, type: String?) {
        Thread {
            val file = runCatching { copy(uri, type) }.getOrNull()
            if (file != null) runOnUiThread { deliver(mapOf("file" to file.path)) }
        }.start()
    }

    private fun copy(uri: Uri, type: String?): File? {
        val folder = File(cacheDir, "shared").apply {
            // Only the latest shared file is kept.
            listFiles()?.forEach { it.delete() }
            mkdirs()
        }
        val file = File(folder, fileName(uri, type))
        val input = contentResolver.openInputStream(uri) ?: return null
        input.use { source -> file.outputStream().use { source.copyTo(it) } }
        return file
    }

    private fun fileName(uri: Uri, type: String?): String {
        var name = contentResolver.query(uri, arrayOf(OpenableColumns.DISPLAY_NAME), null, null, null)
            ?.use { if (it.moveToFirst()) it.getString(0) else null }
            ?: uri.lastPathSegment
            ?: "book"
        name = File(name).name.ifBlank { "book" }
        if (!name.contains('.')) EXTENSIONS[type]?.let { name = "$name.$it" }
        return name
    }

    @Suppress("DEPRECATION")
    private fun streamOf(intent: Intent): Uri? =
        if (Build.VERSION.SDK_INT >= 33) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }

    companion object {
        private const val CHANNEL = "babel/share"
        private val EXTENSIONS = mapOf(
            "application/epub+zip" to "epub",
            "application/pdf" to "pdf",
            "application/vnd.comicbook+zip" to "cbz",
            "application/x-cbz" to "cbz",
            "application/vnd.comicbook-rar" to "cbr",
            "application/x-cbr" to "cbr",
        )
    }
}
