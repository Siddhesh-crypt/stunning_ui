// Generates registry.json + llms.txt from the package's public exports, so AI
// agents (and docs/tooling) have a single, accurate source of truth for what
// stunning_ui ships. Run: `dart run tool/build_registry.dart`.
//
// A drift test (test/registry_test.dart) fails if the committed registry.json
// is out of date — so this must be re-run whenever exports change.
//
// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Scans the barrel + exported files and returns the registry map.
Map<String, dynamic> buildRegistry({required String packageRoot}) {
  final barrel = File('$packageRoot/lib/stunning_ui.dart').readAsStringSync();
  final exportRe = RegExp(r"export '([^']+)';");
  final exports =
      exportRe.allMatches(barrel).map((m) => m.group(1)!).toList()..sort();

  final components = <Map<String, dynamic>>[];
  for (final rel in exports) {
    final file = File('$packageRoot/lib/$rel');
    if (!file.existsSync()) continue;
    final src = file.readAsStringSync();
    final category = _category(rel);

    final symbols = <String>{
      ...RegExp(
        r'^class (Stunning\w+)',
        multiLine: true,
      ).allMatches(src).map((m) => m.group(1)!),
      ...RegExp(
        r'^enum (Stunning\w+)',
        multiLine: true,
      ).allMatches(src).map((m) => m.group(1)!),
    }..removeWhere((s) => s.endsWith('State'));

    for (final name in symbols) {
      components.add(<String, dynamic>{
        'name': name,
        'category': category,
        'file': rel,
        'description': _docFor(src, name),
      });
    }
  }
  components.sort(
    (a, b) => (a['name'] as String).compareTo(b['name'] as String),
  );

  return <String, dynamic>{
    'name': 'stunning_ui',
    'description':
        'A glassmorphic, physics-driven Flutter UI toolkit. One seed colour + '
        'style derives a full theme; accessible by default; chainable .stunning() effects.',
    'generatedBy': 'tool/build_registry.dart',
    'componentCount': components.length,
    'components': components,
  };
}

String _category(String rel) {
  final m = RegExp(r'src/(?:components/)?(\w+)/').firstMatch(rel);
  return m?.group(1) ?? 'core';
}

/// The first dartdoc sentence above a class/enum declaration.
String _docFor(String src, String name) {
  final decl = RegExp('(?:class|enum) $name\\b');
  final idx = src.indexOf(decl);
  if (idx < 0) return '';
  final before = src.substring(0, idx).trimRight().split('\n');
  final doc = <String>[];
  for (var i = before.length - 1; i >= 0; i--) {
    final line = before[i].trim();
    if (line.startsWith('///')) {
      doc.insert(0, line.replaceFirst('///', '').trim());
    } else if (line.isEmpty || line.startsWith('@')) {
      continue;
    } else {
      break;
    }
  }
  final text = doc.join(' ').trim();
  final dot = text.indexOf('. ');
  return dot > 0 ? text.substring(0, dot + 1) : text;
}

String _llms(Map<String, dynamic> reg) {
  final byCat = <String, List<String>>{};
  for (final c in reg['components'] as List<dynamic>) {
    final m = c as Map<String, dynamic>;
    byCat
        .putIfAbsent(m['category'] as String, () => <String>[])
        .add(m['name'] as String);
  }
  final cats = byCat.keys.toList()..sort();
  final buffer =
      StringBuffer()
        ..writeln('# stunning_ui')
        ..writeln()
        ..writeln(reg['description'])
        ..writeln()
        ..writeln('## Setup (one line)')
        ..writeln('```dart')
        ..writeln(
          "MaterialApp(theme: StunningTheme.dark(seedColor: Colors.cyanAccent).toThemeData(), home: ...)",
        )
        ..writeln('```')
        ..writeln(
          'Styles: StunningUIStyle.enterprise | minimal | gaming. '
          'Read the theme anywhere with StunningTheme.of(context).',
        )
        ..writeln()
        ..writeln('## Chainable effects')
        ..writeln('```dart')
        ..writeln('widget.stunning().glow().tilt().springIn().glass()')
        ..writeln('Column(children: cards.stunningStagger())')
        ..writeln('```')
        ..writeln()
        ..writeln('## Components (${reg['componentCount']})');
  for (final cat in cats) {
    final names = byCat[cat]!..sort();
    buffer.writeln('- **$cat**: ${names.join(', ')}');
  }
  buffer
    ..writeln()
    ..writeln('## Conventions for correct code')
    ..writeln(
      '- Colours come from the theme (StunningTheme.of(context): textPrimary, '
      'textSecondary, hintColor, iconColor, borderColor, primaryBrand, onColor(bg)). '
      'Do not hardcode Colors.white/black — the kit must work in light AND dark.',
    )
    ..writeln(
      '- Animation durations use StunningTheme.of(context).motion(context) so '
      'reduce-motion is honoured.',
    )
    ..writeln('- Pass onChanged/onPressed: null to disable a control.')
    ..writeln(
      '- Glass: use GlassSurface or .glass(); wrap a screen in StunningGlassScope '
      'to coalesce blur. Requires Flutter >= 3.41.',
    );
  return buffer.toString();
}

void main() {
  const root = '.';
  final reg = buildRegistry(packageRoot: root);
  File(
    '$root/registry.json',
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(reg)}\n');
  File('$root/llms.txt').writeAsStringSync(_llms(reg));
  print('Wrote registry.json (${reg['componentCount']} components) + llms.txt');
}
