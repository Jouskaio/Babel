import 'dart:async';

import 'dart:convert';
import 'dart:io';

import 'package:babel_api_client/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';

import '../../../core/api/api_providers.dart';
import '../../../core/storage/local_database.dart';
import '../../library/presentation/library_page.dart' show libraryCoverUrl;
import '../../reader/application/reading_position.dart';

/// The audiobook being listened to.
@immutable
class NowPlaying {
  const NowPlaying({required this.item, required this.playback});
  final LibraryItemResponse item;
  final PlaybackResponse playback;

  double get duration => playback.duration.toDouble();

  /// The chapter at [seconds], if the book has chapters.
  AudioChapterResponse? chapterAt(double seconds) {
    for (final chapter in playback.chapters) {
      if (seconds >= chapter.start && seconds < chapter.end) return chapter;
    }
    return playback.chapters.lastOrNull;
  }
}

/// How the player should stop: after some time, or at the end of the chapter.
sealed class SleepTimer {
  const SleepTimer();
}

class SleepAt extends SleepTimer {
  const SleepAt(this.time);
  final DateTime time;
}

class SleepAtChapterEnd extends SleepTimer {
  const SleepAtChapterEnd(this.end);
  final double end;
}

/// Whether a book was downloaded for offline listening.
final audioOfflineProvider = FutureProvider.family<bool, String>((
  ref,
  itemId,
) async {
  final db = await ref.watch(localDatabaseProvider.future);
  return db != null &&
      await LocalStores.meta.record('audio-offline:$itemId').get(db) == true;
});

/// The one audio player of the app: it keeps playing while the reader moves around the
/// app (a mini player shows it), and on the lock screen. Positions are saved like reading
/// positions (synced, offline too) and sent to Audiobookshelf.
final audioSessionProvider = NotifierProvider<AudioSession, NowPlaying?>(
  AudioSession.new,
);

class AudioSession extends Notifier<NowPlaying?> {
  static const _saveEvery = Duration(seconds: 15);

  AudioPlayer? _player;
  Timer? _saver;
  Timer? _sleeper;
  StreamSubscription<Object?>? _watch;

  /// The sleep timer set, if any.
  final sleep = ValueNotifier<SleepTimer?>(null);

  AudioPlayer get player => _player ??= AudioPlayer();

  @override
  NowPlaying? build() {
    ref.onDispose(() {
      _saver?.cancel();
      _sleeper?.cancel();
      _watch?.cancel();
      _player?.dispose();
    });
    return null;
  }

  /// Where the listener is in the whole book, in seconds.
  double get position {
    final now = state;
    if (now == null) return 0;
    final index = player.currentIndex ?? 0;
    final tracks = now.playback.tracks;
    final start = index < tracks.length ? tracks[index].start.toDouble() : 0.0;
    return start + player.position.inMilliseconds / 1000;
  }

  /// Opens [item] where it was left: the latest of this app's positions and
  /// Audiobookshelf's own (other apps). Already open: nothing changes.
  Future<void> open(LibraryItemResponse item) async {
    if (state?.item.id == item.id) return;
    await _saveNow();
    final positions = ref.read(readingPositionsProvider);
    final refreshed = positions
        .refresh(); // what the other devices did, meanwhile
    final playback = await _playbackOf(item);
    await refreshed;
    final saved = await positions.latest(item.id);
    var start = saved == null
        ? 0.0
        : ReadingLocator.parse(saved.locator)?.seconds ?? 0.0;
    final remote = playback.remotePosition;
    if (remote != null &&
        (saved == null || remote.updatedAt.isAfter(saved.time))) {
      start = remote.currentTime.toDouble();
    }
    final cover = libraryCoverUrl(item);
    final dir = kIsWeb ? null : await getApplicationSupportDirectory();
    _tracks = [
      for (final track in playback.tracks)
        _source(
          Uri.parse(apiUrl(track.path)),
          dir == null
              ? null
              : File('${dir.path}/audio/${item.id}-${track.index}.cache'),
          MediaItem(
            id: '${item.id}:${track.index}',
            title: item.title,
            artist: item.authors.join(', '),
            album: item.title,
            artUri: cover == null ? null : Uri.parse(cover),
            duration: Duration(milliseconds: (track.duration * 1000).round()),
          ),
        ),
    ];
    final sources = _tracks;
    final (index, offset) = _locate(playback.tracks, start);
    await player.setAudioSources(
      sources,
      initialIndex: index,
      initialPosition: offset,
    );
    state = NowPlaying(item: item, playback: playback);
    unawaited(_watch?.cancel());
    _watch = player.playerStateStream.listen((s) {
      if (s.playing) {
        _saver ??= Timer.periodic(_saveEvery, (_) => _saveNow());
      } else {
        _saver?.cancel();
        _saver = null;
        unawaited(_saveNow());
      }
      if (s.processingState == ProcessingState.completed) {
        unawaited(_saveNow(finished: true));
      }
      _checkSleep();
    });
  }

  (int, Duration) _locate(List<AudioTrackResponse> tracks, double seconds) {
    for (var i = 0; i < tracks.length; i++) {
      final start = tracks[i].start.toDouble();
      final end = start + tracks[i].duration.toDouble();
      if (seconds < end || i == tracks.length - 1) {
        final local = (seconds - start).clamp(0, tracks[i].duration.toDouble());
        return (i, Duration(milliseconds: (local * 1000).round()));
      }
    }
    return (0, Duration.zero);
  }

  Future<void> play() => player.play();

  Future<void> pause() => player.pause();

  Future<void> seekTo(double seconds) async {
    final now = state;
    if (now == null) return;
    final clamped = seconds.clamp(0, now.duration).toDouble();
    final (index, offset) = _locate(now.playback.tracks, clamped);
    await player.seek(offset, index: index);
  }

  Future<void> skip(double seconds) => seekTo(position + seconds);

  Future<void> setSpeed(double speed) => player.setSpeed(speed);

  /// Stops after [minutes], at the end of the chapter (null minutes), or never (0).
  void setSleep(int? minutes) {
    _sleeper?.cancel();
    final now = state;
    if (minutes == 0 || now == null) {
      sleep.value = null;
      return;
    }
    if (minutes == null) {
      final chapter = now.chapterAt(position);
      sleep.value = chapter == null
          ? null
          : SleepAtChapterEnd(chapter.end.toDouble());
      _sleeper = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _checkSleep(),
      );
      return;
    }
    sleep.value = SleepAt(DateTime.now().add(Duration(minutes: minutes)));
    _sleeper = Timer.periodic(const Duration(seconds: 1), (_) => _checkSleep());
  }

  void _checkSleep() {
    final timer = sleep.value;
    final due = switch (timer) {
      SleepAt(:final time) => DateTime.now().isAfter(time),
      SleepAtChapterEnd(:final end) => position >= end,
      null => false,
    };
    if (!due) return;
    _sleeper?.cancel();
    sleep.value = null;
    unawaited(pause());
  }

  /// Saves where the listener is: as a reading position (synced) and in Audiobookshelf.
  Future<void> _saveNow({bool finished = false}) async {
    final now = state;
    if (now == null || !ref.mounted) return;
    final seconds = finished ? now.duration : position;
    final percent = now.duration == 0 ? 0.0 : seconds / now.duration * 100;
    await ref
        .read(readingPositionsProvider)
        .save(now.item.id, ReadingLocator.audio(seconds), percent);
    try {
      await ref
          .read(audiobooksApiProvider)
          .saveAudioProgress(
            now.item.id,
            AudioProgressRequest(
              currentTime: seconds,
              finished: finished || percent >= 99.5,
            ),
          );
    } on ApiException {
      // Offline or Audiobookshelf away: the synced position is enough for Babel.
    }
  }

  List<AudioSource> _tracks = const [];

  /// A track kept on the device as it plays (not on the web, which cannot keep files).
  // ponytail: LockCachingAudioSource is experimental in just_audio; if it changes, keep
  // tracks with a plain download to the same path.
  // ignore: experimental_member_use
  static AudioSource _source(Uri uri, File? cache, MediaItem tag) {
    if (cache == null) return AudioSource.uri(uri, tag: tag);
    cache.parent.createSync(recursive: true);
    // ignore: experimental_member_use
    return LockCachingAudioSource(uri, cacheFile: cache, tag: tag);
  }

  /// What the player needs, from the server, kept for opening the book without network.
  Future<PlaybackResponse> _playbackOf(LibraryItemResponse item) async {
    final db = await ref.read(localDatabaseProvider.future);
    final cache = LocalStores.meta.record('playback:${item.id}');
    try {
      final playback = await ref
          .read(audiobooksApiProvider)
          .getPlayback(item.id);
      if (playback == null) throw const FormatException('no playback');
      if (db != null) await cache.put(db, jsonDecode(jsonEncode(playback)));
      return playback;
    } on ApiException catch (error) {
      final kept = db == null ? null : await cache.get(db);
      if (error.innerException == null || kept == null) rethrow;
      return PlaybackResponse.fromJson(kept)!;
    }
  }

  /// Downloads every track of the open book, to listen without network. [onProgress]
  /// goes from 0 to 1.
  Future<void> download(void Function(double) onProgress) async {
    final now = state;
    if (now == null) return;
    // ignore: experimental_member_use
    final cached = _tracks.whereType<LockCachingAudioSource>().toList();
    for (final (i, source) in cached.indexed) {
      onProgress(i / cached.length);
      await (await source.request()).stream.drain<void>();
    }
    onProgress(1);
    final db = await ref.read(localDatabaseProvider.future);
    if (db != null) {
      await LocalStores.meta
          .record('audio-offline:${now.item.id}')
          .put(db, true);
    }
    ref.invalidate(audioOfflineProvider(now.item.id));
  }

  /// Stops and forgets the audiobook (the mini player goes away).
  Future<void> close() async {
    await _saveNow();
    await player.stop();
    _sleeper?.cancel();
    sleep.value = null;
    state = null;
  }
}
