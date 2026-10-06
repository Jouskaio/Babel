import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/display/eink.dart';
import '../../../core/theme/babel_colors.dart';

/// Colors of the reading screen.
enum ReaderTheme {
  night(BabelPalette.midnight),
  day(
    BabelPalette(
      dark: false,
      canvas: Color(0xFFFBF8F1),
      surface: Color(0xFFFFFFFF),
      sunken: Color(0xFFF1ECE2),
      border: Color(0xFFD9D0C1),
      textPrimary: Color(0xFF1F1A14),
      textSecondary: Color(0xFF6B5E4E),
      gold: Color(0xFF8E6A2C),
      velvet: Color(0xFF7D2638),
      dustyRose: Color(0xFFA55F62),
      forest: Color(0xFFDDEBDD),
    ),
  ),
  sepia(
    BabelPalette(
      dark: false,
      canvas: Color(0xFFF4ECD8),
      surface: Color(0xFFFAF4E4),
      sunken: Color(0xFFEADFC6),
      border: Color(0xFFD3C4A2),
      textPrimary: Color(0xFF3B2F22),
      textSecondary: Color(0xFF6E5B43),
      gold: Color(0xFF85632A),
      velvet: Color(0xFF7D2638),
      dustyRose: Color(0xFF9C5B5D),
      forest: Color(0xFFDCE5CF),
    ),
  );

  const ReaderTheme(this.palette);
  final BabelPalette palette;
}

/// Typefaces for book text. Lexend and Atkinson Hyperlegible were designed for readers
/// with dyslexia and low vision.
enum ReaderFont {
  literata('Literata'),
  sans('Inter'),
  lexend('Lexend'),
  atkinson('Atkinson Hyperlegible');

  const ReaderFont(this.family);
  final String family;

  TextStyle style(TextStyle base) =>
      GoogleFonts.getFont(family, textStyle: base);
}

/// Space between lines.
enum ReaderSpacing {
  compact(1.45),
  normal(1.6),
  airy(1.9);

  const ReaderSpacing(this.height);
  final double height;
}

/// Continuous scrolling, or one screen at a time like turning pages.
enum ReaderLayout { scroll, pages }

@immutable
class ReaderSettings {
  const ReaderSettings({
    this.textSize = initialSize,
    this.theme = ReaderTheme.night,
    this.font = ReaderFont.literata,
    this.spacing = ReaderSpacing.normal,
    this.layout = ReaderLayout.scroll,
    this.readerNotes = true,
  });

  static const minSize = 14.0;
  static const maxSize = 30.0;
  static const initialSize = 19.0;

  final double textSize;
  final ReaderTheme theme;
  final ReaderFont font;
  final ReaderSpacing spacing;
  final ReaderLayout layout;

  /// Show the notes other readers shared, in the text and in the margin.
  final bool readerNotes;

  ReaderSettings copyWith({
    double? textSize,
    ReaderTheme? theme,
    ReaderFont? font,
    ReaderSpacing? spacing,
    ReaderLayout? layout,
    bool? readerNotes,
  }) => ReaderSettings(
    textSize: textSize ?? this.textSize,
    theme: theme ?? this.theme,
    font: font ?? this.font,
    spacing: spacing ?? this.spacing,
    layout: layout ?? this.layout,
    readerNotes: readerNotes ?? this.readerNotes,
  );

  /// The palette while reading: on e-ink always black on white.
  BabelPalette palette({required bool eink}) =>
      eink ? BabelPalette.paper : theme.palette;

  /// Style of the book text.
  TextStyle textStyle(Color color) => font.style(
    TextStyle(fontSize: textSize, height: spacing.height, color: color),
  );

  @override
  bool operator ==(Object other) =>
      other is ReaderSettings &&
      other.textSize == textSize &&
      other.theme == theme &&
      other.font == font &&
      other.spacing == spacing &&
      other.layout == layout &&
      other.readerNotes == readerNotes;

  @override
  int get hashCode =>
      Object.hash(textSize, theme, font, spacing, layout, readerNotes);
}

final readerSettingsProvider =
    NotifierProvider<ReaderSettingsController, ReaderSettings>(
      ReaderSettingsController.new,
    );

/// Reading preferences, kept on this device. E-readers read in pages by default.
class ReaderSettingsController extends Notifier<ReaderSettings> {
  static const _prefix = 'babel.reader.';

  @override
  ReaderSettings build() {
    _load();
    return ReaderSettings(
      layout: ref.read(einkDisplayProvider).active
          ? ReaderLayout.pages
          : ReaderLayout.scroll,
    );
  }

  Future<void> _load() async {
    try {
      final prefs = SharedPreferencesAsync();
      T? pick<T extends Enum>(List<T> values, String? name) =>
          name == null ? null : values.asNameMap()[name];
      // Read everything first: the state only exists once build has returned.
      final textSize = await prefs.getDouble('${_prefix}text_size');
      final theme = await prefs.getString('${_prefix}theme');
      final font = await prefs.getString('${_prefix}font');
      final spacing = await prefs.getString('${_prefix}spacing');
      final layout = await prefs.getString('${_prefix}layout');
      final readerNotes = await prefs.getBool('${_prefix}reader_notes');
      if (!ref.mounted) return;
      final loaded = state.copyWith(
        textSize: textSize?.clamp(
          ReaderSettings.minSize,
          ReaderSettings.maxSize,
        ),
        theme: pick(ReaderTheme.values, theme),
        font: pick(ReaderFont.values, font),
        spacing: pick(ReaderSpacing.values, spacing),
        layout: pick(ReaderLayout.values, layout),
        readerNotes: readerNotes,
      );
      state = loaded;
    } on Object catch (error) {
      debugPrint('Reader settings not loaded: $error');
    }
  }

  Future<void> setTextSize(double size) async {
    state = state.copyWith(
      textSize: size.clamp(ReaderSettings.minSize, ReaderSettings.maxSize),
    );
    await SharedPreferencesAsync().setDouble(
      '${_prefix}text_size',
      state.textSize,
    );
  }

  Future<void> setTheme(ReaderTheme theme) => _save('theme', theme, () {
    state = state.copyWith(theme: theme);
  });

  Future<void> setFont(ReaderFont font) => _save('font', font, () {
    state = state.copyWith(font: font);
  });

  Future<void> setSpacing(ReaderSpacing spacing) =>
      _save('spacing', spacing, () => state = state.copyWith(spacing: spacing));

  Future<void> setLayout(ReaderLayout layout) =>
      _save('layout', layout, () => state = state.copyWith(layout: layout));

  Future<void> setReaderNotes(bool show) async {
    state = state.copyWith(readerNotes: show);
    await SharedPreferencesAsync().setBool('${_prefix}reader_notes', show);
  }

  Future<void> _save(String key, Enum value, void Function() apply) async {
    apply();
    await SharedPreferencesAsync().setString('$_prefix$key', value.name);
  }
}
