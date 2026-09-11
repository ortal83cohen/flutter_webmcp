import 'dart:async';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() {
  return integrationDriver(
    writeResponseOnFailure: true,
    responseDataCallback: (Map<String, dynamic>? data) {
      final evidence = data?['evidence'];
      if (evidence is List<dynamic>) {
        for (final line in evidence) {
          // Stable evidence is intentionally written to the command output.
          // ignore: avoid_print
          print(line);
        }
      }
    },
  );
}
