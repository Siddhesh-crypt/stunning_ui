// Stunning UI — example showcase.
//
// A single screen that demonstrates the kit across light and dark (toggle in
// the app bar). For a browsable, per-component catalogue see widgetbook.dart;
// for focused demos see motion_demo.dart, glass_demo.dart and glass_poc.dart.
import 'package:flutter/material.dart';
import 'package:stunning_ui/stunning_ui.dart';

void main() => runApp(const StunningExampleApp());

class StunningExampleApp extends StatefulWidget {
  const StunningExampleApp({super.key});
  @override
  State<StunningExampleApp> createState() => _StunningExampleAppState();
}

class _StunningExampleAppState extends State<StunningExampleApp> {
  ThemeMode _mode = ThemeMode.dark;

  void _toggle() => setState(
    () => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stunning UI',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: StunningTheme.light(
        seedColor: const Color(0xFF6C5CE7),
        style: StunningUIStyle.minimal,
      ).toThemeData(),
      darkTheme: StunningTheme.dark(
        seedColor: Colors.cyanAccent,
        style: StunningUIStyle.gaming,
      ).toThemeData(),
      home: ShowcasePage(
        isDark: _mode == ThemeMode.dark,
        onToggleBrightness: _toggle,
      ),
    );
  }
}

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({
    super.key,
    required this.isDark,
    required this.onToggleBrightness,
  });

  final bool isDark;
  final VoidCallback onToggleBrightness;

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  bool _notify = true;
  bool _agree = true;
  double _volume = 0.6;
  int _segment = 0;
  int _tab = 0;
  String? _framework = 'Flutter';

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stunning UI'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            tooltip: widget.isDark ? 'Light mode' : 'Dark mode',
            icon: Icon(
              widget.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: widget.onToggleBrightness,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
        children: <Widget>[
          _section(st, 'Buttons', <Widget>[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                StunningButton(text: 'Primary', onPressed: () {}),
                StunningButton(
                  text: 'Outline',
                  variant: StunningButtonVariant.outline,
                  onPressed: () {},
                ),
                StunningButton(
                  text: 'Ghost',
                  variant: StunningButtonVariant.ghost,
                  onPressed: () {},
                ),
                StunningButton(
                  text: 'Tonal',
                  variant: StunningButtonVariant.tonal,
                  onPressed: () {},
                ),
                StunningButton(
                  text: 'Delete',
                  icon: Icons.delete_outline,
                  variant: StunningButtonVariant.danger,
                  onPressed: () => _showDialog(context),
                ),
              ],
            ),
          ]),
          _section(st, 'Inputs', <Widget>[
            const StunningTextField(
              hintText: 'Search…',
              prefixIcon: Icons.search,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                StunningSwitch(
                  value: _notify,
                  onChanged: (v) => setState(() => _notify = v),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notifications',
                  style: TextStyle(color: st.textSecondary),
                ),
                const Spacer(),
                StunningCheckbox(
                  value: _agree,
                  semanticLabel: 'Agree',
                  onChanged: (v) => setState(() => _agree = v),
                ),
                const SizedBox(width: 8),
                Text('Agree', style: TextStyle(color: st.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            StunningSlider(
              value: _volume,
              onChanged: (v) => setState(() => _volume = v),
            ),
            const SizedBox(height: 16),
            StunningSegmentedControl(
              options: const <String>['Day', 'Week', 'Month'],
              selectedIndex: _segment,
              onValueChanged: (i) => setState(() => _segment = i),
            ),
            const SizedBox(height: 16),
            StunningTabs(
              tabs: const <String>['Overview', 'Activity', 'Settings'],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 16),
            StunningSelect<String>(
              items: const <String>['Flutter', 'React Native', 'SwiftUI'],
              value: _framework,
              hint: 'Pick a framework',
              onChanged: (v) => setState(() => _framework = v),
            ),
          ]),
          _section(st, 'Glass', <Widget>[
            SizedBox(
              height: 150,
              child: GlassSurface(
                borderRadius: 24,
                tintAmount: 0.10,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.diamond_rounded,
                        color: st.primaryBrand,
                        size: 30,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'GlassSurface',
                        style: TextStyle(
                          color: st.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
          _section(st, 'Data', <Widget>[
            const StunningBarChart(
              data: <double>[12, 28, 18, 42],
              labels: <String>['Jan', 'Feb', 'Mar', 'Apr'],
              maxValue: 50,
              height: 200,
            ),
            const SizedBox(height: 16),
            const StunningDataTable(
              columns: <String>['Order', 'Status'],
              data: <List<String>>[
                <String>['Invoice #1021', 'Success'],
                <String>['Invoice #1022', 'Pending'],
                <String>['Invoice #1023', 'Failed'],
              ],
            ),
          ]),
          _section(st, 'Feedback', <Widget>[
            Row(
              children: <Widget>[
                const StunningProgressRing(value: 0.7),
                const SizedBox(width: 20),
                Expanded(child: const StunningProgressBar(value: 0.45)),
                const SizedBox(width: 20),
                const StunningBadge(
                  label: '3',
                  child: Icon(Icons.notifications_rounded, size: 30),
                ),
                const SizedBox(width: 16),
                const StunningTooltip(
                  message: 'Profile',
                  child: StunningAvatar(initials: 'SU'),
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showStunningDialog<void>(
      context: context,
      title: 'Delete invoice?',
      message: 'This action cannot be undone.',
      icon: Icons.warning_amber_rounded,
      primaryAction: StunningButton(
        text: 'Delete',
        variant: StunningButtonVariant.danger,
        onPressed: () => Navigator.of(context).pop(),
      ),
      secondaryAction: StunningButton(
        text: 'Cancel',
        variant: StunningButtonVariant.ghost,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _section(StunningTheme st, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: 24),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: st.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    );
  }
}
