import 'dart:convert';
import 'dart:io';

import 'helper_fixtures.dart';

void main() {
  final cases = evaluateFixtures();
  final valid = cases.where((c) => c['preference_label'] != null).toList();
  final report = {
    'fixture_clock_utc': '2026-10-22T12:00:00Z',
    'fixture_type': 'Synthetic convenience preference labels',
    'cases': cases,
    'metric': {
      'n': valid.length,
      'helper_matches': valid.where((c) => c['helper_match'] == true).length,
      'baseline_matches': valid
          .where((c) => c['baseline_match'] == true)
          .length,
    },
    'limitation': 'Small hand-authored fixtures; not a user study, health measure or held-out ML evaluation.',
  };
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
  if (cases.any((c) => c['passed'] != true)) exitCode = 1;
}
