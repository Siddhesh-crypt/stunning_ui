// Stunning UI — Motion Engine demo.
//
// Shows the chainable `.stunning()` API: a hero card with a pulsing glow that
// tilts toward the pointer and springs back, plus a list of cards that
// stagger-spring into view. All physics come from the theme spring token and
// honor reduce-motion. (Open it live to feel the springs — a screenshot only
// captures the settled frame.)
//
// Run:  flutter run -t lib/motion_demo.dart -d chrome
import 'package:flutter/material.dart';
import 'package:stunning_ui/stunning_ui.dart';

void main() => runApp(const MotionDemoApp());

class MotionDemoApp extends StatelessWidget {
  const MotionDemoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: StunningTheme.dark(seedColor: const Color(0xFF22D3EE)).toThemeData(),
      home: const MotionDemoScreen(),
    );
  }
}

class MotionDemoScreen extends StatelessWidget {
  const MotionDemoScreen({super.key});

  static const List<(IconData, String, String)> _items = <(IconData, String, String)>[
    (Icons.bolt_rounded, 'Spring physics', 'Velocity-preserving, interruptible'),
    (Icons.layers_rounded, 'Theme-driven', 'Springs come from the active style'),
    (Icons.accessibility_new_rounded, 'Reduce-motion', 'Collapses to instant when asked'),
    (Icons.auto_awesome_rounded, 'One-liner', 'widget.stunning().glow().springIn()'),
  ];

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Hero card — pulsing glow + interactive tilt.
                _hero(st)
                    .stunning()
                    .glow(pulse: true, blur: 40)
                    .tilt(max: 0.18)
                    .springIn(fromScale: 0.8),
                const SizedBox(height: 28),
                // Feature cards — staggered spring entrance + glow.
                for (int i = 0; i < _items.length; i++) ...<Widget>[
                  _card(st, _items[i])
                      .stunning()
                      .glow(blur: 22)
                      .springIn(
                        fromScale: 0.92,
                        fromOffset: const Offset(0, 24),
                        delay: Duration(milliseconds: 350 + i * 120),
                      ),
                  if (i != _items.length - 1) const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(StunningTheme st) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            st.primaryBrand.withValues(alpha: 0.30),
            st.surfaceGlass,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: st.primaryBrand.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.auto_awesome_rounded, color: st.primaryBrand, size: 34),
          const SizedBox(height: 14),
          Text('.stunning() motion',
              style: TextStyle(
                  color: st.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Hover me — I tilt and spring back.',
              style: TextStyle(color: st.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _card(StunningTheme st, (IconData, String, String) item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: st.surfaceGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: st.borderColor),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: st.primaryBrand.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.$1, color: st.primaryBrand),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(item.$2,
                    style: TextStyle(
                        color: st.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.$3,
                    style: TextStyle(color: st.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
