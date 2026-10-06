import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/relative_time.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../sources/presentation/source_badge.dart';
import '../application/social_providers.dart';
import 'safety.dart';
import 'social_widgets.dart';

/// Another reader's page: only what they share with you.
class ReaderProfilePage extends ConsumerWidget {
  const ReaderProfilePage({required this.handle, super.key});
  final String handle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final page = ref.watch(readerPageProvider(handle));
    return Scaffold(
      appBar: sourcesAppBar(
        atHandle(handle),
        actions: [
          if (page case AsyncData(:final value))
            ReaderSafetyMenu(handle: handle, name: value.reader.displayName),
        ],
      ),
      body: switch (page) {
        AsyncData(:final value) => _Page(page: value, handle: handle),
        AsyncError(:final error) => Center(
          child: Text(
            error is ApiException && error.code == 404
                ? l10n.readerNotFoundSocial
                : l10n.errorNetwork,
            style: BabelText.body(15),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Page extends ConsumerWidget {
  const _Page({required this.page, required this.handle});
  final ReaderPageResponse page;
  final String handle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reader = page.reader;
    return RefreshIndicator(
      color: BabelColors.gold,
      onRefresh: () async => ref.invalidate(readerPageProvider(handle)),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Center(
            child: ReaderAvatar(
              name: reader.displayName,
              handle: reader.handle,
              size: 88,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            reader.displayName,
            textAlign: TextAlign.center,
            style: BabelText.title(36),
          ),
          Text(
            [
              atHandle(reader.handle),
              if (reader.relation.followsYou) l10n.followsYou,
            ].join(' · ').toUpperCase(),
            textAlign: TextAlign.center,
            style: BabelText.label(9, color: BabelColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Center(
            child: RelationButtons(
              reader: reader,
              onChanged: (_) => ref.invalidate(readerPageProvider(handle)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (page.books != null) _Count(page.books!, l10n.statBooks),
              _Count(page.friends, l10n.statFriends),
              _Count(page.followers, l10n.statFollowers),
            ],
          ),
          if (page.reading.isNotEmpty) ...[
            _Title(l10n.readingNow),
            for (final book in page.reading)
              _Line(
                title: book.title,
                detail:
                    '${book.authors.join(', ')} · ${book.percent.round()} %',
              ),
          ],
          if (page.finished.isNotEmpty) ...[
            _Title(l10n.profileFinished),
            for (final book in page.finished)
              _Line(
                title: book.title,
                detail: [
                  book.authors.join(', '),
                  timeAgo(context, book.at),
                ].where((t) => t.isNotEmpty).join(' · '),
              ),
          ],
          for (final shelf in page.shelves) ...[
            _Title(shelf.name),
            if (shelf.books.isEmpty)
              Text(l10n.shelfEmpty, style: BabelText.body(13)),
            for (final book in shelf.books)
              _Line(title: book.title, detail: book.authors.join(', ')),
          ],
          if (page.reviews.isNotEmpty) ...[
            _Title(l10n.reviewsTitle),
            for (final review in page.reviews)
              _Line(
                title: review.title,
                detail: [
                  stars(review.rating),
                  ?review.text,
                ].where((t) => t.isNotEmpty).join(' · '),
              ),
          ],
          if (page.notes.isNotEmpty) ...[
            _Title(l10n.sharedNotes),
            for (final note in page.notes)
              _Line(
                title: note.quote.isNotEmpty
                    ? '« ${note.quote} »'
                    : l10n.comicPageNote((note.page ?? 0) + 1),
                detail: [
                  ?note.note,
                  note.title,
                ].where((t) => t.isNotEmpty).join(' · '),
                italic: note.quote.isNotEmpty,
              ),
          ],
          if (page.books != null && (page.library_?.isNotEmpty ?? false)) ...[
            _Title(l10n.libraryTitleShared),
            for (final book in page.library_!)
              _Line(title: book.title, detail: book.authors.join(', ')),
          ],
          if (page.reading.isEmpty &&
              page.finished.isEmpty &&
              page.shelves.isEmpty &&
              page.reviews.isEmpty &&
              page.notes.isEmpty &&
              (page.library_?.isEmpty ?? true))
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                l10n.nothingShared,
                textAlign: TextAlign.center,
                style: BabelText.body(14),
              ),
            ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.value, this.label);
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('$value', style: BabelText.figure(32)),
      Text(
        label.toUpperCase(),
        style: BabelText.label(9, color: BabelColors.textSecondary),
      ),
    ],
  );
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 8),
    child: Text(text, style: BabelText.title(26)),
  );
}

class _Line extends StatelessWidget {
  const _Line({required this.title, required this.detail, this.italic = false});
  final String title;
  final String detail;
  final bool italic;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: BabelText.reading(16, italic: italic)),
        if (detail.isNotEmpty) Text(detail, style: BabelText.body(13)),
      ],
    ),
  );
}
