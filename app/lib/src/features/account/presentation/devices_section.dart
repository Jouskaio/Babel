import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/locale/relative_time.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../l10n.dart';

/// The devices that sync with this account.
final devicesProvider = FutureProvider.autoDispose<List<DeviceResponse>>(
  (ref) async => await ref.watch(syncApiProvider).getDevices() ?? const [],
);

/// "My devices": each one that syncs, when it was last seen, and a way to forget it.
class DevicesSection extends ConsumerWidget {
  const DevicesSection({super.key});

  IconData _icon(DeviceKind kind) {
    if (kind == DeviceKind.phone) return Icons.smartphone_rounded;
    if (kind == DeviceKind.tablet) return Icons.tablet_mac_rounded;
    if (kind == DeviceKind.ereader) return Icons.menu_book_rounded;
    if (kind == DeviceKind.desktop) return Icons.computer_rounded;
    return Icons.language_rounded;
  }

  Future<void> _forget(
    BuildContext context,
    WidgetRef ref,
    DeviceResponse device,
  ) async {
    final l10n = context.l10n;
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BabelColors.surface,
        title: Text(l10n.deviceForgetTitle(device.name)),
        content: Text(l10n.deviceForgetBody, style: BabelText.body(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deviceForget),
          ),
        ],
      ),
    );
    if (sure != true) return;
    await ref.read(syncApiProvider).removeDevice(device.id);
    ref.invalidate(devicesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final devices = ref.watch(devicesProvider).value;
    final mine = ref.watch(deviceSessionProvider).id;
    if (devices == null || devices.isEmpty) {
      return Text(l10n.devicesEmpty, style: BabelText.body(13));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.devicesHint, style: BabelText.body(13)),
        const SizedBox(height: 8),
        for (final d in devices)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(_icon(d.kind), color: BabelColors.gold),
            title: Text(
              d.id == mine ? '${d.name} · ${l10n.deviceThis}' : d.name,
              style: BabelText.heading(17),
            ),
            subtitle: Text(
              l10n.deviceLastSeen(timeAgo(context, d.lastSeenAt)),
              style: BabelText.body(12),
            ),
            trailing: d.id == mine
                ? null
                : IconButton(
                    tooltip: l10n.deviceForget,
                    icon: Icon(
                      Icons.delete_outline,
                      color: BabelColors.textSecondary,
                    ),
                    onPressed: () => _forget(context, ref, d),
                  ),
          ),
      ],
    );
  }
}
