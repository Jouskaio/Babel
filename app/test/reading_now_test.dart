import 'package:babel/src/features/home/presentation/home_sections.dart';
import 'package:babel_api_client/api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_server.dart';

LibraryItemResponse reading(String id, String time, {num progress = 20}) =>
    LibraryItemResponse.fromJson({
      ...libraryItem(id, 'Book $id'),
      'status': 'reading',
      'progress': progress,
      'state_time': time,
    })!;

void main() {
  test('every book being read is listed, the latest opened first', () {
    final list = readingNow([
      reading('a', '2026-10-01T10:00:00Z'),
      reading('b', '2026-10-03T10:00:00Z'),
      reading('c', '2026-10-02T10:00:00Z'),
      reading('d', '2026-10-04T10:00:00Z', progress: 0), // not started
    ], const {});
    expect([for (final i in list) i.id], ['b', 'c', 'a']);
  });
}
