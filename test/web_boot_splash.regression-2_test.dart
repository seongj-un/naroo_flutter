import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('boot splash waits for the first Flutter frame before hiding', () {
    // Regression: ISSUE-001 — boot splash hid before Flutter painted, leaving a blank page
    // Found by /qa on 2026-06-02
    // Report: .gstack/qa-reports/qa-report-localhost-2026-06-02.md
    final indexHtml = File('web/index.html').readAsStringSync();

    expect(indexHtml, contains("'flutter-first-frame'"));
    expect(indexHtml, isNot(contains("querySelector('flutter-view')")));
    expect(indexHtml, isNot(contains('setTimeout(hideBootSplash')));
  });
}
