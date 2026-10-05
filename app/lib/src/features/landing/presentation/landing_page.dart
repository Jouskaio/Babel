import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/locale/language_picker.dart';
import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../application/trending_provider.dart';

/// Public landing page (design: Penpot "04 Landing & auth").
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Content scrolls under the status bar, but never starts behind it.
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 960;
            final gutter = wide ? 64.0 : 24.0;
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Nav(wide: wide, gutter: gutter),
                      _Hero(wide: wide, gutter: gutter),
                      _Features(wide: wide, gutter: gutter),
                      _Devices(wide: wide, gutter: gutter),
                      _Quote(wide: wide, gutter: gutter),
                      _CallToAction(wide: wide, gutter: gutter),
                      _Footer(gutter: gutter),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav({required this.wide, required this.gutter});
  final bool wide;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      // Phones get 16 px more at the top, below the status bar icons.
      padding: EdgeInsets.fromLTRB(
        gutter,
        wide ? 28 : 36,
        gutter,
        wide ? 28 : 20,
      ),
      child: Row(
        children: [
          Text(l10n.brand, style: BabelText.label(13, spacing: 6)),
          const Spacer(),
          const LanguagePicker(),
          const SizedBox(width: 12),
          PillButton(
            label: l10n.signIn,
            kind: PillButtonKind.secondary,
            onPressed: () => context.go(Routes.login),
          ),
          if (wide) ...[
            const SizedBox(width: 12),
            PillButton(
              label: l10n.createAccount,
              onPressed: () => context.go(Routes.signup),
            ),
          ],
        ],
      ),
    );
  }
}

class _Hero extends ConsumerWidget {
  const _Hero({required this.wide, required this.gutter});
  final bool wide;
  final double gutter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trending =
        ref.watch(trendingWorksProvider).value ??
        const <TrendingWorkResponse>[];
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.heroEyebrow.toUpperCase(),
          style: BabelText.label(wide ? 11 : 10, spacing: 2.4),
        ),
        const SizedBox(height: 24),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: l10n.heroTitleLead),
              TextSpan(
                text: l10n.heroTitleEmphasis,
                style: BabelText.title(wide ? 76 : 44, italic: true),
              ),
            ],
          ),
          style: BabelText.title(wide ? 76 : 44),
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Text(l10n.heroLede, style: BabelText.body(wide ? 18 : 16)),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            PillButton(
              label: l10n.startFree,
              large: true,
              expand: !wide,
              onPressed: () => context.go(Routes.signup),
            ),
            PillButton(
              label: l10n.haveAccount,
              kind: PillButtonKind.secondary,
              large: true,
              expand: !wide,
              onPressed: () => context.go(Routes.login),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          l10n.heroNote,
          style: BabelText.body(
            13,
            color: BabelColors.textSecondary.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
    final covers = _CoverFan(works: trending, scale: wide ? 1 : 0.6);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        gutter,
        wide ? 72 : 8,
        gutter,
        wide ? 72 : 24,
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: copy),
                Expanded(flex: 5, child: covers),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [covers, const SizedBox(height: 16), copy],
            ),
    );
  }
}

/// Three trending covers fanned out over a crimson glow, with the top one highlighted.
class _CoverFan extends StatelessWidget {
  const _CoverFan({required this.works, required this.scale});
  final List<TrendingWorkResponse> works;
  final double scale;

  @override
  Widget build(BuildContext context) {
    String? url(int i) => i < works.length ? apiUrl(works[i].coverPath) : null;
    String? title(int i) => i < works.length ? works[i].title : null;
    final s = scale;
    final top = works.isEmpty ? null : works.first;
    return SizedBox(
      height: 560 * s,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 560 * s,
            height: 560 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  BabelColors.velvet.withValues(alpha: 0.45),
                  BabelColors.velvet.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(-150 * s, 30 * s),
            child: BookCover(
              width: 200 * s,
              url: url(1),
              title: title(1),
              angle: -9,
            ),
          ),
          Transform.translate(
            offset: Offset(150 * s, 20 * s),
            child: BookCover(
              width: 200 * s,
              url: url(2),
              title: title(2),
              angle: 8,
            ),
          ),
          Transform.translate(
            offset: Offset(0, -10 * s),
            child: BookCover(
              width: 230 * s,
              url: url(0),
              title: title(0),
              angle: -1,
            ),
          ),
          if (top != null && s >= 1)
            Positioned(right: 0, bottom: 0, child: _TrendingCard(work: top)),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.work});
  final TrendingWorkResponse work;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: BabelColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x73000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.trendingLabel.toUpperCase(),
            style: BabelText.label(10, spacing: 1.6),
          ),
          const SizedBox(height: 10),
          Text(
            work.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: BabelText.heading(22),
          ),
          if (work.authors.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              work.authors.join(', '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BabelText.body(12),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.wide,
  });
  final String eyebrow;
  final String title;
  final bool wide;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        eyebrow.toUpperCase(),
        style: BabelText.label(wide ? 11 : 10, spacing: 2.4),
      ),
      const SizedBox(height: 16),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Text(title, style: BabelText.title(wide ? 52 : 34)),
      ),
    ],
  );
}

class _Features extends StatelessWidget {
  const _Features({required this.wide, required this.gutter});
  final bool wide;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = [
      (l10n.featureAllTitle, l10n.featureAllBody, BabelColors.gold),
      (l10n.featureSyncTitle, l10n.featureSyncBody, BabelColors.dustyRose),
      (l10n.featureNotesTitle, l10n.featureNotesBody, BabelColors.velvet),
      (l10n.featureStatsTitle, l10n.featureStatsBody, const Color(0xFF36584A)),
    ];
    Widget card((String, String, Color) item) => Container(
      padding: wide
          ? const EdgeInsets.fromLTRB(28, 32, 28, 32)
          : const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BabelColors.surface,
        borderRadius: BorderRadius.circular(wide ? 28 : 22),
        border: Border.all(color: BabelColors.border),
      ),
      child: Flex(
        direction: wide ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: wide
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: wide ? 36 : 28,
            height: wide ? 36 : 28,
            decoration: BoxDecoration(color: item.$3, shape: BoxShape.circle),
          ),
          SizedBox(width: 16, height: wide ? 24 : 0),
          Flexible(
            fit: wide ? FlexFit.loose : FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.$1, style: BabelText.heading(wide ? 26 : 20)),
                SizedBox(height: wide ? 14 : 4),
                Text(item.$2, style: BabelText.body(wide ? 15 : 13)),
              ],
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: gutter,
        vertical: wide ? 96 : 56,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeading(
            eyebrow: l10n.featuresEyebrow,
            title: l10n.featuresTitle,
            wide: wide,
          ),
          SizedBox(height: wide ? 48 : 20),
          if (wide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, item) in items.indexed) ...[
                    if (i > 0) const SizedBox(width: 24),
                    Expanded(child: card(item)),
                  ],
                ],
              ),
            )
          else
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: card(item),
              ),
        ],
      ),
    );
  }
}

class _Devices extends StatelessWidget {
  const _Devices({required this.wide, required this.gutter});
  final bool wide;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          eyebrow: l10n.devicesEyebrow,
          title: l10n.devicesTitle,
          wide: wide,
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(l10n.devicesBody, style: BabelText.body(wide ? 17 : 15)),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final platform in ['Kobo', 'Android', 'iPhone', 'Web'])
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: ShapeDecoration(
                  shape: StadiumBorder(
                    side: BorderSide(color: BabelColors.border),
                  ),
                ),
                child: Text(
                  platform.toUpperCase(),
                  style: BabelText.label(
                    11,
                    color: BabelColors.textPrimary,
                    spacing: 1.2,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
    final eReader = Container(
      width: 300,
      height: 400,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E4DA),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.deviceChapter.toUpperCase(),
            style: BabelText.label(9, color: const Color(0xFF3A3A3A)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              l10n.deviceExcerpt,
              overflow: TextOverflow.fade,
              style: BabelText.reading(14, color: const Color(0xFF1E1E1E)),
            ),
          ),
          Text(
            '64 %',
            style: BabelText.label(9, color: const Color(0xFF3A3A3A)),
          ),
        ],
      ),
    );
    return Container(
      color: BabelColors.surface,
      padding: EdgeInsets.symmetric(
        horizontal: gutter,
        vertical: wide ? 96 : 56,
      ),
      child: wide
          ? Row(
              children: [
                Expanded(child: copy),
                const SizedBox(width: 64),
                eReader,
              ],
            )
          : copy,
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.wide, required this.gutter});
  final bool wide;
  final double gutter;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: gutter,
      vertical: wide ? 120 : 48,
    ),
    child: Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Text(
            context.l10n.quote,
            textAlign: TextAlign.center,
            style: BabelText.reading(wide ? 30 : 20, italic: true),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.quoteAuthor.toUpperCase(),
          textAlign: TextAlign.center,
          style: BabelText.label(11),
        ),
      ],
    ),
  );
}

class _CallToAction extends StatelessWidget {
  const _CallToAction({required this.wide, required this.gutter});
  final bool wide;
  final double gutter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: wide ? 72 : 40),
        decoration: BoxDecoration(
          color: BabelColors.velvet,
          borderRadius: BorderRadius.circular(wide ? 36 : 28),
        ),
        child: Column(
          children: [
            Text(
              l10n.ctaTitle,
              textAlign: TextAlign.center,
              style: BabelText.title(wide ? 56 : 32),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.ctaBody,
              textAlign: TextAlign.center,
              style: BabelText.body(
                wide ? 17 : 15,
                color: BabelColors.textPrimary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 24),
            PillButton(
              label: l10n.createAccount,
              large: true,
              onPressed: () => context.go(Routes.signup),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.gutter});
  final double gutter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gutter, vertical: 48),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 32,
        runSpacing: 16,
        children: [
          Text(l10n.brand, style: BabelText.label(12, spacing: 6)),
          Text(
            '${l10n.footerPrivacy} · ${l10n.footerTerms} · ${l10n.footerContact}',
            style: BabelText.body(13),
          ),
          Text('© ${DateTime.now().year} Babel', style: BabelText.body(13)),
        ],
      ),
    );
  }
}
