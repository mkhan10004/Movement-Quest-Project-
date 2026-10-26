import 'dart:convert';
import 'dart:io';

import 'helper_fixtures.dart';

void main() {
  final cases = evaluateFixtures();
  final valid = cases.where((c) => c['preference_label'] != null).toList();
  final report = {
    
