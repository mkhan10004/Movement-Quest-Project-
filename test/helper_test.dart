import 'package:flutter_test/flutter_test.dart';

import '../tool/helper_fixtures.dart';

void main() {
  for (final row in evaluateFixtures()) {
    test('helper ${row['case']}', () {
      expect(row['passed'], true, reason: row.toString());
    });
  }
}
