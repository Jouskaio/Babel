import 'package:babel/src/core/update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final release = AppRelease.fromJson({
    'version': '0.50.0',
    'build': 78,
    'released': '2026-10-11',
    'notes': ['Un', 'Deux'],
    'notes_en': ['One', 'Two'],
    'android': {'url': '/downloads/Babel-0.50.0.apk', 'size': 1048576},
    'macos': null,
  });

  test('reads what the release workflow writes', () {
    expect(release.version, '0.50.0');
    expect(release.notesFor('fr'), ['Un', 'Deux']);
    expect(release.notesFor('en'), ['One', 'Two']);
    expect(release.android?.url, '/downloads/Babel-0.50.0.apk');
    expect(release.macos, isNull);
  });

  test('only a newer build is an update', () {
    expect(isNewer(release, 77), isTrue);
    expect(isNewer(release, 78), isFalse);
    expect(isNewer(release, 0), isFalse); // unknown installed build: stay quiet
  });
}
