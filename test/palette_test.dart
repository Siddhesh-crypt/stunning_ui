import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stunning_ui/stunning_ui.dart';

int _r(Color c) => (c.toARGB32() >> 16) & 0xFF;
int _g(Color c) => (c.toARGB32() >> 8) & 0xFF;
int _b(Color c) => c.toARGB32() & 0xFF;

const _seeds = <Color>[
  Color(0xFF6C5CE7), // violet
  Color(0xFF22D3EE), // cyan
  Color(0xFFEF4444), // red brand (collides with error)
  Color(0xFF10B981), // green
  Color(0xFF808080), // near-grey
  Color(0xFFF59E0B), // amber
];

void main() {
  group('StunningPalette · structure', () {
    test('single seed yields a full palette, primary preserved', () {
      const seed = Color(0xFF6C5CE7);
      final p = StunningPalette.fromSeed(seed);
      expect(p.primary, seed);
      for (final role in StunningRole.values) {
        expect(p.ramp(role).length, kStunningRampStops.length,
            reason: '$role ramp must have 11 stops');
      }
      expect(p.gradients.brand.length, 2);
      expect(p.gradients.mesh.length, 3);
    });

    test('ramps are monotonic in luminance (lightest → darkest)', () {
      final p = StunningPalette.fromSeed(const Color(0xFF22D3EE));
      final ramp = p.ramp(StunningRole.primary);
      for (var i = 0; i < ramp.length - 1; i++) {
        expect(ramp[i].computeLuminance(),
            greaterThanOrEqualTo(ramp[i + 1].computeLuminance() - 0.001),
            reason: 'stop $i should be >= next in luminance');
      }
    });
  });

  group('StunningPalette · WCAG contrast guarantee', () {
    test('every on/bg pair meets AA (>= 4.5) for both brightnesses', () {
      for (final seed in _seeds) {
        for (final b in Brightness.values) {
          final p = StunningPalette.fromSeed(seed, brightness: b);
          p.contrastReport().forEach((pair, ratio) {
            expect(ratio, greaterThanOrEqualTo(4.49),
                reason: '$pair on seed $seed/$b was $ratio');
          });
        }
      }
    });

    test('on() guarantees the requested ratio for arbitrary backgrounds', () {
      final p = StunningPalette.fromSeed(const Color(0xFF6C5CE7));
      for (final bg in [
        const Color(0xFFFFFFFF),
        const Color(0xFF000000),
        const Color(0xFF7F7F7F),
        const Color(0xFF6C5CE7),
      ]) {
        final fg = p.on(bg);
        final ratio = (fg.computeLuminance() + 0.05) /
                (bg.computeLuminance() + 0.05);
        final r = ratio < 1 ? 1 / ratio : ratio;
        expect(r, greaterThanOrEqualTo(4.4), reason: 'on($bg) only hit $r');
      }
    });
  });

  group('StunningPalette · harmony auto-pick', () {
    test('vibrant seed → complementary, calm → analogous, grey → mono', () {
      expect(StunningPalette.fromSeed(const Color(0xFF22D3EE)).resolvedHarmony,
          StunningHarmony.complementary);
      expect(StunningPalette.fromSeed(const Color(0xFF808080)).resolvedHarmony,
          StunningHarmony.monochromatic);
    });

    test('explicit harmony overrides auto', () {
      final p = StunningPalette.fromSeed(const Color(0xFF6C5CE7),
          harmony: StunningHarmony.triadic);
      expect(p.resolvedHarmony, StunningHarmony.triadic);
    });

    test('a provided secondary is harmonised, never identical to primary', () {
      final p = StunningPalette.fromSeed(
        const Color(0xFF6C5CE7),
        secondary: const Color(0xFFFF7A00),
      );
      expect(p.secondary, isNot(p.primary));
    });
  });

  group('StunningPalette · brand-tuned semantics stay meaningful', () {
    test('error reads red, success reads green across seeds', () {
      for (final seed in _seeds) {
        final s = StunningPalette.fromSeed(seed).semantics;
        expect(_r(s.error.color), greaterThan(_b(s.error.color)),
            reason: 'error must stay red for seed $seed');
        expect(_g(s.success.color), greaterThan(_b(s.success.color)),
            reason: 'success must stay green for seed $seed');
      }
    });
  });

  group('StunningTheme · palette integration', () {
    test('generate(single seed) is backward compatible + adds a palette', () {
      const seed = Color(0xFF6C5CE7);
      final t = StunningTheme.generate(
          seedColor: seed, brightness: Brightness.dark);
      expect(t.primaryBrand, seed);
      expect(t.palette, isNotNull);
      expect(t.semantics, isNotNull);
    });

    test('scheme adopts the harmonised secondary/tertiary', () {
      final t = StunningTheme.generate(
          seedColor: const Color(0xFF6C5CE7), brightness: Brightness.light);
      expect(t.colorScheme!.secondary, t.palette!.secondary);
      expect(t.colorScheme!.tertiary, t.palette!.tertiary);
    });

    test('preset factories all carry a palette', () {
      for (final t in [
        StunningTheme.gaming(),
        StunningTheme.enterprise(),
        StunningTheme.minimal(),
        StunningTheme.light(),
        StunningTheme.dark(),
      ]) {
        expect(t.palette, isNotNull);
      }
    });

    test('lerp between two themes interpolates the palette without error', () {
      final a = StunningTheme.light();
      final b = StunningTheme.dark();
      final mid = a.lerp(b, 0.5);
      expect(mid.palette, isNotNull);
      expect(mid.palette!.ramp(StunningRole.primary).length, 11);
    });
  });

  group('StunningTheme · share codes', () {
    test('round-trip is exact across styles and brightnesses', () {
      for (final style in StunningUIStyle.values) {
        for (final b in Brightness.values) {
          final t = StunningTheme.generate(
              seedColor: const Color(0xFF6C5CE7), brightness: b, style: style);
          final code = t.toShareCode();
          expect(code, startsWith('st1_'));
          final back = StunningTheme.fromShareCode(code)!;
          expect(back.primaryBrand.toARGB32(), t.primaryBrand.toARGB32());
          expect(back.brightness, b);
          expect(back.style, style);
        }
      }
    });

    test('malformed codes return null', () {
      expect(StunningTheme.fromShareCode('nope'), isNull);
      expect(StunningTheme.fromShareCode('st1_'), isNull);
      expect(StunningTheme.fromShareCode('st1_!!!'), isNull);
    });
  });

  group('Widgets · accent + morph', () {
    testWidgets('StunningAccent recolours a subtree', (tester) async {
      late Color seen;
      await tester.pumpWidget(MaterialApp(
        theme: StunningTheme.light(seedColor: const Color(0xFF6C5CE7))
            .toThemeData(),
        home: StunningAccent(
          seedColor: const Color(0xFFFF7A00),
          child: Builder(builder: (context) {
            seen = StunningTheme.of(context).primaryBrand;
            return const SizedBox();
          }),
        ),
      ));
      expect(seen, const Color(0xFFFF7A00));
    });

    testWidgets('StunningAnimatedTheme morphs between themes', (tester) async {
      Widget tree(StunningTheme t) => MaterialApp(
            home: StunningAnimatedTheme(
              theme: t,
              duration: const Duration(milliseconds: 300),
              child: const SizedBox(),
            ),
          );
      await tester.pumpWidget(tree(StunningTheme.light()));
      await tester.pumpWidget(tree(StunningTheme.dark()));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
