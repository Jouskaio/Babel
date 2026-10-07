import 'package:babel_api_client/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/storage/local_database.dart';
import '../../../core/sync/lookups.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../library/application/library_controller.dart';

/// Barcode scanning on phones and tablets; manual ISBN entry everywhere.
bool get _cameraSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Scan a book (design: Penpot "screen / scan").
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  final _isbn = TextEditingController();
  final _scanner = _cameraSupported
      ? MobileScannerController(formats: const [BarcodeFormat.ean13])
      : null;
  String? _lastCode;
  bool _busy = false;
  IsbnLookupResponse? _found;
  String? _error;
  bool _burst = false;
  final _added = <String>[];

  @override
  void dispose() {
    _isbn.dispose();
    _scanner?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.map((b) => b.rawValue).nonNulls.firstOrNull;
    // Book barcodes are EAN-13 starting with 978 or 979 (the ISBN-13 itself).
    if (code == null ||
        code == _lastCode ||
        !RegExp(r'^97[89]\d{10}$').hasMatch(code)) {
      return;
    }
    _lastCode = code;
    _lookup(code);
  }

  Future<void> _lookup(String isbn) async {
    final lang = Localizations.localeOf(context).languageCode;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final found = await ref
          .read(authedCatalogApiProvider)
          .lookupIsbn(isbn, lang: lang);
      if (mounted) setState(() => _found = found);
      if (_burst && found != null) await _addPaper(found.work);
    } on ApiException catch (error) {
      if (mounted) {
        setState(() {
          _found = null;
          _error = switch (error.code) {
            400 => l10n.isbnInvalid,
            404 => l10n.isbnNotFound,
            _ =>
              error.innerException != null
                  ? l10n.scanQueued
                  : l10n.errorGeneric,
          };
        });
      }
      if (error.innerException != null) {
        // Offline: keep the scan, it is looked up when the network is back.
        final db = await ref.read(localDatabaseProvider.future);
        if (db != null) {
          await queueLookup(db, LookupKind.isbn, isbn.trim(), lang);
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Burst mode: the scanned book joins the library as a paper book.
  Future<void> _addPaper(WorkResponse work) async {
    final item = await ref
        .read(libraryApiProvider)
        .addPaperBook(PaperBookRequest(workId: work.id));
    if (item == null) return;
    await ref.read(libraryControllerProvider.notifier).keep(item);
    if (mounted) setState(() => _added.add(item.title));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          l10n.scanTitle.toUpperCase(),
          style: BabelText.label(11, color: BabelColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _scanner == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.cameraUnavailable,
                        textAlign: TextAlign.center,
                        style: BabelText.body(15),
                      ),
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(
                        controller: _scanner,
                        onDetect: _onDetect,
                        errorBuilder: (_, _) => Center(
                          child: Text(
                            l10n.cameraUnavailable,
                            style: BabelText.body(15),
                          ),
                        ),
                      ),
                      Container(
                        width: 270,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: BabelColors.gold, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 16,
                        right: 16,
                        child: SwitchListTile(
                          value: _burst,
                          onChanged: (v) => setState(() => _burst = v),
                          title: Text(
                            l10n.scanBurst,
                            style: BabelText.body(
                              13,
                              color: BabelColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        child: Text(
                          l10n.scanHint,
                          style: BabelText.body(
                            14,
                            color: BabelColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          _ResultSheet(
            isbn: _isbn,
            busy: _busy,
            found: _found,
            error: _error,
            added: _added,
            onLookup: () => _lookup(_isbn.text),
          ),
        ],
      ),
    );
  }
}

class _ResultSheet extends StatelessWidget {
  const _ResultSheet({
    required this.isbn,
    required this.busy,
    required this.found,
    required this.error,
    required this.added,
    required this.onLookup,
  });

  final TextEditingController isbn;
  final bool busy;
  final IsbnLookupResponse? found;
  final String? error;
  final List<String> added;
  final VoidCallback onLookup;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final work = found?.work;
    final edition = work?.editions
        .where((e) => e.id == found!.editionId)
        .firstOrNull;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (work != null) ...[
              Row(
                children: [
                  BookCover(
                    width: 64,
                    url: work.coverPath == null
                        ? null
                        : apiUrl(work.coverPath!),
                    title: work.title,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n
                              .scanFound(
                                edition?.isbn13.firstOrNull ?? isbn.text,
                              )
                              .toUpperCase(),
                          style: BabelText.label(9),
                        ),
                        const SizedBox(height: 4),
                        Text(work.title, style: BabelText.title(26)),
                        Text(
                          [
                            work.authors.join(', '),
                            ?edition?.publisher,
                          ].join(' · '),
                          style: BabelText.body(13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              PillButton(
                label: l10n.seeWork,
                large: true,
                expand: true,
                onPressed: () => context.push(Routes.work(work.id)),
              ),
              const SizedBox(height: 16),
            ],
            if (added.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  l10n.scanBurstAdded(
                    added.length,
                    added.reversed.take(3).join(', '),
                  ),
                  style: BabelText.body(13, color: BabelColors.gold),
                ),
              ),
            if (error case final message?)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  message,
                  style: BabelText.body(13, color: BabelColors.dustyRose),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: isbn,
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => onLookup(),
                    style: BabelText.body(15, color: BabelColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: l10n.isbnManualHint,
                      hintStyle: BabelText.body(15),
                      filled: true,
                      fillColor: BabelColors.canvas,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PillButton(
                  label: l10n.isbnLookup,
                  loading: busy,
                  onPressed: onLookup,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
