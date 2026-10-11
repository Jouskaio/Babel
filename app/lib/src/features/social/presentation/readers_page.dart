import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_look.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/loading_bar.dart';
import '../../../l10n.dart';
import '../../sources/presentation/source_badge.dart';
import '../application/social_providers.dart';
import 'social_widgets.dart';

/// Every reader who chose a handle, searchable; a tap opens their page.
class ReadersPage extends ConsumerStatefulWidget {
  const ReadersPage({super.key});

  @override
  ConsumerState<ReadersPage> createState() => _ReadersPageState();
}

class _ReadersPageState extends ConsumerState<ReadersPage> {
  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _query = value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final readers = ref.watch(readersDirectoryProvider(_query));
    return Scaffold(
      appBar: sourcesAppBar(l10n.readersTitle),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            children: [
              TextField(
                controller: _search,
                onChanged: _onSearch,
                style: BabelText.body(15, color: BabelColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.searchReaders,
                  hintStyle: BabelText.body(15),
                  prefixIcon: Icon(
                    Icons.search,
                    color: BabelColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: BabelColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BabelShape.radius(28),
                    borderSide: BorderSide(color: BabelColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BabelShape.radius(28),
                    borderSide: BorderSide(color: BabelColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...switch (readers) {
                AsyncData(:final value) when value.isEmpty => [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(l10n.noReaderFound, style: BabelText.body(14)),
                  ),
                ],
                AsyncData(:final value) => [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      l10n.readersCount(value.length),
                      style: BabelText.label(10),
                    ),
                  ),
                  for (final reader in value)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                      decoration: BoxDecoration(
                        color: BabelColors.surface,
                        borderRadius: BabelShape.radius(18),
                        border: Border.all(color: BabelColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ReaderTile(
                            name: reader.displayName,
                            handle: reader.handle,
                            subtitle: reader.handle == null
                                ? null
                                : '@${reader.handle}',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 58),
                            child: RelationButtons(reader: reader),
                          ),
                        ],
                      ),
                    ),
                ],
                AsyncError() => [
                  Text(l10n.errorNetwork, style: BabelText.body(14)),
                ],
                _ => [const LoadingBar()],
              },
            ],
          ),
        ),
      ),
    );
  }
}
