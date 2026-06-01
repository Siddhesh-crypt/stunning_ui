// Stunning UI — light/dark verification gallery.
//
// Renders the same components twice: a LIGHT minimal theme and a DARK gaming
// theme, side by side, so the M1 light-mode fix is visible at a glance. Uses
// the new one-line presets + toThemeData().
//
// Run:  flutter run -t lib/gallery.dart -d chrome
import 'package:flutter/material.dart';
import 'package:stunning_ui/stunning_ui.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Row(
          children: <Widget>[
            Expanded(
              child: _ThemedSide(
                label: 'LIGHT · minimal',
                theme: StunningTheme.light(
                    seedColor: const Color(0xFF6C5CE7),
                    style: StunningUIStyle.minimal),
              ),
            ),
            const VerticalDivider(width: 1, color: Colors.white24),
            Expanded(
              child: _ThemedSide(
                label: 'DARK · gaming',
                theme: StunningTheme.dark(
                    seedColor: const Color(0xFF22D3EE),
                    style: StunningUIStyle.gaming),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemedSide extends StatefulWidget {
  const _ThemedSide({required this.label, required this.theme});
  final String label;
  final StunningTheme theme;
  @override
  State<_ThemedSide> createState() => _ThemedSideState();
}

class _ThemedSideState extends State<_ThemedSide> {
  bool _switch = true;
  int _seg = 0;
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    // Wrap this subtree in its own ThemeData so StunningTheme.of() resolves the
    // correct (light or dark) engine per side.
    return Theme(
      data: widget.theme.toThemeData(),
      child: Builder(
        builder: (context) {
          final bg = Theme.of(context).scaffoldBackgroundColor;
          return Container(
            color: bg,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StunningTheme.of(context).textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Buttons — all three variants.
                  Row(
                    children: const <Widget>[
                      Expanded(
                          child: StunningButton(
                              text: 'Primary', onPressed: _noop)),
                      SizedBox(width: 10),
                      Expanded(
                          child: StunningButton(
                              text: 'Outline',
                              onPressed: _noop,
                              variant: StunningButtonVariant.outline)),
                      SizedBox(width: 10),
                      Expanded(
                          child: StunningButton(
                              text: 'Ghost',
                              onPressed: _noop,
                              variant: StunningButtonVariant.ghost)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Text field.
                  const StunningTextField(
                      hintText: 'Search…', prefixIcon: Icons.search),
                  const SizedBox(height: 16),

                  // Switch row.
                  Row(
                    children: <Widget>[
                      StunningSwitch(
                          value: _switch,
                          onChanged: (v) => setState(() => _switch = v)),
                      const SizedBox(width: 12),
                      Text('Enable notifications',
                          style: TextStyle(
                              color: StunningTheme.of(context).textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Segmented control.
                  StunningSegmentedControl(
                    options: const <String>['Trending', 'Recent', 'Top'],
                    selectedIndex: _seg,
                    onValueChanged: (i) => setState(() => _seg = i),
                  ),
                  const SizedBox(height: 16),

                  // Tabs.
                  StunningTabs(
                    tabs: const <String>['Overview', 'Activity', 'Settings'],
                    selectedIndex: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                  const SizedBox(height: 20),

                  // Bar chart.
                  const StunningBarChart(
                    data: <double>[12, 28, 18, 42],
                    labels: <String>['Jan', 'Feb', 'Mar', 'Apr'],
                    maxValue: 50,
                    height: 200,
                  ),
                  const SizedBox(height: 20),

                  // Accordion.
                  const StunningAccordion(
                    title: 'What is included?',
                    content: Text('Glass, glow and motion — all theme-driven.'),
                  ),
                  const SizedBox(height: 20),

                  // Data table with smart badges (semantic colours preserved).
                  const StunningDataTable(
                    columns: <String>['Order', 'Status'],
                    data: <List<String>>[
                      <String>['Invoice #1021', 'Success'],
                      <String>['Invoice #1022', 'Pending'],
                      <String>['Invoice #1023', 'Failed'],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void _noop() {}
