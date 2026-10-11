import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/locale/greeting.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_logo.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../kavita/presentation/kavita_progress_card.dart';
import '../../social/application/social_providers.dart';
import '../../social/presentation/feed_section.dart';
import '../../social/presentation/social_widgets.dart';
import 'home_sections.dart';
import 'verify_email_banner.dart';

/// Home screen of a signed-in reader (design: Penpot "screen / accueil"): the book being read,
/// suggestions, the reading pile, the reader's path, friends, adaptations, moods, downloads and
/// the month in books.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(authControllerProvider);
    final name = session is SignedIn ? session.user.displayName : '';
    final handle = ref.watch(socialProfileProvider).value?.handle;
    // "Bonsoir," then the name, big: the greeting is cut after its first word.
    final hello = greeting(l10n, name, DateTime.now());
    final cut = hello.indexOf(' ');
    final first = cut < 0 ? hello : hello.substring(0, cut);
    final rest = cut < 0 ? '' : hello.substring(cut + 1);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, box) {
              // Two columns on a wide screen; on a tablet or phone, one column.
              final wide = box.maxWidth >= 980;
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: wide ? 1160 : 720),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: BabelBrand(
                              style: BabelText.label(12, spacing: 5),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: l10n.searchTitle,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => context.go(Routes.search),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: BabelColors.border),
                              ),
                              child: Icon(
                                Icons.search,
                                color: BabelColors.textPrimary,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => context.go(Routes.profile),
                          child: ReaderAvatar(
                            name: name,
                            handle: handle,
                            size: 44,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const VerifyEmailBanner(),
                    const SizedBox(height: 24),
                    Text(
                      first,
                      style: BabelText.reading(
                        22,
                        color: BabelColors.textSecondary,
                        italic: true,
                      ),
                    ),
                    Text(rest, style: BabelText.title(52)),
                    const SizedBox(height: 24),
                    _Columns(
                      wide: wide,
                      main: const [
                        ContinueCard(),
                        KavitaProgressCard(),
                        ForYouRow(),
                        PlaylistsRow(),
                        ToReadList(),
                      ],
                      side: const [
                        JourneyCard(),
                        Padding(
                          padding: EdgeInsets.only(bottom: 32),
                          child: FeedSection(),
                        ),
                        BornFromReadings(),
                        MoodChips(),
                        DownloadsSection(),
                        MonthCard(),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The home sections: the reader's books on the left, their path and the community on the
/// right (a third of the width); stacked when the screen is narrow.
class _Columns extends StatelessWidget {
  const _Columns({required this.wide, required this.main, required this.side});
  final bool wide;
  final List<Widget> main;
  final List<Widget> side;

  @override
  Widget build(BuildContext context) {
    if (!wide) return Column(children: [...main, ...side]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Column(children: main)),
        const SizedBox(width: 32),
        Expanded(child: Column(children: side)),
      ],
    );
  }
}
