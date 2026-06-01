import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunning_ui/stunning_ui.dart';

Widget _host(Widget child) => MaterialApp(
      theme: StunningTheme.dark().toThemeData(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('StunningDialog renders title and message',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const StunningDialog(
      title: 'Delete file?',
      message: 'This cannot be undone.',
    )));
    await tester.pumpAndSettle();
    expect(find.text('Delete file?'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);
  });

  testWidgets('showStunningDialog opens a titled dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: StunningTheme.dark().toThemeData(),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: StunningButton(
              text: 'open',
              onPressed: () => showStunningDialog<void>(
                context: context,
                title: 'Saved',
                message: 'All good.',
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('StunningBadge standalone shows its label',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const StunningBadge(label: '9+', standalone: true)));
    await tester.pumpAndSettle();
    expect(find.text('9+'), findsOneWidget);
  });

  testWidgets('StunningAvatar shows the initials fallback',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const StunningAvatar(initials: 'SL')));
    await tester.pumpAndSettle();
    expect(find.text('SL'), findsOneWidget);
  });

  testWidgets('StunningTooltip wraps its child', (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      const StunningTooltip(message: 'More info', child: Icon(Icons.info_outline)),
    ));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
  });

  testWidgets('Progress bar and ring build (determinate)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(width: 200, child: StunningProgressBar(value: 0.4)),
        SizedBox(height: 20),
        StunningProgressRing(value: 0.6),
      ],
    )));
    await tester.pumpAndSettle();
    expect(find.byType(StunningProgressBar), findsOneWidget);
    expect(find.byType(StunningProgressRing), findsOneWidget);
  });
}
