import 'dart:async';

import 'package:babel_api_client/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';

/// What can be translated and into which languages; null when the server cannot say.
final translationLanguagesProvider =
    FutureProvider.autoDispose<LanguagesResponse?>(
      (ref) => ref.watch(translateApiProvider).getTranslationLanguages(),
    );

/// The reader's book translations with their progress, newest first.
final bookTranslationsProvider =
    FutureProvider.autoDispose<List<BookTranslationResponse>>((ref) async {
      final jobs =
          await ref.watch(translateApiProvider).listBookTranslations() ??
          const [];
      // While one runs, ask again every few seconds.
      if (jobs.any((j) => j.status == 'queued' || j.status == 'running')) {
        final timer = Timer(const Duration(seconds: 4), ref.invalidateSelf);
        ref.onDispose(timer.cancel);
      }
      return jobs;
    });
