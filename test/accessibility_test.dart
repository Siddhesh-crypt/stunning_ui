import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunning_ui/stunning_ui.dart';

Widget _host(Widget child) => MaterialApp(
  theme: StunningTheme.dark().toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets(
    'StunningButton exposes an accessible, labeled, 48dp tap target',
    (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      var tapped = false;

      await tester.pumpWidget(
        _host(StunningButton(text: 'Submit', onPressed: () => tapped = true)),
      );

      // Screen-reader label + button role are present and enabled.
      expect(find.bySemanticsLabel('Submit'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Submit')),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: true),
      );

      // Meets minimum tap-target size and every tappable node has a label.
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      // Activates on tap.
      await tester.tap(find.text('Submit'));
      expect(tapped, isTrue);

      handle.dispose();
    },
  );

  testWidgets('A null onPressed renders a disabled (not enabled) button', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(const _DisabledHost());

    expect(
      tester.getSemantics(find.bySemanticsLabel('Disabled')),
      isSemantics(hasEnabledState: true, isEnabled: false),
    );

    handle.dispose();
  });

  testWidgets('Components honor reduce-motion (durations collapse to zero)', (
    WidgetTester tester,
  ) async {
    final theme = StunningTheme.gaming();
    expect(theme.motionDuration.inMilliseconds, greaterThan(0));

    await tester.pumpWidget(
      MaterialApp(
        theme: theme.toThemeData(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: _MotionProbe(),
        ),
      ),
    );

    final probed = tester.state<_MotionProbeState>(find.byType(_MotionProbe));
    expect(probed.resolved, Duration.zero);
  });

  testWidgets('StunningSwitch exposes toggle semantics and a 48dp target', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();
    var value = true;

    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder:
              (context, setState) => StunningSwitch(
                value: value,
                onChanged: (v) => setState(() => value = v),
              ),
        ),
      ),
    );

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    expect(
      tester.getSemantics(find.byType(StunningSwitch)),
      isSemantics(hasToggledState: true, isToggled: true),
    );

    await tester.tap(find.byType(StunningSwitch));
    await tester.pumpAndSettle();
    expect(value, isFalse);

    handle.dispose();
  });

  testWidgets('StunningTabs marks the selected tab and activates on tap', (
    WidgetTester tester,
  ) async {
    final handle = tester.ensureSemantics();
    int? picked;

    await tester.pumpWidget(
      _host(
        SizedBox(
          width: 320,
          child: StunningTabs(
            tabs: const <String>['Overview', 'Activity', 'Settings'],
            selectedIndex: 1,
            onChanged: (i) => picked = i,
          ),
        ),
      ),
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Activity')),
      isSemantics(isSelected: true),
    );

    await tester.tap(find.bySemanticsLabel('Overview'));
    expect(picked, 0);

    handle.dispose();
  });
}

class _DisabledHost extends StatelessWidget {
  const _DisabledHost();
  @override
  Widget build(BuildContext context) =>
      _host(const StunningButton(text: 'Disabled', onPressed: null));
}

class _MotionProbe extends StatefulWidget {
  const _MotionProbe();
  @override
  State<_MotionProbe> createState() => _MotionProbeState();
}

class _MotionProbeState extends State<_MotionProbe> {
  Duration resolved = const Duration(days: 1);
  @override
  Widget build(BuildContext context) {
    resolved = StunningTheme.of(context).motion(context);
    return const SizedBox();
  }
}
