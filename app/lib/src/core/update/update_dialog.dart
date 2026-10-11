import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n.dart';
import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';
import '../widgets/pill_button.dart';
import 'app_update.dart';

const _dismissedKey = 'babel.update.dismissed';

/// The build the reader said "later" to (not offered again until a newer one).
Future<int> dismissedBuild() async {
  try {
    return await SharedPreferencesAsync().getInt(_dismissedKey) ?? 0;
  } on Object {
    return 0;
  }
}

/// Where to get the update on this device; null when it cannot be done from here (the web app
/// reloads itself, other platforms wait for their store).
String? updateUrl(AppRelease release) {
  if (kIsWeb) return null;
  final file = switch (defaultTargetPlatform) {
    TargetPlatform.android => release.android,
    TargetPlatform.macOS => release.macos,
    _ => null,
  };
  return file == null ? null : siteUrl(file.url);
}

/// Whether this device can update at all (so the prompt is worth showing).
bool canUpdate(AppRelease release) => kIsWeb || updateUrl(release) != null;

/// Offers the update with what it brings; "Update" reloads the web app, or downloads the new
/// version on a phone or a Mac.
Future<void> showUpdateDialog(BuildContext context, AppRelease release) async {
  final l10n = context.l10n;
  final update = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: BabelColors.surface,
      title: Text(
        l10n.updateTitle(release.version),
        style: BabelText.heading(22),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(child: UpdateNotes(release: release)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.updateLater),
        ),
        PillButton(
          label: kIsWeb ? l10n.updateReload : l10n.updateNow,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  if (update == true) {
    await applyUpdate(release);
  } else {
    try {
      await SharedPreferencesAsync().setInt(_dismissedKey, release.build);
    } on Object {
      // not remembering only means being asked again
    }
  }
}

/// Reloads the web app, or opens the download of the new version.
Future<void> applyUpdate(AppRelease release) async {
  if (kIsWeb) {
    await launchUrl(Uri.base, webOnlyWindowName: '_self');
    return;
  }
  final url = updateUrl(release);
  if (url != null) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

/// What a release brings, as a list.
class UpdateNotes extends StatelessWidget {
  const UpdateNotes({required this.release, super.key});
  final AppRelease release;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notes = release.notesFor(
      Localizations.localeOf(context).languageCode,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.updateWhatsNew.toUpperCase(), style: BabelText.label(10)),
        const SizedBox(height: 8),
        if (notes.isEmpty)
          Text(l10n.updateNoNotes, style: BabelText.body(14))
        else
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 10),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BabelColors.gold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      note,
                      style: BabelText.body(14, color: BabelColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
