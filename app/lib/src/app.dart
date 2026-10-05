import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_controller.dart';
import 'core/display/eink.dart';
import 'core/locale/locale_controller.dart';
import 'core/push/push_notifications.dart';
import 'core/share/share_intake.dart';
import 'core/theme/babel_colors.dart';
import 'core/theme/babel_theme.dart';
import 'core/theme/palette_scope.dart';
import 'l10n.dart';
import 'routing/router.dart';

/// Application root.
class BabelApp extends ConsumerStatefulWidget {
  const BabelApp({super.key});

  @override
  ConsumerState<BabelApp> createState() => _BabelAppState();
}

class _BabelAppState extends ConsumerState<BabelApp> {
  StreamSubscription<Shared>? _shares;
  StreamSubscription<String>? _notifications;

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
    _listenToShares();
  }

  /// Notifications are set up once signed in (the permission is asked then); tapping
  /// one opens its book.
  void _listenToNotifications() {
    final messaging = ref.read(pushMessagingProvider);
    if (messaging == null) return;
    ref.listenManual(authControllerProvider, (_, session) {
      if (session is SignedIn) {
        unawaited(ref.read(pushRegistrationProvider)?.start());
      }
    }, fireImmediately: true);
    _notifications = messaging.opened.listen(_openBook);
    unawaited(
      messaging.openedAtLaunch().then((item) {
        if (item != null && mounted) _openBook(item);
      }),
    );
  }

  void _openBook(String itemId) =>
      ref.read(routerProvider).go(Routes.read(itemId));

  void _listenToShares() {
    final source = ref.read(shareSourceProvider);
    if (source == null) return;
    _shares = source.incoming.listen(_open);
    unawaited(
      source.initial().then((shared) {
        if (shared != null && mounted) _open(shared);
      }),
    );
  }

  @override
  void dispose() {
    unawaited(_shares?.cancel());
    unawaited(_notifications?.cancel());
    super.dispose();
  }

  /// Links open the link import, files go to the library, which imports them.
  void _open(Shared shared) {
    final router = ref.read(routerProvider);
    switch (shared) {
      case SharedText(:final text):
        router.go(
          Uri(
            path: Routes.importLink,
            queryParameters: {'text': text},
          ).toString(),
        );
      case SharedFile():
        ref.read(pendingSharedFileProvider.notifier).offer(shared);
        router.go(Routes.library);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eink = ref.watch(einkDisplayProvider.select((d) => d.active));
    final palette =
        ref.watch(readingPaletteProvider) ??
        (eink ? BabelPalette.paper : BabelPalette.midnight);
    if (palette != BabelColors.palette) {
      BabelColors.use(palette);
      // Pages read their colors when built: rebuild them all, keeping their state.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) rebuildAll(context);
      });
    }
    return MaterialApp.router(
      title: 'Babel',
      debugShowCheckedModeBanner: false,
      theme: BabelTheme.current(eink: eink),
      builder: (context, child) => eink
          ? MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            )
          : child!,
      locale: ref.watch(localeControllerProvider),
      localeListResolutionCallback: LocaleController.resolve,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
