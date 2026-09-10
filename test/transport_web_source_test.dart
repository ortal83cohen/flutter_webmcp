import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web transport retains its detection-only contract', () {
    final String source = File('lib/src/transport/transport_web.dart')
        .readAsStringSync();
    expect(source, contains('web-detection'));
    expect(source, contains('not published'));
  });
}
