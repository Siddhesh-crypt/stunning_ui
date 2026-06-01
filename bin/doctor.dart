// `dart run stunning_ui:doctor` — checks that a project is set up to use
// stunning_ui correctly. Read-only: it never modifies your files.
//
// ignore_for_file: avoid_print  (this is a command-line tool)
import 'dart:io';

const _reset = '\x1B[0m';
const _green = '\x1B[32m';
const _red = '\x1B[31m';
const _yellow = '\x1B[33m';
const _cyan = '\x1B[36m';
const _bold = '\x1B[1m';

void _ok(String m) => print('  $_green✓$_reset $m');
void _warn(String m) => print('  $_yellow!$_reset $m');
void _bad(String m) => print('  $_red✗$_reset $m');

void main(List<String> args) {
  print('\n$_bold${_cyan}stunning_ui doctor$_reset\n');

  // 1. Flutter version (>= 3.41 for glass refraction + BackdropGroup).
  try {
    final res = Process.runSync('flutter', <String>[
      '--version',
    ], runInShell: true);
    final out = '${res.stdout}';
    final m = RegExp(r'Flutter (\d+)\.(\d+)\.(\d+)').firstMatch(out);
    if (m != null) {
      final major = int.parse(m.group(1)!);
      final minor = int.parse(m.group(2)!);
      final v = '${m.group(1)}.${m.group(2)}.${m.group(3)}';
      if (major > 3 || (major == 3 && minor >= 41)) {
        _ok('Flutter $v (>= 3.41 OK)');
      } else {
        _bad('Flutter $v — stunning_ui needs >= 3.41');
      }
    } else {
      _warn('Could not parse the Flutter version');
    }
  } on ProcessException {
    _warn('Flutter not found on PATH');
  }

  // 2. stunning_ui in pubspec.yaml.
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    _bad('No pubspec.yaml here — run this from your project root');
  } else {
    final text = pubspec.readAsStringSync();
    if (RegExp(r'^\s*stunning_ui\s*:', multiLine: true).hasMatch(text)) {
      _ok('stunning_ui is listed in pubspec.yaml');
    } else {
      _bad('stunning_ui not found in pubspec.yaml');
    }
  }

  // 3. StunningTheme wired + a quick hardcoded-colour scan.
  final lib = Directory('lib');
  var themeWired = false;
  var whiteCount = 0;
  var dartFiles = 0;
  if (lib.existsSync()) {
    for (final e in lib.listSync(recursive: true).whereType<File>()) {
      if (!e.path.endsWith('.dart')) continue;
      dartFiles++;
      final s = e.readAsStringSync();
      if (s.contains('StunningTheme')) themeWired = true;
      whiteCount += RegExp(r'Colors\.white').allMatches(s).length;
    }
  }
  if (themeWired) {
    _ok('StunningTheme referenced in lib/');
  } else {
    _warn('StunningTheme not wired — run `dart run stunning_ui:init`');
  }
  if (dartFiles > 0 && whiteCount > 0) {
    _warn(
      '$whiteCount hardcoded `Colors.white` in lib/ — prefer theme tokens '
      '(st.textPrimary / iconColor / borderColor) so it works in light + dark',
    );
  } else if (dartFiles > 0) {
    _ok('No hardcoded `Colors.white` chrome detected');
  }

  print(
    '\nNext: ${_cyan}dart run stunning_ui:init$_reset to scaffold a theme.\n',
  );
}
