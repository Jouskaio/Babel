import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../library/application/library_controller.dart';
import '../application/audiobooks_providers.dart';

/// The reader's Audiobookshelf: its libraries, searched, and audiobooks to add.
class AudiobooksPage extends ConsumerStatefulWidget {
  const AudiobooksPage({super.key});

  @override
  ConsumerState<AudiobooksPage> createState() => _AudiobooksPageState();
}

class _AudiobooksPageState extends ConsumerState<AudiobooksPage> {
  final _search = TextEditingController();
  String? _library;
  String _query = '';
  final _adding = <String>{};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _add(AbsBookResponse book) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _adding.add(book.id));
    try {
      final item = await ref.read(audiobooksApiProvider).addAudiobook(book.id);
      if (item != null) {
        await ref.read(libraryControllerProvider.notifier).keep(item);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.audiobookAdded(item.title))),
        );
      }
      ref.invalidate(audiobooksProvider);
    } on ApiException catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            error.innerException != null
                ? l10n.errorNetwork
                : l10n.errorGeneric,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _adding.remove(book.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final link = ref.watch(audiobookshelfProvider).value;
    final libraries = ref.watch(audiobookLibrariesProvider);
    final library = _library ?? libraries.value?.firstOrNull?.id;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
            children: [
              Text(l10n.audiobooksTitle, style: BabelText.title(40)),
              const SizedBox(height: 16),
              if (link == null || link.expired)
                Text(l10n.audiobooksNotLinked, style: BabelText.body(15))
              else ...[
                if ((libraries.value?.length ?? 0) > 1)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final lib in libraries.value!)
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: InkWell(
                              onTap: () => setState(() => _library = lib.id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: lib.id == library
                                          ? BabelColors.gold
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  lib.name,
                                  style: BabelText.body(
                                    14,
                                    color: lib.id == library
                                        ? BabelColors.textPrimary
                                        : BabelColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  style: BabelText.body(15, color: BabelColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: l10n.audiobooksSearch,
                    prefixIcon: Icon(
                      Icons.search,
                      color: BabelColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: BabelColors.surface,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (v) => setState(() => _query = v.trim()),
                ),
                const SizedBox(height: 16),
                if (library == null)
                  if (libraries.isLoading)
                    Center(
                      child: CircularProgressIndicator(color: BabelColors.gold),
                    )
                  else
                    Text(l10n.audiobooksEmpty, style: BabelText.body(15))
                else
                  ...ref
                      .watch(
                        audiobooksProvider((library: library, query: _query)),
                      )
                      .when(
                        loading: () => [
                          Center(
                            child: CircularProgressIndicator(
                              color: BabelColors.gold,
                            ),
                          ),
                        ],
                        error: (_, _) => [
                          Text(l10n.errorNetwork, style: BabelText.body(15)),
                        ],
                        data: (books) => books.isEmpty
                            ? [
                                Text(
                                  l10n.audiobooksEmpty,
                                  style: BabelText.body(15),
                                ),
                              ]
                            : [
                                for (final book in books)
                                  _BookRow(
                                    book: book,
                                    adding: _adding.contains(book.id),
                                    onAdd: () => _add(book),
                                  ),
                              ],
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BookRow extends StatelessWidget {
  const _BookRow({
    required this.book,
    required this.adding,
    required this.onAdd,
  });

  final AbsBookResponse book;
  final bool adding;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final details = [
      if (book.authors.isNotEmpty) book.authors.join(', '),
      if (book.narrators.isNotEmpty) l10n.narratedBy(book.narrators.join(', ')),
      duration(book.duration.toDouble()),
    ].join(' · ');
    final itemId = book.itemId;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: BabelColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: BabelColors.border),
            ),
            child: Icon(Icons.headphones, color: BabelColors.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: BabelText.heading(18)),
                if (book.series case final series?)
                  Text(series, style: BabelText.label(9)),
                Text(details, style: BabelText.body(13)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (itemId != null)
            TextButton(
              onPressed: () => context.push(Routes.read(itemId)),
              child: Text(
                l10n.listen.toUpperCase(),
                style: BabelText.label(10),
              ),
            )
          else
            OutlinedButton(
              onPressed: adding ? null : onAdd,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: BabelColors.gold),
                shape: const StadiumBorder(),
              ),
              child: Text(
                l10n.audiobookAdd,
                style: BabelText.body(13, color: BabelColors.gold),
              ),
            ),
        ],
      ),
    );
  }
}
