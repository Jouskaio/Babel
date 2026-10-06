import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/search_page.dart';
import '../application/library_controller.dart';

/// Says which catalog work a book is, so its reviews and notes join every other
/// edition's on the work's page.
Future<void> showLinkWorkSheet(
  BuildContext context,
  LibraryItemResponse item,
) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  backgroundColor: BabelColors.surface,
  builder: (_) => _LinkWorkSheet(item: item),
);

class _LinkWorkSheet extends ConsumerStatefulWidget {
  const _LinkWorkSheet({required this.item});
  final LibraryItemResponse item;

  @override
  ConsumerState<_LinkWorkSheet> createState() => _LinkWorkSheetState();
}

class _LinkWorkSheetState extends ConsumerState<_LinkWorkSheet> {
  late final _query = TextEditingController(
    text: [widget.item.title, ...widget.item.authors.take(1)].join(' '),
  );
  late String _search = _query.text;
  bool _saving = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _link(String? workId) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      final updated = await ref
          .read(libraryApiProvider)
          .linkWork(widget.item.id, WorkLinkRequest(workId: workId));
      if (updated != null) {
        await ref.read(libraryControllerProvider.notifier).keep(updated);
      }
      navigator.pop();
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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final results = _search.trim().isEmpty
        ? null
        : ref.watch(searchResultsProvider((query: _search.trim(), lang: lang)));
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.linkWork, style: BabelText.title(30)),
              const SizedBox(height: 6),
              Text(l10n.linkWorkHint, style: BabelText.body(13)),
              const SizedBox(height: 14),
              TextField(
                controller: _query,
                textInputAction: TextInputAction.search,
                style: BabelText.body(15, color: BabelColors.textPrimary),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: BabelColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: BabelColors.canvas,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (v) => setState(() => _search = v),
              ),
              if (_saving)
                LinearProgressIndicator(
                  color: BabelColors.gold,
                  backgroundColor: BabelColors.sunken,
                ),
              Expanded(
                child:
                    results?.when(
                      loading: () => Center(
                        child: CircularProgressIndicator(
                          color: BabelColors.gold,
                        ),
                      ),
                      error: (_, _) => Center(
                        child: Text(
                          l10n.errorNetwork,
                          style: BabelText.body(14),
                        ),
                      ),
                      data: (works) => ListView(
                        children: [
                          for (final work in works)
                            WorkRow(
                              work: work,
                              onTap: _saving ? () {} : () => _link(work.id),
                            ),
                          if (widget.item.workId != null)
                            TextButton(
                              onPressed: _saving ? null : () => _link(null),
                              child: Text(l10n.linkWorkNone),
                            ),
                        ],
                      ),
                    ) ??
                    const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
