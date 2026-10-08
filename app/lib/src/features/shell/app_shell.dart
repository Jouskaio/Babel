import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/sync/sync_engine.dart';
import '../../core/theme/babel_colors.dart';
import '../../core/theme/babel_text.dart';
import '../../l10n.dart';
import '../../routing/router.dart';
import '../audiobooks/presentation/audio_player_view.dart';

class _Destination {
  const _Destination(this.icon, this.label, {this.branch, this.route});
  final IconData icon;
  final String label;
  final int? branch; // a tab of the shell
  final String? route; // or a full-screen page
}

/// The tab a page belongs to, so the bar lights it up: null for a page outside the tabs.
int? branchOf(String path) {
  bool under(String root) => path == root || path.startsWith('$root/');
  if (under(Routes.home)) return 0;
  if (under(Routes.search) || under('/works') || under('/saga')) return 1;
  if (under(Routes.library) ||
      under(Routes.sources) ||
      under(Routes.importLink) ||
      under(Routes.audiobooks)) {
    return 2;
  }
  if (under(Routes.profile) ||
      under(Routes.account) ||
      under(Routes.stats) ||
      under(Routes.friends) ||
      under(Routes.kavita) ||
      under(Routes.admin) ||
      under('/readers')) {
    return 3;
  }
  return null;
}

/// Pages shown without the bar: signing in, and the reader, which takes the whole screen.
bool _framed(String path) =>
    !Routes.public.contains(path) &&
    !Routes.open.contains(path) &&
    path != Routes.splash &&
    !path.startsWith('/read/');

/// Signed-in frame around every page: floating bottom bar on phones, sidebar on wide screens.
class AppChrome extends ConsumerStatefulWidget {
  const AppChrome({required this.router, required this.child, super.key});
  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<AppChrome> createState() => _AppChromeState();
}

class _AppChromeState extends ConsumerState<AppChrome> {
  GoRouter get router => widget.router;
  Widget get child => widget.child;

  @override
  void initState() {
    super.initState();
    router.routerDelegate.addListener(_routeChanged);
  }

  @override
  void dispose() {
    router.routerDelegate.removeListener(_routeChanged);
    super.dispose();
  }

  /// The router can announce a new page while the frame is being built: look again after it.
  void _routeChanged() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  static const _tabs = [
    Routes.home,
    Routes.search,
    Routes.library,
    Routes.profile,
  ];

  List<_Destination> _destinations(AppLocalizations l10n) => [
    _Destination(Icons.home_outlined, l10n.navHome, branch: 0),
    _Destination(Icons.search, l10n.navSearch, branch: 1),
    _Destination(Icons.qr_code_scanner, l10n.navScan, route: Routes.scan),
    _Destination(Icons.menu_book_outlined, l10n.navLibrary, branch: 2),
    _Destination(Icons.person_outline, l10n.navProfile, branch: 3),
  ];

  void _open(_Destination d) {
    if (d.route != null) {
      router.push(d.route!);
    } else {
      // Each tab keeps its own pages: going to its root shows where it was left.
      router.go(_tabs[d.branch!]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = ref.watch(authControllerProvider) is SignedIn;
    final path = router.routerDelegate.currentConfiguration.uri.path;
    if (!signedIn || !_framed(path)) return child;
    return _frame(context, branchOf(path) ?? -1);
  }

  Widget _frame(BuildContext context, int current) {
    // Watching the engine keeps it running while signed in.
    final sync = ref.watch(syncEngineProvider);
    final destinations = _destinations(context.l10n);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 960) {
          return Scaffold(
            body: Row(
              children: [
                _Sidebar(
                  destinations: destinations,
                  current: current,
                  onOpen: _open,
                ),
                Expanded(
                  child: SafeArea(
                    child: Column(
                      children: [
                        if (!sync.online) _OfflinePill(pending: sync.pending),
                        Expanded(child: child),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: MiniPlayer(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          // The pages end above the bar: those outside the tabs are not padded for it.
          body: SafeArea(bottom: false, child: child),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!sync.online) _OfflinePill(pending: sync.pending),
                const MiniPlayer(),
                _BottomBar(
                  destinations: destinations,
                  current: current,
                  onOpen: _open,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.destinations,
    required this.current,
    required this.onOpen,
  });
  final List<_Destination> destinations;
  final int current;
  final ValueChanged<_Destination> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: BabelColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: BabelColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final d in destinations)
            Expanded(
              child: InkResponse(
                onTap: () => onOpen(d),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(d.icon, size: 22, color: _color(d)),
                    const SizedBox(height: 4),
                    Text(
                      d.label.toUpperCase(),
                      style: BabelText.label(8, color: _color(d), spacing: 1),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _color(_Destination d) =>
      d.branch == current ? BabelColors.gold : BabelColors.textSecondary;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.destinations,
    required this.current,
    required this.onOpen,
  });
  final List<_Destination> destinations;
  final int current;
  final ValueChanged<_Destination> onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 248,
      decoration: BoxDecoration(
        color: BabelColors.surface,
        border: Border(right: BorderSide(color: BabelColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 32),
            child: Text(
              context.l10n.brand,
              style: BabelText.label(13, spacing: 6),
            ),
          ),
          for (final d in destinations)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Material(
                color: d.branch == current
                    ? BabelColors.sunken
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onOpen(d),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          d.icon,
                          size: 20,
                          color: d.branch == current
                              ? BabelColors.textPrimary
                              : BabelColors.textSecondary,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          d.label,
                          style: BabelText.body(
                            15,
                            color: d.branch == current
                                ? BabelColors.textPrimary
                                : BabelColors.textSecondary,
                            weight: d.branch == current
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// "Offline · 2 changes waiting": changes are kept and pushed when the network is back.
class _OfflinePill extends StatelessWidget {
  const _OfflinePill({required this.pending});
  final int pending;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = [
      l10n.offline,
      if (pending > 0) l10n.pendingOps(pending),
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: BabelColors.sunken,
          shape: StadiumBorder(
            side: BorderSide(color: BabelColors.gold.withValues(alpha: 0.5)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 14, color: BabelColors.gold),
              const SizedBox(width: 8),
              Text(
                text,
                style: BabelText.body(12, color: BabelColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
