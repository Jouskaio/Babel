import 'dart:async';
import 'dart:math' as math;

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
import '../../../l10n.dart';
import '../application/library_controller.dart';
import 'file_reports.dart';

/// The community library: the books every reader shares (a fanfiction only when its reader
/// chose to), to add to one's own library without uploading anything.
class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  final _books = <CommunityBookResponse>[];
  final _adding = <String>{};
  var _query = '';
  var _page = 0;
  var _hasNext = true;
  var _loading = false;
  var _failed = false;
  var _enabled = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) _more();
    });
    _more();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
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
        _enabled = page?.enabled ?? true;
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
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: CustomScrollView(
            controller: _scroll,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.communityTitle, style: BabelText.title(44)),
                      const SizedBox(height: 6),
                      Text(l10n.communityIntro, style: BabelText.body(14)),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _search,
                        onChanged: _onChanged,
                        textInputAction: TextInputAction.search,
                        style: BabelText.body(
                          16,
                          color: BabelColors.textPrimary,
                        ),
                        cursorColor: BabelColors.gold,
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          hintStyle: BabelText.reading(
                            16,
                            color: BabelColors.textSecondary,
                            italic: true,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: BabelColors.gold,
                          ),
                          filled: true,
                          fillColor: BabelColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(999),
                            ),
                            borderSide: BorderSide(color: BabelColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(999),
                            ),
                            borderSide: BorderSide(
                              color: BabelColors.gold,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    mainAxisSpacing: 22,
                    crossAxisSpacing: 18,
                    mainAxisExtent: 340,
                  ),
                  itemCount: _books.length,
                  itemBuilder: (context, i) {
                    final book = _books[i];
                    return _Card(
                      book: book,
                      adding: _adding.contains(book.sha256),
                      onAdd: () => _add(book),
                      onReport: () =>
                          reportCommunityFile(context, ref, book.sha256),
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: _failed
                      ? ErrorRetry(onRetry: _more)
                      : _loading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: BabelColors.gold,
                          ),
                        )
                      : _books.isEmpty
                      ? Text(
                          _enabled ? l10n.communityEmpty : l10n.communityOff,
                          style: BabelText.body(15),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.communityHint2,
                    style: BabelText.body(12, color: BabelColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A shared book: its cover with a round button to add it (or a tick when it is already in the
/// library), its title and author, and a discreet flag to report the file.
class _Card extends StatelessWidget {
  const _Card({
    required this.book,
    required this.adding,
    required this.onAdd,
    required this.onReport,
  });

  final CommunityBookResponse book;
  final bool adding;
  final VoidCallback onAdd;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) => Stack(
              children: [
                BookCover(
                  // As wide as the cell, unless the cell is too short for a 2:3 cover.
                  width: math.min(box.maxWidth, box.maxHeight / 1.5),
                  url: book.coverPath == null ? null : apiUrl(book.coverPath!),
                  title: book.title,
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: book.inLibrary
                      ? Tooltip(
                          message: l10n.communityHave,
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: BabelColors.canvas.withValues(
                              alpha: 0.85,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 19,
                              color: BabelColors.gold,
                            ),
                          ),
                        )
                      : Tooltip(
                          message: l10n.ao3Add,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: adding ? null : onAdd,
                            child: CircleAvatar(
                              radius: 19,
                              backgroundColor: BabelColors.gold,
                              child: adding
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: BabelColors.canvas,
                                      ),
                                    )
                                  : Icon(
                                      Icons.add,
                                      size: 22,
                                      color: BabelColors.canvas,
                                    ),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: IconButton(
                    tooltip: l10n.reportFileTitle,
                    onPressed: onReport,
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: BabelColors.canvas.withValues(
                        alpha: 0.55,
                      ),
                    ),
                    icon: Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: BabelColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: BabelText.heading(15),
        ),
        if (book.authors.isNotEmpty)
          Text(
            book.authors.join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BabelText.body(12),
          ),
        Text(
          '${book.format.toUpperCase()} · ${fileSize(context, book.size)}',
          style: BabelText.label(9, color: BabelColors.textSecondary),
        ),
      ],
    );
  }
}
