import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunning_ui/stunning_ui.dart';

Widget _host(Widget child) => MaterialApp(
      theme: StunningTheme.dark().toThemeData(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('icon-only button is labeled, sized and activatable',
      (WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    var tapped = false;

    await tester.pumpWidget(_host(StunningButton(
      icon: Icons.add,
      semanticLabel: 'Add item',
      onPressed: () => tapped = true,
    )));

    expect(find.bySemanticsLabel('Add item'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await tester.tap(find.byIcon(Icons.add));
    expect(tapped, isTrue);

    handle.dispose();
  });

  testWidgets('icon + text renders both', (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      StunningButton(icon: Icons.send, text: 'Send', onPressed: () {}),
    ));
    expect(find.byIcon(Icons.send), findsOneWidget);
    expect(find.text('Send'), findsOneWidget);
  });

  testWidgets('every variant and size builds', (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final v in StunningButtonVariant.values)
            StunningButton(
                text: v.name, variant: v, size: StunningButtonSize.large, onPressed: () {}),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(StunningButton),
        findsNWidgets(StunningButtonVariant.values.length));
  });

  testWidgets('custom child takes precedence', (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      StunningButton(
        onPressed: () {},
        child: const Text('custom'),
      ),
    ));
    expect(find.text('custom'), findsOneWidget);
  });
}
