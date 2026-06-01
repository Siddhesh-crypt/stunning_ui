// `dart run stunning_ui:init` — scaffolds a starter theme for your app.
// Non-destructive: it creates lib/stunning_theme.dart only if it doesn't exist
// and never edits your other files. Flags: --style, --seed, --brightness.
//
// ignore_for_file: avoid_print  (this is a command-line tool)
import 'dart:io';

const _reset = '\x1B[0m';
const _green = '\x1B[32m';
const _yellow = '\x1B[33m';
const _cyan = '\x1B[36m';

String _flag(List<String> args, String name, String fallback) {
  final prefix = '--$name=';
  final hit = args.firstWhere((a) => a.startsWith(prefix), orElse: () => '');
  return hit.isEmpty ? fallback : hit.substring(prefix.length);
}

void main(List<String> args) {
  const styles = <String>{'gaming', 'enterprise', 'minimal'};
  final style = _flag(args, 'style', 'gaming');
  final brightness = _flag(args, 'brightness', 'dark');
  final seed = _flag(args, 'seed', 'Colors.cyanAccent');

  if (!styles.contains(style)) {
    stderr.writeln(
      'Unknown --style "$style". Use one of: ${styles.join(', ')}.',
    );
    exitCode = 64; // usage error
    return;
  }

  final file = File('lib/stunning_theme.dart');
  if (file.existsSync()) {
    print(
      '$_yellow!$_reset lib/stunning_theme.dart already exists — leaving it untouched.',
    );
  } else {
    file.createSync(recursive: true);
    file.writeAsStringSync('''
import 'package:flutter/material.dart';
import 'package:stunning_ui/stunning_ui.dart';

/// Your app's Stunning theme. Tweak the seed colour, brightness and style here
/// and the whole UI follows.
ThemeData buildStunningTheme() => StunningTheme.generate(
      seedColor: $seed,
      brightness: Brightness.$brightness,
      style: StunningUIStyle.$style,
    ).toThemeData();
''');
    print(
      '$_green✓$_reset Created lib/stunning_theme.dart  '
      '(style: $style, brightness: $brightness)',
    );
  }

  print('''

Wire it into your app:

  ${_cyan}import 'stunning_theme.dart';

  MaterialApp(
    theme: buildStunningTheme(),
    home: const HomePage(),
  );$_reset

Then drop in components — StunningButton(text: 'Go', onPressed: () {}),
myCard.stunning().glow().tilt(), GlassSurface(child: ...), and more.
''');
}
