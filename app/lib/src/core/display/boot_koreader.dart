import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n.dart';
import '../theme/babel_colors.dart';
import '../theme/babel_text.dart';

/// "Open KOReader when the e-reader starts" (Android, when KOReader is installed): at boot,
/// Babel brings KOReader to the front (see BootReceiver.kt).
@immutable
class BootKoreaderState {
  const BootKoreaderState({
    required this.on,
    required this.installed,
    required this.allowed,
    required this.watch,
  });

  factory BootKoreaderState.from(Map<Object?, Object?>? map) =>
      BootKoreaderState(
        on: map?['on'] == true,
        installed: map?['installed'] == true,
        allowed: map?['allowed'] == true,
        watch: map?['watch'] == true,
      );

  final bool on;

  /// KOReader is on this device.
  final bool installed;

  /// Android lets Babel open it from the background ("Display over other apps").
  final bool allowed;

  /// Babel may see which app is in front ("Usage access"), so at boot it reopens KOReader only
  /// when the launcher covers it.
  final bool watch;
}

const _channel = MethodChannel('babel/device');

Future<BootKoreaderState?> _read() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
  try {
    return BootKoreaderState.from(
      await _channel.invokeMapMethod<Object?, Object?>('bootKoreader'),
    );
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}

/// The switch, in "My e-readers". Shows nothing off Android or without KOReader.
class BootKoreaderSwitch extends StatefulWidget {
  const BootKoreaderSwitch({super.key});

  @override
  State<BootKoreaderSwitch> createState() => _BootKoreaderSwitchState();
}

class _BootKoreaderSwitchState extends State<BootKoreaderSwitch> {
  BootKoreaderState? _state;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _refresh();
    // Back from the system's "Display over other apps" page.
    _lifecycle = AppLifecycleListener(onResume: _refresh);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final state = await _read();
    if (mounted) setState(() => _state = state);
  }

  Future<void> _set(bool on) async {
    try {
      final map = await _channel.invokeMapMethod<Object?, Object?>(
        'setBootKoreader',
        {'on': on},
      );
      final state = BootKoreaderState.from(map);
      if (mounted) setState(() => _state = state);
      if (on && !state.allowed) await _allow();
    } on PlatformException {
      // Left as it was.
    }
  }

  Future<void> _allow() => _channel.invokeMethod<void>('allowBackgroundStart');

  Future<void> _allowWatch() => _channel.invokeMethod<void>('allowUsageAccess');

  Widget _ask(String text, String button, VoidCallback onPressed) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: BabelText.body(12, color: BabelColors.gold)),
        ),
        TextButton(onPressed: onPressed, child: Text(button)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null || !state.installed) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: state.on,
          onChanged: _set,
          title: Text(l10n.bootKoreader, style: BabelText.body(14)),
          subtitle: Text(l10n.bootKoreaderHint, style: BabelText.body(12)),
        ),
        if (state.on && !state.allowed)
          _ask(l10n.bootKoreaderAllow, l10n.bootKoreaderAllowButton, _allow)
        else if (state.on && !state.watch)
          _ask(
            l10n.bootKoreaderWatch,
            l10n.bootKoreaderWatchButton,
            _allowWatch,
          ),
      ],
    );
  }
}
