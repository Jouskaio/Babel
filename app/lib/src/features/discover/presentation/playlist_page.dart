import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/back_leading.dart';
import '../../../core/widgets/loading_bar.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../catalog/presentation/search_page.dart' show WorkRow;
import '../application/discover_providers.dart';
import 'playlists.dart';

/// A playlist of books: the popular works of a theme, to open one's page.
class PlaylistPage extends ConsumerWidget {
  const PlaylistPage({required this.keyName, super.key});
  final String keyName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final books = ref.watch(playlistProvider(keyName));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
        leading: const BackLeading(),
        title: Text(playlistName(l10n, keyName), style: BabelText.heading(24)),
      ),
      body: books.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(24), child: LoadingBar()),
        error: (_, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.searchFailed, style: BabelText.body(15)),
        ),
        data: (works) => ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
          children: [
            Text(l10n.playlistHint, style: BabelText.body(13)),
            const SizedBox(height: 12),
            for (final work in works)
              WorkRow(
                work: work,
                onTap: () => context.push(Routes.work(work.id)),
              ),
          ],
        ),
      ),
    );
  }
}
