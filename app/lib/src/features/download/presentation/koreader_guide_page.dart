import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';

/// How to install and use the Babel plugin for KOReader. Public: linked from the download page.
class KoreaderGuidePage extends StatelessWidget {
  const KoreaderGuidePage({super.key});

  static const _plugin = 'https://github.com/Jouskaio/babel.koplugin';
  static const _store = 'https://github.com/omer-faruq/appstore.koplugin';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget step(String title, String body) => Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BabelText.heading(20)),
          const SizedBox(height: 6),
          Text(body, style: BabelText.body(14, color: BabelColors.textPrimary)),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: BabelColors.textPrimary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.download),
        ),
        title: Text(l10n.koreaderGuideTitle, style: BabelText.heading(24)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.koreaderGuideIntro, style: BabelText.body(15)),
                const SizedBox(height: 24),
                step(l10n.koreaderGuideInstallTitle, l10n.koreaderGuideInstall),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    PillButton(
                      label: l10n.koreaderGuideStoreLink,
                      kind: PillButtonKind.secondary,
                      onPressed: () => launchUrl(
                        Uri.parse(_store),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    PillButton(
                      label: l10n.koreaderGuidePluginLink,
                      kind: PillButtonKind.secondary,
                      onPressed: () => launchUrl(
                        Uri.parse(_plugin),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                step(l10n.koreaderGuideConnectTitle, l10n.koreaderGuideConnect),
                step(l10n.koreaderGuideUseTitle, l10n.koreaderGuideUse),
                step(l10n.koreaderGuideBooksTitle, l10n.koreaderGuideBooks),
                step(l10n.koreaderGuideHelpTitle, l10n.koreaderGuideHelp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
