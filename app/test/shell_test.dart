import 'package:babel/src/features/shell/app_shell.dart';
import 'package:babel/src/routing/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a page lights up the tab it belongs to', () {
    expect(branchOf(Routes.home), 0);
    expect(branchOf(Routes.search), 1);
    expect(branchOf(Routes.work('abc')), 1);
    expect(branchOf(Uri.parse(Routes.saga('Homunculus')).path), 1);
    expect(branchOf(Routes.library), 2);
    expect(branchOf(Routes.source('s1')), 2);
    expect(branchOf(Routes.profile), 3);
    expect(branchOf(Routes.stats), 3);
    expect(branchOf(Routes.wrap(2026)), 3);
    expect(branchOf(Routes.scan), isNull);
  });
}
