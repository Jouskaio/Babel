import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/babel_colors.dart';
import '../../core/theme/babel_text.dart';
import '../../l10n.dart';
import '../../routing/router.dart';

class _Destination {
  const _Destination(this.icon, this.label, {this.branch, this.route});
  final IconData icon;
  final String label;
  final int? branch; // a tab of the shell
  final String? route; // or a full-screen page
}

/// Signed-in frame: floating bottom bar on phones, sidebar on wide screens.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});
  final StatefulNavigationShell shell;

  List<_Destination> _destinations(AppLocalizations l10n) => [
    _Destination(Icons.home_outlined, l10n.navHome, branch: 0),
    _Destination(Icons.search, l10n.navSearch, branch: 1),
    _Destination(Icons.qr_code_scanner, l10n.navScan, route: Routes.scan),
    _Destination(Icons.menu_book_outlined, l10n.navLibrary, branch: 2),
    _Destination(Icons.person_outline, l10n.navProfile, branch: 3),
  ];

  void _open(BuildContext context, _Destination d) {
    if (d.route != null) {
      context.push(d.route!);
    } else {
      shell.goBranch(
        d.branch!,
        initialLocation: d.branch == shell.currentIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(context.l10n);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 960) {
          return Scaffold(
            body: Row(
              children: [
                _Sidebar(
                  destinations: destinations,
                  current: shell.currentIndex,
                  onOpen: (d) => _open(context, d),
                ),
                Expanded(child: SafeArea(child: shell)),
              ],
            ),
          );
        }
        return Scaffold(
          extendBody: true,
          body: SafeArea(bottom: false, child: shell),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _BottomBar(
              destinations: destinations,
              current: shell.currentIndex,
              onOpen: (d) => _open(context, d),
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
      decoration: const BoxDecoration(
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
