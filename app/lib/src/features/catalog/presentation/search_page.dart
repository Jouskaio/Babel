import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../landing/application/trending_provider.dart';
import '../application/catalog_providers.dart';

/// Search (design: Penpot "screen / recherche").
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  void _search(String value) {
    _debounce?.cancel();
    _controller.text = value;
    setState(() => _query = value.trim());
    ref.read(recentSearchesProvider.notifier).add(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
      children: [
        Text(l10n.searchTitle, style: BabelText.title(44)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                onSubmitted: _search,
                textInputAction: TextInputAction.search,
                style: BabelText.body(15, color: BabelColors.textPrimary),
                cursorColor: BabelColors.gold,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  hintStyle: BabelText.reading(
                    15,
                    color: BabelColors.textSecondary,
                    italic: true,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: BabelColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: BabelColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                    borderSide: BorderSide(color: BabelColors.border),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                    borderSide: BorderSide(color: BabelColors.gold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              tooltip: l10n.navScan,
              onPressed: () => context.push(Routes.scan),
              style: IconButton.styleFrom(
                backgroundColor: BabelColors.textPrimary,
                foregroundColor: BabelColors.canvas,
                fixedSize: const Size(52, 52),
              ),
              icon: const Icon(Icons.qr_code_scanner),
            ),
          ],
        ),
        const SizedBox(height: 28),
        if (_query.length >= 2)
          _Results(
            query: _query,
            lang: lang,
            onOpen: () => ref.read(recentSearchesProvider.notifier).add(_query),
          )
        else ...[
          _Recent(onSelect: _search),
          const _Trending(),
        ],
      ],
    );
  }
}

class _Recent extends ConsumerWidget {
  const _Recent({required this.onSelect});
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentSearchesProvider);
    if (recent.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.recentTitle, style: BabelText.title(30)),
              ),
              TextButton(
                onPressed: ref.read(recentSearchesProvider.notifier).clear,
                child: Text(
                  l10n.clear.toUpperCase(),
                  style: BabelText.label(10, spacing: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final q in recent)
                ActionChip(
                  label: Text(
                    q,
                    style: BabelText.body(13, color: BabelColors.textPrimary),
                  ),
                  backgroundColor: BabelColors.surface,
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  onPressed: () => onSelect(q),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Trending extends ConsumerWidget {
  const _Trending();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final works =
        ref.watch(trendingWorksProvider).value ??
        const <TrendingWorkResponse>[];
    if (works.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.trendingTitle, style: BabelText.title(30)),
        const SizedBox(height: 16),
        for (final (i, work) in works.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '${i + 1}',
                    style: BabelText.title(34, color: BabelColors.gold),
                  ),
                ),
                BookCover(
                  width: 56,
                  url: apiUrl(work.coverPath),
                  title: work.title,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(work.title, style: BabelText.heading(20)),
                      Text(work.authors.join(', '), style: BabelText.body(13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({
    required this.query,
    required this.lang,
    required this.onOpen,
  });
  final String query;
  final String lang;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final results = ref.watch(
      searchResultsProvider((query: query, lang: lang)),
    );
    return results.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: BabelColors.gold),
        ),
      ),
      error: (_, _) => Text(l10n.searchFailed, style: BabelText.body(15)),
      data: (works) => works.isEmpty
          ? Text(l10n.noResults(query), style: BabelText.body(15))
          : Column(
              children: [
                for (final work in works)
                  WorkRow(
                    work: work,
                    onTap: () {
                      onOpen();
                      context.push(Routes.work(work.id));
                    },
                  ),
              ],
            ),
    );
  }
}

/// A work in a list: cover, title, authors and year.
class WorkRow extends StatelessWidget {
  const WorkRow({required this.work, required this.onTap, super.key});
  final WorkSummaryResponse work;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (work.authors.isNotEmpty) work.authors.join(', '),
      if (work.firstPublishYear case final year?) '$year',
    ].join(' · ');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            BookCover(
              width: 56,
              url: work.coverPath == null ? null : apiUrl(work.coverPath!),
              title: work.title,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(work.title, style: BabelText.heading(19)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle, style: BabelText.body(13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
