import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_controller.dart';
import 'core/display/eink.dart';
import 'core/locale/locale_controller.dart';
import 'core/push/push_notifications.dart';
import 'core/share/share_intake.dart';
import 'core/sync/sync_engine.dart';
import 'core/theme/appearance.dart';
import 'core/theme/babel_colors.dart';
import 'core/theme/babel_look.dart';
import 'core/theme/babel_theme.dart';
import 'core/theme/backdrop.dart';
import 'core/theme/palette_scope.dart';
import 'core/update/app_update.dart';
import 'core/update/update_dialog.dart';
import 'features/shell/app_shell.dart';
import 'l10n.dart';
import 'routing/router.dart';

/// Application root.
class BabelApp extends ConsumerStatefulWidget {
  const BabelApp({super.key});

  @override
  ConsumerState<BabelApp> createState() => _BabelAppState();
}

class _BabelAppState extends ConsumerState<BabelApp>
    with WidgetsBindingObserver {
  StreamSubscription<Shared>? _shares;
  StreamSubscription<Map<String, String>>? _notifications;
  Timer? _updates;
  int _offered = 0; // the build the update was last offered for, this session

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToNotifications();
    _listenToShares();
    _watchUpdates();
  }

  /// A new release is offered when the app starts, then every few hours and when it comes
  /// back to the front; the reader who said "later" is not asked again for that version.
  void _watchUpdates() {
    ref.listenManual(availableUpdateProvider, (_, update) async {
      final release = update.value;
      if (release == null || !canUpdate(release) || release.build <= _offered) {
        return;
      }
      if (release.build <= await dismissedBuild() || !mounted) return;
      final context = ref
          .read(routerProvider)
          .routerDelegate
          .navigatorKey
          .currentContext;
      if (context == null || !context.mounted) return;
      _offered = release.build;
      await showUpdateDialog(context, release);
    }, fireImmediately: true);
    _updates = Timer.periodic(
      const Duration(hours: 6),
      (_) => ref.invalidate(latestReleaseProvider),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back to the app (or to its tab): learn what the other devices did meanwhile.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(latestReleaseProvider);
    }
    if (state == AppLifecycleState.resumed &&
        ref.read(authControllerProvider) is SignedIn) {
      unawaited(ref.read(syncEngineProvider.notifier).sync());
    }
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
    _notifications = messaging.opened.listen(_openNotification);
    unawaited(
      messaging.openedAtLaunch().then((data) {
        if (data != null && mounted) _openNotification(data);
      }),
    );
  }

  /// A new chapter opens its book; friend requests the friends; recommendations home.
  void _openNotification(Map<String, String> data) {
    final router = ref.read(routerProvider);
    switch (data['kind']) {
      case 'friend_request':
        router.go(Routes.friends);
      case 'friend_accepted' when data['handle'] != null:
        router.go(Routes.reader(data['handle']!));
      case 'recommendation':
        router.go(Routes.home);
      case 'report':
        router.go(Routes.admin);
      case _ when data['item_id'] != null:
        router.go(Routes.read(data['item_id']!));
    }
  }

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
    WidgetsBinding.instance.removeObserver(this);
    _updates?.cancel();
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
    final appearance = ref.watch(appearanceProvider);
    final reading = ref.watch(readingPaletteProvider);
    final palette = reading ?? (eink ? BabelPalette.paper : appearance.palette);
    // A book's own palette and e-ink keep Babel's plain look.
    final look = reading != null || eink ? BabelLook.standard : appearance.look;
    if (palette != BabelColors.palette || look != BabelShape.look) {
      BabelColors.use(palette);
      BabelShape.use(look);
      // Pages read their colors when built: rebuild them all, keeping their state.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) rebuildAll(context);
      });
    }
    return MaterialApp.router(
      title: 'Babel',
      debugShowCheckedModeBanner: false,
      theme: BabelTheme.current(eink: eink),
      // Every text can be selected and copied (an error message, an address, a title). The
      // selection menu needs an Overlay above the pages, hence the entry. The e-ink setting
      // sits outside it: an entry is not rebuilt when this builder runs again.
      builder: (context, child) {
        final router = ref.read(routerProvider);
        final pages = Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (_) => SelectionArea(
                child: AppChrome(router: router, child: child!),
              ),
            ),
          ],
        );
        final framed = AppBackdrop(look: look, child: pages);
        return eink
            ? MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: framed,
              )
            : framed;
      },
      locale: ref.watch(localeControllerProvider),
      localeListResolutionCallback: LocaleController.resolve,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
