// Stunning UI — Liquid Glass refraction PROOF OF CONCEPT (style comparison).
//
// One fragment shader samples a procedural background at displaced coordinates
// to fake real index-of-refraction lensing (watch the grid lines bend at the
// panel edges), plus a frost blur, brand tint and specular rim — ALL driven by
// a tiny token set that maps 1:1 to StunningTheme's enterprise / minimal /
// gaming styles. The developer sets none of it. In the real library this
// becomes `widget.stunning().glass()`.
//
// Run:  flutter run -t lib/glass_poc.dart -d chrome
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(const GlassPocApp());

/// The numbers a developer would NEVER set by hand — derived from the theme.
class GlassStyle {
  final String name;
  final String blurb;
  final double refraction; // px edge displacement
  final double blur; // px frost radius
  final double glow; // specular + border intensity
  final Color tint; // brand color
  final double tintAmount; // 0..1 tint mix
  final double radius; // corner radius
  const GlassStyle(
    this.name,
    this.blurb, {
    required this.refraction,
    required this.blur,
    required this.glow,
    required this.tint,
    required this.tintAmount,
    required this.radius,
  });
}

const List<GlassStyle> kStyles = <GlassStyle>[
  GlassStyle('Enterprise', 'flat · no glass · save GPU',
      refraction: 3, blur: 1, glow: 0.03, tint: Color(0xFF94A3B8), tintAmount: 0.03, radius: 14),
  GlassStyle('Minimal', 'soft frost · subtle glow',
      refraction: 16, blur: 6, glow: 0.18, tint: Color(0xFF8B5CF6), tintAmount: 0.07, radius: 24),
  GlassStyle('Gaming', 'thick lens · neon glow',
      refraction: 32, blur: 11, glow: 0.85, tint: Color(0xFF22D3EE), tintAmount: 0.12, radius: 30),
];

class GlassPocApp extends StatelessWidget {
  const GlassPocApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GlassPocScreen(),
    );
  }
}

class GlassPocScreen extends StatefulWidget {
  const GlassPocScreen({super.key});
  @override
  State<GlassPocScreen> createState() => _GlassPocScreenState();
}

class _GlassPocScreenState extends State<GlassPocScreen>
    with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  String? _error;
  late final Ticker _ticker;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration e) {
      setState(() => _t = e.inMicroseconds / 1e6);
    })..start();
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await ui.FragmentProgram.fromAsset('shaders/liquid_glass.frag');
      if (mounted) setState(() => _program = p);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05050F),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Shader load failed:\n$_error',
                    style: const TextStyle(color: Colors.redAccent)),
              ),
            )
          : _program == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const SizedBox(height: 18),
                    const Text(
                      'stunning_ui · .glass() refraction — same shader, theme-driven styles',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'grid lines bend through the glass = real index-of-refraction lensing',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          for (final style in kStyles)
                            Expanded(
                              child: _GlassColumn(
                                program: _program!,
                                time: _t,
                                style: style,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _GlassColumn extends StatelessWidget {
  const _GlassColumn({
    required this.program,
    required this.time,
    required this.style,
  });
  final ui.FragmentProgram program;
  final double time;
  final GlassStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: LayoutBuilder(
          builder: (context, c) {
            final size = Size(c.maxWidth, c.maxHeight);
            final panel = Size(size.width - 40, 170);
            final center = Offset(size.width / 2, size.height / 2);
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: CustomPaint(
                    painter: GlassPainter(
                      program: program,
                      time: time,
                      style: style,
                      center: center,
                      panel: panel,
                    ),
                  ),
                ),
                Positioned(
                  left: center.dx - panel.width / 2,
                  top: center.dy - panel.height / 2,
                  width: panel.width,
                  height: panel.height,
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(Icons.bolt_rounded, color: style.tint, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                style.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            style.blurb,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // style name chip at the bottom of each column
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 14,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: style.tint.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: style.tint.withValues(alpha: 0.8)),
                      ),
                      child: Text(
                        'StunningUIStyle.${style.name.toLowerCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class GlassPainter extends CustomPainter {
  GlassPainter({
    required this.program,
    required this.time,
    required this.style,
    required this.center,
    required this.panel,
  });

  final ui.FragmentProgram program;
  final double time;
  final GlassStyle style;
  final Offset center;
  final Size panel;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    final t = style.tint;
    var i = 0;
    shader.setFloat(i++, size.width); // uSize.x
    shader.setFloat(i++, size.height); // uSize.y
    shader.setFloat(i++, time); // uTime
    shader.setFloat(i++, center.dx - panel.width / 2); // uGlassRect.x
    shader.setFloat(i++, center.dy - panel.height / 2); // uGlassRect.y
    shader.setFloat(i++, panel.width); // uGlassRect.z
    shader.setFloat(i++, panel.height); // uGlassRect.w
    shader.setFloat(i++, style.radius); // uRadius
    shader.setFloat(i++, style.refraction); // uRefraction
    shader.setFloat(i++, style.blur); // uBlur
    shader.setFloat(i++, style.glow); // uGlow
    shader.setFloat(i++, t.r); // uTint.r
    shader.setFloat(i++, t.g); // uTint.g
    shader.setFloat(i++, t.b); // uTint.b
    shader.setFloat(i++, style.tintAmount); // uTintAmount
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(GlassPainter old) =>
      old.time != time ||
      old.style != style ||
      old.center != center ||
      old.panel != panel;
}
