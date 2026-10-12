import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_look.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/loading_bar.dart';
import '../../../l10n.dart';
import '../application/sources_providers.dart';

/// What Archive of Our Own says about a fanfiction: summary, tags and numbers, read from its
/// page when the sheet opens.
Future<void> showFanficSheet(
  BuildContext context, {
  required String sourceId,
  required SourceEntryResponse entry,
  required String title,
  required Widget action,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: BabelColors.surface,
  builder: (_) => _FanficSheet(
    sourceId: sourceId,
    entry: entry,
    title: title,
    action: action,
  ),
);

class _FanficSheet extends ConsumerStatefulWidget {
  const _FanficSheet({
    required this.sourceId,
    required this.entry,
    required this.title,
    required this.action,
  });
  final String sourceId;
  final SourceEntryResponse entry;
  final String title;
  final Widget action;

  @override
  ConsumerState<_FanficSheet> createState() => _FanficSheetState();
}

class _FanficSheetState extends ConsumerState<_FanficSheet> {
  String? _kudos; // what happened when kudos were left: 'given' or 'already'
  bool _kudosBusy = false;
  String? _translation; // the summary in the reader's language, once asked for
  bool _translating = false;
  bool _showOriginal = false;

  String get sourceId => widget.sourceId;
  SourceEntryResponse get entry => widget.entry;
  String get title => widget.title;
  Widget get action => widget.action;

  Future<void> _leaveKudos() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _kudosBusy = true);
    try {
      final result = await ref
          .read(sourcesApiProvider)
          .leaveKudos(sourceId, entry.id);
      if (mounted) {
        setState(() => _kudos = result?.given == false ? 'already' : 'given');
      }
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.fanficKudosFailed)));
    } finally {
      if (mounted) setState(() => _kudosBusy = false);
    }
  }

  Future<void> _translate(String summary) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final language = Localizations.localeOf(context).languageCode;
    setState(() => _translating = true);
    try {
      final result = await ref
          .read(translateApiProvider)
          .translateText(TranslateRequest(text: summary, target: language));
      if (mounted && result != null) {
        setState(() {
          _translation = result.text;
          _showOriginal = false;
        });
      }
    } on ApiException {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.fanficTranslateFailed)),
      );
    } finally {
      if (mounted) setState(() => _translating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = ref.watch(
      fanficDetailsProvider((sourceId: sourceId, entryId: entry.id)),
    );
    final d = details.value;
    final stats = [
      if (d?.chapters case final chapters?) l10n.fanficChapters(chapters),
      if (d?.words case final words?) l10n.fanficWords(words),
      if (d?.kudos case final kudos?) l10n.fanficKudos(kudos),
      if (d?.hits case final hits?) l10n.fanficHits(hits),
      if (d?.comments case final comments?) l10n.fanficComments(comments),
      if (d?.bookmarks case final bookmarks?) l10n.fanficBookmarks(bookmarks),
    ].join(' · ');
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(
                  width: 70,
                  title: d?.title ?? title,
                  style: BookCoverStyle.fanfiction,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d?.title ?? title, style: BabelText.title(26)),
                      if ((d?.authors ?? entry.authors).isNotEmpty)
                        Text(
                          (d?.authors ?? entry.authors).join(', '),
                          style: BabelText.body(14),
                        ),
                      if (d?.series case final series?)
                        Text(series, style: BabelText.body(13)),
                      if (stats.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            stats,
                            style: BabelText.body(
                              12,
                              color: BabelColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (details.isLoading && d == null)
              const LoadingBar()
            else if (d == null)
              Text(l10n.fanficUnavailable, style: BabelText.body(14))
            else ...[
              _Icons(details: d),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (d.rating != null)
                    _Tag(d.rating!, color: BabelColors.gold),
                  for (final w in d.warnings) _Tag(w),
                  for (final c in d.categories) _Tag(c),
                ],
              ),
              if (d.summary case final summary?) ...[
                const SizedBox(height: 18),
                Text(
                  l10n.fanficSummary.toUpperCase(),
                  style: BabelText.label(10),
                ),
                const SizedBox(height: 6),
                Text(
                  _translation != null && !_showOriginal
                      ? _translation!
                      : summary,
                  style: BabelText.reading(15),
                ),
                const SizedBox(height: 6),
                if (_translation != null)
                  Row(
                    children: [
                      Text(
                        l10n.fanficTranslated,
                        style: BabelText.body(
                          12,
                          color: BabelColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showOriginal = !_showOriginal),
                        child: Text(
                          _showOriginal
                              ? l10n.fanficTranslate
                              : l10n.fanficOriginal,
                          style: BabelText.body(13),
                        ),
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _translating
                          ? null
                          : () => _translate(summary),
                      icon: const Icon(Icons.translate, size: 18),
                      label: Text(
                        l10n.fanficTranslate,
                        style: BabelText.body(13),
                      ),
                    ),
                  ),
              ],
              _Group(l10n.fanficFandoms, d.fandoms),
              _Group(l10n.fanficRelationships, d.relationships),
              _Group(l10n.fanficCharacters, d.characters),
              _Group(l10n.fanficTags, d.tags),
              const SizedBox(height: 14),
              Text(
                [
                  if (d.published case final p?) l10n.fanficPublished(p),
                  if (d.updated case final u?) l10n.fanficUpdated(u),
                  ?d.language,
                ].join(' · '),
                style: BabelText.body(12, color: BabelColors.textSecondary),
              ),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse('https://archiveofourown.org${entry.path}'),
                  ),
                  child: Text(l10n.fanficOnAo3, style: BabelText.body(14)),
                ),
                OutlinedButton.icon(
                  onPressed: _kudos != null || _kudosBusy ? null : _leaveKudos,
                  icon: Icon(
                    _kudos == null ? Icons.favorite_border : Icons.favorite,
                    size: 18,
                    color: BabelColors.dustyRose,
                  ),
                  label: Text(switch (_kudos) {
                    'given' => l10n.fanficKudosGiven,
                    'already' => l10n.fanficKudosAlready,
                    _ => l10n.fanficKudosAction,
                  }, style: BabelText.body(13, color: BabelColors.textPrimary)),
                ),
                action,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.title, this.tags);
  final String title;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: BabelText.label(10)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final t in tags.take(40)) _Tag(t)],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: color ?? BabelColors.border),
      borderRadius: BabelShape.radius(999),
    ),
    child: Text(
      text,
      style: BabelText.body(12, color: color ?? BabelColors.textPrimary),
    ),
  );
}

/// AO3's four little squares: rating, warnings, category, and whether the work is finished.
class _Icons extends StatelessWidget {
  const _Icons({required this.details});
  final FanficDetailsResponse details;

  static const _specific = [
    'Graphic Depictions Of Violence',
    'Major Character Death',
    'Rape/Non-Con',
    'Underage',
  ];

  (String, Color) get _rating => switch (details.rating) {
    'General Audiences' => ('G', const Color(0xFF5BA55B)),
    'Teen And Up Audiences' => ('T', const Color(0xFFD9B93A)),
    'Mature' => ('M', const Color(0xFFE08A2B)),
    'Explicit' => ('E', const Color(0xFFC0392B)),
    _ => ('?', const Color(0xFF8A8A8A)),
  };

  (String, Color) get _warnings {
    if (details.warnings.any(_specific.contains)) {
      return ('!', const Color(0xFFC0392B));
    }
    if (details.warnings.any((w) => w.startsWith('Creator Chose'))) {
      return ('?', const Color(0xFFE08A2B));
    }
    return ('✓', const Color(0xFF5BA55B));
  }

  String get _category => switch (details.categories.length) {
    0 => '·',
    1 => details.categories.first,
    _ => 'Multi',
  };

  bool? get _complete {
    final parts = details.chapters?.split('/');
    if (parts == null || parts.length != 2) return null;
    return parts[0] == parts[1];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (rating, ratingColor) = _rating;
    final (warning, warningColor) = _warnings;
    final complete = _complete;
    return Row(
      children: [
        _Square(rating, ratingColor),
        const SizedBox(width: 6),
        _Square(warning, warningColor),
        const SizedBox(width: 6),
        _Square(_category, BabelColors.gold),
        const SizedBox(width: 6),
        _Square(
          complete == null ? '·' : (complete ? '✓' : '…'),
          complete == true ? const Color(0xFF5BA55B) : const Color(0xFF8A8A8A),
        ),
        if (complete != null) ...[
          const SizedBox(width: 10),
          Text(
            complete ? l10n.fanficComplete : l10n.fanficInProgress,
            style: BabelText.body(12, color: BabelColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _Square extends StatelessWidget {
  const _Square(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: color, borderRadius: BabelShape.radius(4)),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    ),
  );
}
