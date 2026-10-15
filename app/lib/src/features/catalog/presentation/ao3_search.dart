import 'package:babel_api_client/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/ao3/ao3_direct.dart';
import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_look.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/error_retry.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';

const _pageSize = 20;

/// Archive of Our Own search, as its own form: tags (all or any), numbers, sorting and
/// pages. AO3 is asked only when the reader presses search, to spare it.
class Ao3SearchPanel extends ConsumerStatefulWidget {
  const Ao3SearchPanel({required this.text, super.key});

  /// The free text typed in the search field.
  final String text;

  @override
  ConsumerState<Ao3SearchPanel> createState() => _Ao3SearchPanelState();
}

class _Ao3SearchPanelState extends ConsumerState<Ao3SearchPanel> {
  final _tag = TextEditingController();
  final _fandom = TextEditingController();
  final _kudos = TextEditingController();
  final _hits = TextEditingController();
  final _words = TextEditingController();
  final _tags = <String>[];
  var _any = false;
  var _sort = 'best';
  var _descending = true;
  var _language = '';
  bool? _complete;
  var _updated = '';
  var _page = 1;
  Future<Ao3SearchResponse?>? _results;
  final _added = <String>{};
  final _adding = <String>{};

  @override
  void dispose() {
    _tag.dispose();
    _fandom.dispose();
    _kudos.dispose();
    _hits.dispose();
    _words.dispose();
    super.dispose();
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) setState(() => _tags.add(tag));
    _tag.clear();
  }

  int? _number(TextEditingController c) => int.tryParse(c.text.trim());

  /// From this device first (quick, its own address), through the server where that is not
  /// possible (a browser) or fails.
  Future<Ao3SearchResponse?> _fetch(Ao3Params q) async {
    if (!kIsWeb) {
      try {
        return await ref.read(ao3DirectProvider).search(q);
      } on ApiException catch (error) {
        if (error.code == 429) rethrow;
      }
    }
    return ref
        .read(ao3ApiProvider)
        .searchAo3(
          tags: q.tags,
          anyTag: q.anyTag,
          text: q.text,
          fandom: q.fandom,
          language: q.language,
          complete: q.complete,
          minWords: q.minWords,
          minKudos: q.minKudos,
          minHits: q.minHits,
          updatedWithin: q.updatedWithin,
          sort: q.sort,
          descending: q.descending,
          page: q.page,
        );
  }

  void _search({int page = 1}) {
    if (_tag.text.trim().isNotEmpty) _addTag(_tag.text);
    final params = Ao3Params(
      tags: List.of(_tags),
      anyTag: _any,
      text: widget.text.trim(),
      fandom: _fandom.text.trim(),
      language: _language,
      complete: _complete,
      minWords: _number(_words),
      minKudos: _number(_kudos),
      minHits: _number(_hits),
      updatedWithin: _updated,
      sort: _sort,
      descending: _descending,
      page: page,
    );
    setState(() {
      _page = page;
      _results = _fetch(params);
    });
  }

  Future<void> _add(Ao3HitResponse hit) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _adding.add(hit.workId));
    try {
      await ref.read(libraryApiProvider).importLink(LinkRequest(url: hit.url));
      if (mounted) setState(() => _added.add(hit.workId));
      messenger.showSnackBar(SnackBar(content: Text(l10n.ao3Added)));
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorNetwork)));
    } finally {
      if (mounted) setState(() => _adding.remove(hit.workId));
    }
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    double width = 130,
    bool digits = false,
  }) => SizedBox(
    width: width,
    child: TextField(
      controller: controller,
      keyboardType: digits ? TextInputType.number : TextInputType.text,
      onSubmitted: (_) => _search(),
      style: BabelText.body(14, color: BabelColors.textPrimary),
      decoration: InputDecoration(labelText: label, isDense: true),
    ),
  );

  Widget _choice<T>(
    String label,
    T value,
    List<(String, T)> options,
    ValueChanged<T> onChanged,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(), style: BabelText.label(9)),
      DropdownButton<T>(
        value: value,
        dropdownColor: BabelColors.surface,
        underline: const SizedBox.shrink(),
        style: BabelText.body(14, color: BabelColors.textPrimary),
        items: [
          for (final (text, v) in options)
            DropdownMenuItem<T>(value: v, child: Text(text)),
        ],
        onChanged: (v) {
          if (v is T) setState(() => onChanged(v));
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ao3Title, style: BabelText.heading(24)),
        const SizedBox(height: 4),
        Text(l10n.ao3Hint, style: BabelText.body(13)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tag,
                onSubmitted: _addTag,
                style: BabelText.body(14, color: BabelColors.textPrimary),
                decoration: InputDecoration(
                  labelText: l10n.ao3TagHint,
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.ao3TagAdd,
              onPressed: () => _addTag(_tag.text),
              icon: Icon(Icons.add_circle_outline, color: BabelColors.gold),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in _tags)
                InputChip(
                  label: Text(tag),
                  onDeleted: () => setState(() => _tags.remove(tag)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: false, label: Text(l10n.ao3All)),
              ButtonSegment(value: true, label: Text(l10n.ao3Any)),
            ],
            selected: {_any},
            onSelectionChanged: (v) => setState(() => _any = v.first),
          ),
        ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 14,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _field(_fandom, l10n.ao3Fandom, width: 200),
            _field(_kudos, l10n.ao3MinKudos, digits: true),
            _field(_hits, l10n.ao3MinHits, digits: true),
            _field(_words, l10n.ao3MinWords, digits: true),
            _choice<String>(l10n.ao3Language, _language, [
              (l10n.ao3Any2, ''),
              for (final code in ['en', 'fr', 'es', 'de', 'it', 'ru', 'zh'])
                (code.toUpperCase(), code),
            ], (v) => _language = v),
            _choice<bool?>(l10n.ao3Status, _complete, [
              (l10n.ao3Any2, null),
              (l10n.ao3Complete, true),
              (l10n.ao3Wip, false),
            ], (v) => _complete = v),
            _choice<String>(l10n.ao3Updated, _updated, [
              (l10n.ao3Any2, ''),
              ('1 ${l10n.ao3Week}', '1 week'),
              ('1 ${l10n.ao3Month}', '1 month'),
              ('6 ${l10n.ao3Months}', '6 months'),
              ('1 ${l10n.ao3Year}', '1 year'),
            ], (v) => _updated = v),
            _choice<String>(l10n.ao3Sort, _sort, [
              (l10n.sortBest, 'best'),
              (l10n.sortKudos, 'kudos'),
              (l10n.sortHits, 'hits'),
              (l10n.sortDate, 'date'),
              (l10n.sortCreated, 'created'),
              (l10n.sortWords, 'words'),
              (l10n.sortBookmarks, 'bookmarks'),
              (l10n.sortComments, 'comments'),
            ], (v) => _sort = v),
            IconButton(
              tooltip: _descending ? l10n.sortDesc : l10n.sortAsc,
              onPressed: () => setState(() => _descending = !_descending),
              icon: Icon(
                _descending ? Icons.arrow_downward : Icons.arrow_upward,
                color: BabelColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        PillButton(label: l10n.ao3Search, onPressed: _search),
        const SizedBox(height: 18),
        if (_results case final future?)
          FutureBuilder<Ao3SearchResponse?>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: BabelColors.gold),
                  ),
                );
              }
              final error = snapshot.error;
              if (error != null || snapshot.data == null) {
                return ErrorRetry(
                  message: switch (error) {
                    ApiException(code: 429) => l10n.ao3Limited,
                    ApiException(code: 502) => l10n.ao3Down,
                    _ => l10n.errorNetwork,
                  },
                  onRetry: () => _search(page: _page),
                );
              }
              return _Results(
                data: snapshot.data!,
                added: _added,
                adding: _adding,
                onAdd: _add,
                onPage: (page) => _search(page: page),
              );
            },
          ),
      ],
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.data,
    required this.added,
    required this.adding,
    required this.onAdd,
    required this.onPage,
  });

  final Ao3SearchResponse data;
  final Set<String> added;
  final Set<String> adding;
  final ValueChanged<Ao3HitResponse> onAdd;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = data.total == null
        ? null
        : ((data.total! + _pageSize - 1) ~/ _pageSize).clamp(1, 500);
    if (data.hits.isEmpty) {
      return Text(l10n.ao3None, style: BabelText.body(15));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.total != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${data.total} ${l10n.ao3Found}'.toUpperCase(),
              style: BabelText.label(10),
            ),
          ),
        for (final hit in data.hits)
          _HitCard(
            hit: hit,
            added: added.contains(hit.workId),
            adding: adding.contains(hit.workId),
            onAdd: () => onAdd(hit),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: l10n.ao3Previous,
              onPressed: data.page > 1 ? () => onPage(data.page - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              pages == null ? '${data.page}' : '${data.page} / $pages',
              style: BabelText.body(14, color: BabelColors.textPrimary),
            ),
            IconButton(
              tooltip: l10n.ao3Next,
              onPressed: data.hasNext ? () => onPage(data.page + 1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}

class _HitCard extends StatefulWidget {
  const _HitCard({
    required this.hit,
    required this.added,
    required this.adding,
    required this.onAdd,
  });

  final Ao3HitResponse hit;
  final bool added;
  final bool adding;
  final VoidCallback onAdd;

  @override
  State<_HitCard> createState() => _HitCardState();
}

class _HitCardState extends State<_HitCard> {
  var _open = false;

  String _n(int? v) => v == null ? '–' : '$v';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hit = widget.hit;
    final tags = [...hit.relationships, ...hit.characters, ...hit.tags];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BabelShape.radius(16),
        border: Border.all(color: BabelColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hit.title, style: BabelText.heading(19)),
          if (hit.authors.isNotEmpty)
            Text(hit.authors.join(', '), style: BabelText.body(13)),
          if (hit.fandoms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                hit.fandoms.join(' · '),
                style: BabelText.body(12, color: BabelColors.gold),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            [
              ?hit.rating,
              if (hit.complete == true) l10n.ao3Complete,
              if (hit.complete == false) l10n.ao3Wip,
              if (hit.words != null) '${hit.words} ${l10n.ao3Words}',
              ?hit.chapters,
              ?hit.language,
              ?hit.updated,
            ].join(' · '),
            style: BabelText.label(10, color: BabelColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            '♥ ${_n(hit.kudos)}   👁 ${_n(hit.hits)}   🔖 ${_n(hit.bookmarks)}   💬 ${_n(hit.comments)}',
            style: BabelText.body(12),
          ),
          if (hit.summary case final summary?) ...[
            const SizedBox(height: 8),
            Text(
              summary,
              maxLines: _open ? null : 3,
              overflow: _open ? TextOverflow.visible : TextOverflow.ellipsis,
              style: BabelText.reading(14, color: BabelColors.textPrimary),
            ),
          ],
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tag in tags.take(_open ? 40 : 6))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: BabelColors.border),
                      borderRadius: BabelShape.radius(999),
                    ),
                    child: Text(tag, style: BabelText.body(11)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PillButton(
                label: widget.added ? l10n.ao3AddedShort : l10n.ao3Add,
                loading: widget.adding,
                kind: widget.added
                    ? PillButtonKind.secondary
                    : PillButtonKind.primary,
                onPressed: widget.added || widget.adding ? null : widget.onAdd,
              ),
              TextButton(
                onPressed: () => setState(() => _open = !_open),
                child: Text(_open ? l10n.ao3Less : l10n.ao3More),
              ),
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse(hit.url),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(l10n.ao3Open),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
