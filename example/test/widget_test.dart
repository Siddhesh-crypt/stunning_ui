// Smoke test for the Stunning UI toolkit.
//
// Exercises the theme engine wiring and a core interactive component
// (StunningButton) end to end, without relying on the example app's
// network-backed background image.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunning_ui/stunning_ui.dart';

void main() {
  testWidgets(
    'StunningButton renders under StunningTheme and fires onPressed',
    (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            extensions: <ThemeExtension<dynamic>>[
              StunningTheme.generate(
                seedColor: Colors.cyanAccent,
                brightness: Brightness.dark,
                style: StunningUIStyle.gaming,
              ),
            ],
          ),
          home: Scaffold(
            body: Center(
              child: StunningButton(
                text: 'Tap me',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      // Label renders.
      expect(find.text('Tap me'), findsOneWidget);

      // Interaction wires through to the callback.
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    },
  );
}
