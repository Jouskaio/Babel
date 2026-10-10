import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../application/sources_providers.dart';

/// The plugins the administrator installed, and which ones this reader has on.
final pluginsProvider = FutureProvider.autoDispose<List<PluginResponse>>(
  (ref) async => await ref.watch(pluginsApiProvider).listPlugins() ?? const [],
);

/// Reader side: a switch per plugin; switching one on adds it to the sources.
class PluginsList extends ConsumerWidget {
  const PluginsList({super.key});

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    PluginResponse plugin,
    bool on,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final api = ref.read(pluginsApiProvider);
      if (on) {
        await api.activatePlugin(plugin.id);
      } else {
        await api.deactivatePlugin(plugin.id);
      }
    } on ApiException {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
    ref
      ..invalidate(pluginsProvider)
      ..invalidate(sourcesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final plugins = ref.watch(pluginsProvider).value;
    if (plugins == null || plugins.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Text(l10n.pluginsTitle.toUpperCase(), style: BabelText.label(10)),
        const SizedBox(height: 4),
        Text(l10n.pluginsHint, style: BabelText.body(13)),
        const SizedBox(height: 8),
        for (final plugin in plugins)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: BabelColors.gold,
            title: Text(plugin.name, style: BabelText.heading(18)),
            subtitle: plugin.description == null
                ? null
                : Text(plugin.description!, style: BabelText.body(12)),
            value: plugin.active,
            onChanged: (on) => _toggle(context, ref, plugin, on),
          ),
      ],
    );
  }
}

/// Administrator side: install a plugin from a manifest address, remove one.
class AdminPlugins extends ConsumerStatefulWidget {
  const AdminPlugins({super.key});

  @override
  ConsumerState<AdminPlugins> createState() => _AdminPluginsState();
}

class _AdminPluginsState extends ConsumerState<AdminPlugins> {
  final _name = TextEditingController();
  final _url = TextEditingController(text: 'https://');
  final _token = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _url, _token]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _install() async {
    final l10n = context.l10n;
    if (_name.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(pluginsApiProvider)
          .installPlugin(
            InstallPlugin(
              name: _name.text.trim(),
              url: _url.text.trim(),
              token: _token.text.trim().isEmpty ? null : _token.text.trim(),
            ),
          );
      _name.clear();
      _token.clear();
      ref.invalidate(pluginsProvider);
    } on ApiException catch (error) {
      setState(
        () => _error = error.innerException != null
            ? l10n.errorNetwork
            : l10n.pluginsInstallFailed,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plugins = ref.watch(pluginsProvider).value ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.pluginsAdminTitle.toUpperCase(), style: BabelText.label(10)),
        const SizedBox(height: 4),
        Text(l10n.pluginsAdminHint, style: BabelText.body(13)),
        const SizedBox(height: 10),
        for (final plugin in plugins)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(plugin.name, style: BabelText.heading(18)),
            trailing: IconButton(
              tooltip: l10n.pluginsRemove,
              icon: Icon(
                Icons.delete_outline,
                color: BabelColors.textSecondary,
              ),
              onPressed: () async {
                await ref.read(pluginsApiProvider).uninstallPlugin(plugin.id);
                ref.invalidate(pluginsProvider);
              },
            ),
          ),
        const SizedBox(height: 8),
        BabelTextField(label: l10n.pluginsName, controller: _name),
        const SizedBox(height: 10),
        BabelTextField(
          label: l10n.pluginsUrl,
          controller: _url,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 10),
        BabelTextField(
          label: l10n.pluginsToken,
          controller: _token,
          obscure: true,
          showLabel: l10n.showPassword,
          hideLabel: l10n.hidePassword,
        ),
        if (_error case final error?)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error,
              style: BabelText.body(13, color: BabelColors.dustyRose),
            ),
          ),
        const SizedBox(height: 12),
        PillButton(
          label: l10n.pluginsInstall,
          kind: PillButtonKind.secondary,
          expand: true,
          loading: _busy,
          onPressed: _install,
        ),
      ],
    );
  }
}
