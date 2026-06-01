import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunning_ui/stunning_ui.dart';

Widget _host(Widget child, {bool highContrast = false}) {
  return MaterialApp(
    theme: StunningTheme.gaming().toThemeData(),
    home: Scaffold(
      body: Builder(
        builder: (context) {
          Widget c = Center(child: child);
          if (highContrast) {
            c = MediaQuery(
              data: MediaQuery.of(context).copyWith(highContrast: true),
              child: c,
            );
          }
          return c;
        },
      ),
    ),
  );
}

void main() {
  testWidgets('GlassSurface blurs by default and renders its child',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      const GlassSurface(child: Text('inside')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('inside'), findsOneWidget);
    // On non-Impeller backends (test env) it uses a BackdropFilter blur.
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('GlassSurface falls back to a solid surface under reduce-transparency',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      const GlassSurface(child: Text('inside')),
      highContrast: true,
    ));
    await tester.pumpAndSettle();
    expect(find.text('inside'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('.glass() composes in the .stunning() chain',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const Text('chain').stunning().glass()));
    await tester.pumpAndSettle();
    expect(find.text('chain'), findsOneWidget);
  });

  testWidgets('StunningGlassScope provides a BackdropGroup',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      const StunningGlassScope(child: GlassSurface(child: Text('x'))),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(BackdropGroup), findsOneWidget);
  });
}
