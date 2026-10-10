import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/locale/greeting.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.brand,
                        style: BabelText.label(12, spacing: 5),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.searchTitle,
                      onPressed: () => context.go(Routes.search),
                      style: IconButton.styleFrom(
                        fixedSize: const Size(44, 44),
                        side: BorderSide(color: BabelColors.border),
                      ),
                      icon: Icon(
                        Icons.search_rounded,
                        color: BabelColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.go(Routes.profile),
                      child: ReaderAvatar(name: name, handle: handle, size: 44),
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
                const ContinueCard(),
                const KavitaProgressCard(),
                const ForYouRow(),
                const ToReadList(),
                const JourneyCard(),
                const FeedSection(),
                const BornFromReadings(),
                const MoodChips(),
                const DownloadsSection(),
                const MonthCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
