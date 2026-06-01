import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunning_ui/stunning_ui.dart';

Widget _host(Widget child) => MaterialApp(
  theme: StunningTheme.dark().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('StunningSelect shows the value, opens, and selects an item', (
    WidgetTester tester,
  ) async {
    String? picked;

    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 240,
          child: StatefulBuilder(
            builder:
                (context, setState) => StunningSelect<String>(
                  items: const <String>['Alpha', 'Beta', 'Gamma'],
                  value: 'Alpha',
                  onChanged: (v) => setState(() => picked = v),
                ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Trigger shows the selected value.
    expect(find.text('Alpha'), findsOneWidget);

    // Open the overlay menu.
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.text('Beta'), findsOneWidget);

    // Select another item.
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(picked, 'Beta');
  });

  testWidgets('StunningDivider renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(const SizedBox(width: 120, child: StunningDivider())),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StunningDivider), findsOneWidget);
  });

  testWidgets('StunningPagination advances on Next', (
    WidgetTester tester,
  ) async {
    var page = 0;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder:
              (context, setState) => StunningPagination(
                pageCount: 5,
                currentPage: page,
                onPageChanged: (p) => setState(() => page = p),
              ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(page, 1);
  });
}
