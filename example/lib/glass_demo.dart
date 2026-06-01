// Stunning UI — production GlassSurface demo.
//
// Real glass over live content. On Impeller (mobile/desktop) the panels do
// index-of-refraction lensing of what's behind them; on web/Skia they fall
// back to a blur — both auto-tuned from the theme. StunningGlassScope coalesces
// every panel's blur into one pass.
//
// Run:  flutter run -t lib/glass_demo.dart -d chrome
import 'package:flutter/material.dart';
import 'package:stunning_ui/stunning_ui.dart';

void main() => runApp(const GlassDemoApp());

class GlassDemoApp extends StatelessWidget {
  const GlassDemoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: StunningTheme.dark(seedColor: const Color(0xFF22D3EE)).toThemeData(),
      home: const GlassDemoScreen(),
    );
  }
}

class GlassDemoScreen extends StatelessWidget {
  const GlassDemoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Vibrant, busy background so the glass clearly distorts it.
          const Positioned.fill(child: _Backdrop()),
          // Glass panels — coalesced into one backdrop pass by the scope.
          StunningGlassScope(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GlassSurface(
                      borderRadius: 28,
                      padding: const EdgeInsets.all(26),
                      tintAmount: 0.10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.diamond_rounded, color: st.primaryBrand, size: 32),
                          const SizedBox(height: 14),
                          Text('GlassSurface',
                              style: TextStyle(
                                  color: st.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            'Refraction on Impeller · blur on web · '
                            'solid under reduce-transparency.',
                            style: TextStyle(color: st.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: GlassSurface(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.speed_rounded, color: st.primaryBrand),
                                const SizedBox(height: 8),
                                Text('Coalesced',
                                    style: TextStyle(color: st.textPrimary)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassSurface(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.bolt_rounded, color: st.primaryBrand),
                                const SizedBox(height: 8),
                                Text('Themed',
                                    style: TextStyle(color: st.textPrimary)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1E1B4B), Color(0xFF0E7490), Color(0xFF312E81)],
        ),
      ),
      child: Stack(
        children: const <Widget>[
          _Blob(left: 40, top: 80, color: Color(0xFFA855F7)),
          _Blob(right: 30, top: 200, color: Color(0xFF22D3EE)),
          _Blob(left: 80, bottom: 60, color: Color(0xFFEC4899)),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({this.left, this.top, this.right, this.bottom, required this.color});
  final double? left, top, right, bottom;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: <Color>[color, color.withValues(alpha: 0.0)]),
        ),
      ),
    );
  }
}
