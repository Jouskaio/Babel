import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final readerTextSizeProvider = NotifierProvider<ReaderTextSize, double>(
  ReaderTextSize.new,
);

/// Size of the book text, kept on this device.
class ReaderTextSize extends Notifier<double> {
  static const _key = 'babel.reader.text_size';
  static const min = 14.0;
  static const max = 30.0;
  static const initial = 19.0;

  @override
  double build() {
    _load();
    return initial;
  }

  Future<void> _load() async {
    final saved = await SharedPreferencesAsync().getDouble(_key);
    if (saved != null) state = saved.clamp(min, max);
  }

  Future<void> set(double size) async {
    state = size.clamp(min, max);
    await SharedPreferencesAsync().setDouble(_key, state);
  }
}
