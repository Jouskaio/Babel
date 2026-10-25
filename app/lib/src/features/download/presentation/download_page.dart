import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_look.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/update/app_update.dart';
import '../../../core/update/update_dialog.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';

/// Where to get Babel on each device, with the latest version and what it brings. Public: it
/// is linked from the landing page.
class DownloadPage extends ConsumerWidget {
  const DownloadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final release = ref.watch(latestReleaseProvider).value;
    final locale = Localizations.localeOf(context).toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: BabelColors.textPrimary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.landing),
        ),
        title: Text(l10n.downloadTitle, style: BabelText.heading(24)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.downloadIntro, style: BabelText.body(15)),
                const SizedBox(height: 20),
                if (release != null) ...[
                  Text(
                    l10n.downloadLatest(
                      release.version,
                      release.released == null
                          ? ''
                          : DateFormat.yMMMMd(locale).format(release.released!),
                    ),
                    style: BabelText.heading(18),
                  ),
                  const SizedBox(height: 14),
                  UpdateNotes(release: release),
                  const SizedBox(height: 24),
                ],
                _Platform(
                  icon: Icons.android,
                  name: 'Android',
                  hint: l10n.downloadAndroidHint,
                  file: release?.android,
                  label: l10n.downloadApk,
                ),
                _Platform(
                  icon: Icons.laptop_mac,
                  name: 'macOS',
                  hint: l10n.downloadMacHint,
                  file: release?.macos,
                  label: l10n.downloadMac,
                ),
                _Platform(
                  icon: Icons.menu_book_outlined,
                  name: 'KOReader',
                  hint: l10n.downloadKoreaderCard,
                  action: PillButton(
                    label: l10n.downloadKoreaderGuide,
                    kind: PillButtonKind.secondary,
                    onPressed: () => context.push(Routes.koreaderGuide),
                  ),
                ),
                _Platform(
                  icon: Icons.phone_iphone,
                  name: 'iPhone · iPad',
                  hint: l10n.downloadIosSoon,
                ),
                _Platform(
                  icon: Icons.language,
                  name: l10n.downloadWebName,
                  hint: l10n.downloadWebHint,
                  action: PillButton(
                    label: l10n.downloadOpenWeb,
                    kind: PillButtonKind.secondary,
                    onPressed: () => context.go(Routes.landing),
                  ),
                ),
                const SizedBox(height: 8),
                Text(l10n.downloadUpdates, style: BabelText.body(13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Platform extends StatelessWidget {
  const _Platform({
    required this.icon,
    required this.name,
    required this.hint,
    this.file,
    this.label,
    this.action,
  });
  final IconData icon;
  final String name;
  final String hint;
  final ReleaseFile? file;
  final String? label;
  final Widget? action;

  /// "134 MB", "52 KB": the size a reader expects for the file.
  static String _size(int bytes) => bytes >= 1048576
      ? '${(bytes / 1048576).toStringAsFixed(bytes >= 10485760 ? 0 : 1)} MB'
      : '${(bytes / 1024).ceil()} KB';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = file == null || file!.size == 0 ? null : _size(file!.size);
    final button = file != null
        ? PillButton(
            label: size == null ? label! : '${label!} · $size',
            onPressed: () => launchUrl(
              Uri.parse(siteUrl(file!.url)),
              mode: LaunchMode.externalApplication,
            ),
          )
        : action ?? Text(l10n.downloadSoon, style: BabelText.label(10));
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: BabelText.heading(20)),
        const SizedBox(height: 2),
        Text(hint, style: BabelText.body(13)),
      ],
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BabelShape.radius(22),
        border: Border.all(color: BabelColors.border),
      ),
      // Side by side when there is room; on a phone the button goes under the text.
      child: LayoutBuilder(
        builder: (context, box) => box.maxWidth >= 560
            ? Row(
                children: [
                  Icon(icon, color: BabelColors.gold, size: 30),
                  const SizedBox(width: 16),
                  Expanded(child: text),
                  const SizedBox(width: 12),
                  button,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: BabelColors.gold, size: 30),
                      const SizedBox(width: 14),
                      Expanded(child: text),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Align(alignment: Alignment.centerLeft, child: button),
                ],
              ),
      ),
    );
  }
}
