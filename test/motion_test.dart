import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunning_ui/stunning_ui.dart';

Widget _host(Widget child, {bool reduceMotion = false}) {
  final app = MaterialApp(
    theme: StunningTheme.gaming().toThemeData(),
    home: Scaffold(body: Center(child: child)),
  );
  if (!reduceMotion) return app;
  return MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: app,
  );
}

double _minOpacity(WidgetTester tester) => tester
    .widgetList<Opacity>(find.byType(Opacity))
    .map((o) => o.opacity)
    .fold<double>(1.0, (a, b) => a < b ? a : b);

void main() {
  test('StunningSpring.toSpring() produces a valid SpringDescription', () {
    final SpringDescription s =
        const StunningSpring(durationMs: 400, bounce: 0.3).toSpring();
    expect(s.mass, greaterThan(0));
    expect(s.stiffness, greaterThan(0));
    expect(s.damping, greaterThan(0));
  });

  testWidgets('springIn starts hidden and settles fully visible',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(const Text('hi').stunning().springIn()));

    // First frame: still animating in (not yet fully opaque).
    await tester.pump();
    expect(_minOpacity(tester), lessThan(1.0));

    // Settles to fully visible.
    await tester.pumpAndSettle();
    expect(find.text('hi'), findsOneWidget);
    expect(_minOpacity(tester), 1.0);
  });

  testWidgets('springIn honors reduce-motion (instant, no animation)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(const Text('hi').stunning().springIn(), reduceMotion: true),
    );
    await tester.pump();
    // Already fully visible without settling — no animation ran.
    expect(_minOpacity(tester), 1.0);
  });

  testWidgets('glow and tilt compose without error and render the child',
      (WidgetTester tester) async {
    await tester.pumpWidget(_host(
      const SizedBox(width: 120, height: 80, child: Text('card'))
          .stunning()
          .glow()
          .tilt()
          .springIn(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('card'), findsOneWidget);
  });

  test('stunningStagger wraps every child as a Stunning effect', () {
    final List<Widget> staggered =
        <Widget>[const Text('a'), const Text('b'), const Text('c')]
            .stunningStagger();
    expect(staggered.length, 3);
    expect(staggered.every((w) => w is Stunning), isTrue);
  });
}
