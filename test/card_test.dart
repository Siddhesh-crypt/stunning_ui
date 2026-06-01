import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunning_ui/stunning_ui.dart';

Widget _host(Widget child) => MaterialApp(
  theme: StunningTheme.gaming().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets(
    'StunningTiltCard renders its child (and is draggable for touch tilt)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(
          const StunningTiltCard(
            width: 220,
            height: 140,
            child: Text('Tilt me'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tilt me'), findsOneWidget);

      // Touch tilt: a drag over the card must not throw (pan handler is wired).
      await tester.drag(find.text('Tilt me'), const Offset(20, 12));
      await tester.pumpAndSettle();
      expect(find.text('Tilt me'), findsOneWidget);
    },
  );
}
