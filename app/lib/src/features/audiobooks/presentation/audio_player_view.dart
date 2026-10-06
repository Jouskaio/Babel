import 'package:babel_api_client/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/theme/babel_colors.dart';
import '../../../core/theme/babel_text.dart';
import '../../../core/widgets/book_cover.dart';
import '../../../l10n.dart';
import '../../../routing/router.dart';
import '../../library/presentation/library_page.dart' show libraryCoverUrl;
import '../application/audio_session.dart';
import '../application/audiobooks_providers.dart';

const _speeds = [0.8, 1.0, 1.2, 1.5, 1.75, 2.0];

/// Listening to an audiobook: cover, chapter, position, controls, speed, sleep timer.
class AudioPlayerView extends ConsumerStatefulWidget {
  const AudioPlayerView({required this.item, required this.onBack, super.key});
  final LibraryItemResponse item;
  final VoidCallback onBack;

  @override
  ConsumerState<AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends ConsumerState<AudioPlayerView> {
  late final Future<void> _opening = ref
      .read(audioSessionProvider.notifier)
      .open(widget.item);
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: BabelColors.canvas,
      appBar: AppBar(
        backgroundColor: BabelColors.canvas,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down, color: BabelColors.textPrimary),
          onPressed: widget.onBack,
        ),
      ),
      body: FutureBuilder<void>(
        future: _opening,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.playerError,
                  textAlign: TextAlign.center,
                  style: BabelText.body(15),
                ),
              ),
            );
          }
          final now = ref.watch(audioSessionProvider);
          if (snapshot.connectionState != ConnectionState.done || now == null) {
            return Center(
              child: CircularProgressIndicator(color: BabelColors.gold),
            );
          }
          return _player(context, now);
        },
      ),
    );
  }

  Widget _player(BuildContext context, NowPlaying now) {
    final l10n = context.l10n;
    final session = ref.read(audioSessionProvider.notifier);
    final player = session.player;
    final item = now.item;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
          children: [
            Center(
              child: BookCover(
                width: 220,
                url: libraryCoverUrl(item),
                title: item.title,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: BabelText.title(32),
            ),
            Text(
              [
                if (item.authors.isNotEmpty) item.authors.join(', '),
                if (now.playback.narrators.isNotEmpty)
                  l10n.narratedBy(now.playback.narrators.join(', ')),
              ].join(' · '),
              textAlign: TextAlign.center,
              style: BabelText.body(14),
            ),
            const SizedBox(height: 24),
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, _) {
                final at = _dragging ?? session.position;
                final chapter = now.chapterAt(at);
                return Column(
                  children: [
                    if (chapter != null)
                      Text(
                        chapter.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: BabelText.label(10),
                      ),
                    Slider(
                      value: at.clamp(0, now.duration),
                      max: now.duration <= 0 ? 1 : now.duration,
                      activeColor: BabelColors.gold,
                      inactiveColor: BabelColors.sunken,
                      onChanged: (v) => setState(() => _dragging = v),
                      onChangeEnd: (v) async {
                        await session.seekTo(v);
                        if (mounted) setState(() => _dragging = null);
                      },
                    ),
                    Row(
                      children: [
                        Text(
                          clock(Duration(seconds: at.round())),
                          style: BabelText.label(10),
                        ),
                        const Spacer(),
                        Text(
                          '-${clock(Duration(seconds: (now.duration - at).round()))}',
                          style: BabelText.label(10),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: l10n.playerBack30,
                  iconSize: 34,
                  onPressed: () => session.skip(-30),
                  icon: Icon(Icons.replay_30, color: BabelColors.textPrimary),
                ),
                const SizedBox(width: 24),
                StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton.filled(
                      tooltip: playing ? l10n.playerPause : l10n.playerPlay,
                      iconSize: 40,
                      style: IconButton.styleFrom(
                        backgroundColor: BabelColors.textPrimary,
                        foregroundColor: BabelColors.canvas,
                        fixedSize: const Size(76, 76),
                      ),
                      onPressed: playing ? session.pause : session.play,
                      icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                    );
                  },
                ),
                const SizedBox(width: 24),
                IconButton(
                  tooltip: l10n.playerForward30,
                  iconSize: 34,
                  onPressed: () => session.skip(30),
                  icon: Icon(Icons.forward_30, color: BabelColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                StreamBuilder<double>(
                  stream: player.speedStream,
                  builder: (context, snapshot) => _Chip(
                    icon: Icons.speed,
                    label: '×${_speed(snapshot.data ?? 1)}',
                    onTap: () => _chooseSpeed(context, session),
                  ),
                ),
                ValueListenableBuilder<SleepTimer?>(
                  valueListenable: session.sleep,
                  builder: (context, timer, _) => _Chip(
                    icon: Icons.bedtime_outlined,
                    label: switch (timer) {
                      SleepAt(:final time) => l10n.sleepLeft(
                        clock(time.difference(DateTime.now())),
                      ),
                      SleepAtChapterEnd() => l10n.sleepEndOfChapter,
                      null => l10n.playerSleep,
                    },
                    selected: timer != null,
                    onTap: () => _chooseSleep(context, session),
                  ),
                ),
                if (now.playback.chapters.isNotEmpty)
                  _Chip(
                    icon: Icons.format_list_numbered,
                    label: l10n.playerChapters,
                    onTap: () => _chooseChapter(context, now, session),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _speed(double speed) =>
      speed == speed.roundToDouble() ? speed.toStringAsFixed(0) : '$speed';

  Future<void> _chooseSpeed(BuildContext context, AudioSession session) =>
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        backgroundColor: BabelColors.surface,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final speed in _speeds)
                ListTile(
                  title: Text('×${_speed(speed)}', style: BabelText.body(16)),
                  onTap: () {
                    Navigator.pop(context);
                    session.setSpeed(speed);
                  },
                ),
            ],
          ),
        ),
      );

  Future<void> _chooseSleep(BuildContext context, AudioSession session) {
    final l10n = context.l10n;
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      backgroundColor: BabelColors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (label, minutes) in [
              (l10n.sleepOff, 0),
              for (final m in [15, 30, 45, 60]) (l10n.sleepMinutes(m), m),
              (l10n.sleepEndOfChapter, null),
            ])
              ListTile(
                title: Text(label, style: BabelText.body(16)),
                onTap: () {
                  Navigator.pop(context);
                  session.setSleep(minutes);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseChapter(
    BuildContext context,
    NowPlaying now,
    AudioSession session,
  ) => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: BabelColors.surface,
    builder: (context) {
      final current = now.chapterAt(session.position);
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            for (final chapter in now.playback.chapters)
              ListTile(
                selected: chapter == current,
                selectedColor: BabelColors.gold,
                title: Text(chapter.title, style: BabelText.body(15)),
                trailing: Text(
                  clock(Duration(seconds: chapter.start.round())),
                  style: BabelText.label(10),
                ),
                onTap: () {
                  Navigator.pop(context);
                  session.seekTo(chapter.start.toDouble());
                },
              ),
          ],
        ),
      );
    },
  );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => ActionChip(
    avatar: Icon(
      icon,
      size: 16,
      color: selected ? BabelColors.canvas : BabelColors.gold,
    ),
    label: Text(label),
    labelStyle: BabelText.body(
      13,
      color: selected ? BabelColors.canvas : BabelColors.textPrimary,
    ),
    backgroundColor: selected ? BabelColors.gold : BabelColors.surface,
    side: BorderSide(color: BabelColors.border),
    onPressed: onTap,
  );
}

/// The audiobook playing, above the navigation bar: play or pause, or open it.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(audioSessionProvider);
    if (now == null) return const SizedBox.shrink();
    final session = ref.read(audioSessionProvider.notifier);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: BabelColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: BabelColors.gold.withValues(alpha: 0.6)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(Routes.read(now.item.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
            child: Row(
              children: [
                Icon(Icons.headphones, size: 18, color: BabelColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    now.item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BabelText.heading(16),
                  ),
                ),
                StreamBuilder<PlayerState>(
                  stream: session.player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton(
                      tooltip: playing ? l10n.playerPause : l10n.playerPlay,
                      onPressed: playing ? session.pause : session.play,
                      icon: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: BabelColors.textPrimary,
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: session.close,
                  icon: Icon(Icons.close, color: BabelColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
