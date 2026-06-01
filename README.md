# Stunning UI

A premium, adaptive, and physics-driven Flutter UI framework designed for next-generation Enterprise SaaS, Dashboards, and Gaming applications.

Stop building boring flat screens. Stunning UI brings production-ready **Glassmorphism**, **Physics-based Animations**, and **Smart Components** out of the box.

## ✨ Features

* **Adaptive Theme Engine:** One seed color → a complete theme. Switch between Gaming (neon), Enterprise (dark SaaS), and Minimal vibes by changing a single enum.
* **Smart Data Tables:** Automatically detect statuses (Success, Pending, Failed) and convert them into glowing badges.
* **Physics-Driven Inputs:** TextFields, Switches, and Dropdowns that react elastically to user taps.
* **Holographic Modals & Toasts:** Floating dialogs and bottom-sliding toasts with solid cores to prevent glass-bleed.
* **Zero Dependencies:** Built entirely on Flutter's native Canvas, BackdropFilter, and animation engines.

## 🚀 Installation

Add this to your package's `pubspec.yaml`:

```yaml
dependencies:
  stunning_ui: ^1.7.0
```

Then run `flutter pub get`.

## 🛠️ Quick Start

### 1. Activate the Theme Engine

Wrap your `MaterialApp` with a `StunningTheme` extension. The smart generator takes a **seed color**, a **brightness**, and a **style**, then derives the blur, glow, border, and motion tokens for you.

```dart
import 'package:flutter/material.dart';
import 'package:stunning_ui/stunning_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        extensions: <ThemeExtension<dynamic>>[
          StunningTheme.generate(
            seedColor: Colors.cyanAccent,
            brightness: Brightness.dark,
            style: StunningUIStyle.gaming, // or .enterprise / .minimal
          ),
        ],
      ),
      home: const DashboardScreen(),
    );
  }
}
```

> **Styles:** `StunningUIStyle.enterprise` (flat, fast, high-contrast — best for CRM/B2B), `StunningUIStyle.minimal` (subtle frost, Apple-like motion), `StunningUIStyle.gaming` (heavy glass, neon glow, springy physics).

### 2. Use Components

Components are plug-and-play and automatically read the active theme.

**Button:**

```dart
StunningButton(
  text: 'Generate Report',
  onPressed: () {},
  variant: StunningButtonVariant.primary, // or .outline / .ghost
)
```

**Floating Toast notification:**

```dart
StunningToast.show(
  context: context,
  message: 'Payroll report generated successfully.',
  icon: Icons.check_circle,
  overrideColor: Colors.blueAccent,
);
```

**Animated Bar Chart:**

```dart
StunningBarChart(
  data: const [12.0, 28.0, 18.0, 42.0],
  labels: const ['Jan', 'Feb', 'Mar', 'Apr'],
  maxValue: 50,
)
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Open an issue or a pull request on the [repository](https://github.com/Siddhesh-crypt/stunning_ui).

## 📄 License

Released under the MIT License. See [LICENSE](LICENSE) for details.
