import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunning_ui/stunning_ui.dart';

Widget _host(Widget child) => MaterialApp(
      theme: StunningTheme.dark().toThemeData(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('StunningCheckbox toggles, has toggle semantics + 48dp target',
      (WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    var value = false;

    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, setState) => StunningCheckbox(
        value: value,
        semanticLabel: 'Accept',
        onChanged: (v) => setState(() => value = v),
      ),
    )));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.bySemanticsLabel('Accept')),
      isSemantics(hasToggledState: true, isToggled: false),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    await tester.tap(find.bySemanticsLabel('Accept'));
    await tester.pumpAndSettle();
    expect(value, isTrue);

    handle.dispose();
  });

  testWidgets('StunningRadio selects and reports selected semantics',
      (WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    int? group = 1;

    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StunningRadio<int>(
            value: 0,
            groupValue: group,
            semanticLabel: 'Option A',
            onChanged: (v) => setState(() => group = v),
          ),
          StunningRadio<int>(
            value: 1,
            groupValue: group,
            semanticLabel: 'Option B',
            onChanged: (v) => setState(() => group = v),
          ),
        ],
      ),
    )));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.bySemanticsLabel('Option B')),
      isSemantics(isSelected: true),
    );

    await tester.tap(find.bySemanticsLabel('Option A'));
    await tester.pumpAndSettle();
    expect(group, 0);

    handle.dispose();
  });

  testWidgets('StunningSlider builds and a drag updates the value',
      (WidgetTester tester) async {
    var value = 0.5;

    await tester.pumpWidget(_host(SizedBox(
      width: 240,
      child: StatefulBuilder(
        builder: (context, setState) => StunningSlider(
          value: value,
          onChanged: (v) => setState(() => value = v),
        ),
      ),
    )));
    await tester.pumpAndSettle();

    expect(find.byType(StunningSlider), findsOneWidget);
    await tester.drag(find.byType(StunningSlider), const Offset(80, 0));
    await tester.pumpAndSettle();
    expect(value, greaterThan(0.5));
  });
}
