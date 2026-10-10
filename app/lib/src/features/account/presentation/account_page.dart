import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_failure.dart';
import '../../../core/display/eink_setting.dart';
import '../../../core/locale/language_picker.dart';
import '../../../core/push/push_notifications.dart';
import '../../../core/theme/appearance_setting.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/babel_text_field.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../audiobooks/presentation/audiobookshelf_section.dart';
import '../../auth/presentation/auth_layout.dart';
import '../../kavita/presentation/kavita_section.dart';
import '../../library/presentation/reading_list_import.dart';
import '../../social/presentation/sharing_settings.dart';
import 'chaptarr_section.dart';
import 'devices_section.dart';
import 'koreader_section.dart';
import 'pagebound_section.dart';
import 'shelfmark_section.dart';

/// Profile, password, sign-out and account deletion.
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider);
    if (session is! SignedIn) return const SizedBox.shrink();
    final l10n = context.l10n;
    final user = session.user;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: BabelColors.textPrimary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.profile),
        ),
        title: Text(l10n.accountTitle, style: BabelText.heading(24)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  user.email,
                  style: BabelText.body(15, color: BabelColors.textPrimary),
                ),
                if (user.providers.isNotEmpty)
                  Text(
                    l10n.signedInWith(
                      user.providers
                          .map((p) => p.value == 'apple' ? 'Apple' : 'Google')
                          .join(', '),
                    ),
                    style: BabelText.body(13),
                  ),
                const SizedBox(height: 24),
                // Four groups, closed until opened: the page reads as a table of contents.
                _Group(
                  icon: Icons.person_outline_rounded,
                  title: l10n.groupAccount,
                  subtitle: l10n.groupAccountHint,
                  initiallyOpen: true,
                  children: [
                    _Block(
                      title: l10n.accountProfile,
                      child: _ProfileForm(user: user),
                    ),
                    _Block(
                      title: l10n.accountSecurity,
                      child: _PasswordForm(user: user),
                    ),
                    _Block(
                      title: l10n.publicProfile,
                      child: const SharingSettings(),
                    ),
                  ],
                ),
                _Group(
                  icon: Icons.devices_rounded,
                  title: l10n.groupDisplay,
                  subtitle: l10n.groupDisplayHint,
                  children: [
                    _Block(
                      title: l10n.language,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: LanguagePicker(),
                      ),
                    ),
                    _Block(
                      title: l10n.appearanceTitle,
                      child: const AppearanceSetting(),
                    ),
                    _Block(title: l10n.einkTitle, child: const EinkSetting()),
                    _Block(
                      title: l10n.devicesTitle,
                      child: const DevicesSection(),
                    ),
                    _Block(
                      title: l10n.koreaderTitle,
                      child: const KoreaderSection(),
                    ),
                  ],
                ),
                _Group(
                  icon: Icons.hub_outlined,
                  title: l10n.groupConnections,
                  subtitle: l10n.groupConnectionsHint,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.cloud_sync_outlined,
                        color: BabelColors.gold,
                      ),
                      title: Text(
                        l10n.sourcesTitle,
                        style: BabelText.heading(18),
                      ),
                      subtitle: Text(
                        l10n.accountSourcesHint,
                        style: BabelText.body(13),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: BabelColors.textSecondary,
                      ),
                      onTap: () => context.push(Routes.sources),
                    ),
                    _Block(
                      title: l10n.kavitaTitle,
                      child: const KavitaSection(),
                    ),
                    _Block(
                      title: l10n.absTitle,
                      child: const AudiobookshelfSection(),
                    ),
                    _Block(
                      title: l10n.pageboundTitle,
                      child: const PageboundSection(),
                    ),
                  ],
                ),
                _Group(
                  icon: Icons.download_for_offline_outlined,
                  title: l10n.groupRequests,
                  subtitle: l10n.groupRequestsHint,
                  children: [
                    _Block(
                      title: l10n.shelfmarkTitle,
                      child: const ShelfmarkSection(),
                    ),
                    _Block(
                      title: l10n.chaptarrTitle,
                      child: const ChaptarrSection(),
                    ),
                  ],
                ),
                _Group(
                  icon: Icons.upload_file_outlined,
                  title: l10n.groupData,
                  subtitle: l10n.groupDataHint,
                  children: [
                    _Block(
                      title: l10n.importTitle,
                      child: const ReadingListImport(),
                    ),
                  ],
                ),
                if (user.admin)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.admin_panel_settings_outlined,
                      color: BabelColors.gold,
                    ),
                    title: Text(l10n.adminTitle, style: BabelText.heading(20)),
                    subtitle: Text(
                      l10n.adminPremiumHint,
                      style: BabelText.body(13),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: BabelColors.textSecondary,
                    ),
                    onTap: () => context.push(Routes.admin),
                  ),
                const SizedBox(height: 32),
                PillButton(
                  label: l10n.signOut,
                  kind: PillButtonKind.secondary,
                  expand: true,
                  onPressed: () async {
                    await ref.read(pushRegistrationProvider)?.unregister();
                    await ref.read(authControllerProvider.notifier).logout();
                    // A deliberate sign-out ends on the landing page, not on the sign-in form.
                    ref.read(routerProvider).go(Routes.landing);
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _confirmDeletion(context, ref),
                  child: Text(
                    l10n.deleteAccount,
                    style: BabelText.body(14, color: BabelColors.dustyRose),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeletion(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BabelColors.surface,
        title: Text(l10n.deleteAccountTitle, style: BabelText.heading(24)),
        content: Text(l10n.deleteAccountBody, style: BabelText.body(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.delete,
              style: BabelText.body(
                14,
                color: BabelColors.dustyRose,
                weight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(accountApiProvider).deleteMe();
      await ref.read(authControllerProvider.notifier).signOutLocally();
    } on ApiException catch (error) {
      if (context.mounted) _snack(context, AuthFailure.of(error));
    }
  }
}

void _snack(BuildContext context, AuthFailure? failure, [String? success]) {
  final l10n = context.l10n;
  final text =
      success ??
      switch (failure) {
        AuthFailure.wrongPassword => l10n.errorWrongPassword,
        AuthFailure.network => l10n.errorNetwork,
        _ => l10n.errorGeneric,
      };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

/// A group of settings: a card that opens to its blocks.
class _Group extends StatelessWidget {
  const _Group({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.initiallyOpen = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final bool initiallyOpen;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Container(
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: BabelColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyOpen,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Icon(icon, color: BabelColors.gold),
          iconColor: BabelColors.textSecondary,
          collapsedIconColor: BabelColors.textSecondary,
          title: Text(title, style: BabelText.heading(20)),
          subtitle: Text(subtitle, style: BabelText.body(12)),
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 36),
              children[i],
            ],
          ],
        ),
      ),
    ),
  );
}

/// A titled block inside a group.
class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title.toUpperCase(), style: BabelText.label(10, spacing: 1.6)),
      const SizedBox(height: 12),
      child,
    ],
  );
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.user});
  final UserResponse user;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.user.displayName);
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final user = await ref
          .read(accountApiProvider)
          .updateMe(UpdateProfileRequest(displayName: _name.text.trim()));
      if (user != null) {
        ref.read(authControllerProvider.notifier).updateUser(user);
      }
      if (mounted) _snack(context, null, context.l10n.saved);
    } on ApiException catch (error) {
      if (mounted) _snack(context, AuthFailure.of(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BabelTextField(
            label: l10n.displayNameLabel,
            controller: _name,
            validator: Validators.required(context),
          ),
          const SizedBox(height: 18),
          PillButton(label: l10n.save, loading: _busy, onPressed: _save),
        ],
      ),
    );
  }
}

class _PasswordForm extends ConsumerStatefulWidget {
  const _PasswordForm({required this.user});
  final UserResponse user;

  @override
  ConsumerState<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends ConsumerState<_PasswordForm> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(accountApiProvider)
          .changePassword(
            ChangePasswordRequest(
              currentPassword: widget.user.hasPassword ? _current.text : null,
              newPassword: _next.text,
            ),
          );
      // The API signs out every session, this one included: open a fresh one.
      await ref
          .read(authControllerProvider.notifier)
          .login(widget.user.email, _next.text);
      _current.clear();
      _next.clear();
      if (mounted) _snack(context, null, context.l10n.passwordChanged);
    } on ApiException catch (error) {
      if (mounted) _snack(context, AuthFailure.of(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasPassword = widget.user.hasPassword;
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasPassword) ...[
            BabelTextField(
              label: l10n.currentPasswordLabel,
              controller: _current,
              validator: Validators.required(context),
              obscure: true,
              showLabel: l10n.showPassword,
              hideLabel: l10n.hidePassword,
              autofillHints: const [AutofillHints.password],
            ),
            const SizedBox(height: 14),
          ],
          BabelTextField(
            label: l10n.newPasswordLabel,
            controller: _next,
            validator: Validators.newPassword(context),
            help: l10n.passwordHelp,
            obscure: true,
            showLabel: l10n.showPassword,
            hideLabel: l10n.hidePassword,
            autofillHints: const [AutofillHints.newPassword],
          ),
          const SizedBox(height: 18),
          PillButton(
            label: hasPassword ? l10n.changePassword : l10n.setPassword,
            loading: _busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
