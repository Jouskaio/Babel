import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/locale/file_size.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/back_leading.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/error_retry.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../application/library_controller.dart';

/// The community library: the books every reader shares (a fanfiction only when its reader
/// chose to), to add to one's own library without uploading anything.
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  final _books = <CommunityBookResponse>[];
  final _adding = <String>{};
  var _query = '';
  var _page = 0;
  var _hasNext = true;
  var _loading = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _more();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _more() async {
    if (_loading || !_hasNext) return;
    final query = _query;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await ref
          .read(communityApiProvider)
          .listCommunity(q: query, page: _page + 1);
      if (!mounted || query != _query) return;
      setState(() {
        _page += 1;
        _hasNext = page?.hasNext ?? false;
        _books.addAll(page?.books ?? const []);
      });
    } on ApiException {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _query = value.trim();
        _books.clear();
        _page = 0;
        _hasNext = true;
      });
      _more();
    });
  }

  Future<void> _add(CommunityBookResponse book) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _adding.add(book.sha256));
    try {
      final item = await ref
          .read(libraryApiProvider)
          .addStoredFile(book.sha256);
      if (item != null) {
        await ref.read(libraryControllerProvider.notifier).keep(item);
      }
      final at = _books.indexWhere((b) => b.sha256 == book.sha256);
      if (at >= 0 && mounted) {
        setState(() {
          final old = _books[at];
          _books[at] = CommunityBookResponse(
            sha256: old.sha256,
            title: old.title,
            authors: old.authors,
            format: old.format,
            size: old.size,
            coverPath: old.coverPath,
            inLibrary: true,
          );
        });
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.ao3Added)));
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorNetwork)));
    } finally {
      if (mounted) setState(() => _adding.remove(book.sha256));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
        leading: const BackLeading(),
        title: Text(l10n.communityTitle, style: BabelText.heading(24)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
            children: [
              Text(l10n.communityHint, style: BabelText.body(13)),
              const SizedBox(height: 14),
              TextField(
                controller: _search,
                onChanged: _onChanged,
                style: BabelText.body(15, color: BabelColors.textPrimary),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10n.searchHint,
                ),
              ),
              const SizedBox(height: 16),
              for (final book in _books)
                _Row(
                  book: book,
                  adding: _adding.contains(book.sha256),
                  onAdd: () => _add(book),
                ),
              if (_failed)
                ErrorRetry(onRetry: _more)
              else if (_loading)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: BabelColors.gold),
                  ),
                )
              else if (_books.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.communityEmpty, style: BabelText.body(15)),
                )
              else if (_hasNext)
                Center(
                  child: TextButton(
                    onPressed: _more,
                    child: Text(l10n.communityMore),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.book, required this.adding, required this.onAdd});

  final CommunityBookResponse book;
  final bool adding;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          BookCover(
            width: 56,
            url: book.coverPath == null ? null : apiUrl(book.coverPath!),
            title: book.title,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: BabelText.heading(17),
                ),
                if (book.authors.isNotEmpty)
                  Text(
                    book.authors.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BabelText.body(13),
                  ),
                Text(
                  '${book.format.toUpperCase()} · ${fileSize(context, book.size)}',
                  style: BabelText.label(10, color: BabelColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          PillButton(
            label: book.inLibrary ? l10n.communityHave : l10n.ao3Add,
            loading: adding,
            kind: book.inLibrary
                ? PillButtonKind.secondary
                : PillButtonKind.primary,
            onPressed: book.inLibrary || adding ? null : onAdd,
          ),
        ],
      ),
    );
  }
}
