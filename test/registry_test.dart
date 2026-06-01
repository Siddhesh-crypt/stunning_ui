import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import '../tool/build_registry.dart';

void main() {
  test('registry.json is in sync with the public exports', () {
    final committedFile = File('registry.json');
    expect(
      committedFile.existsSync(),
      isTrue,
      reason: 'registry.json missing — run `dart run tool/build_registry.dart`',
    );

    final committed =
        jsonDecode(committedFile.readAsStringSync()) as Map<String, dynamic>;
    final fresh = buildRegistry(packageRoot: '.');

    final committedNames =
        (committed['components'] as List<dynamic>)
            .map((c) => (c as Map<String, dynamic>)['name'])
            .toList();
    final freshNames =
        (fresh['components'] as List<dynamic>)
            .map((c) => (c as Map<String, dynamic>)['name'])
            .toList();

    expect(
      committedNames,
      freshNames,
      reason:
          'Component registry drifted — re-run `dart run tool/build_registry.dart`',
    );
    expect(committed['componentCount'], fresh['componentCount']);
  });
}
