
```markdown
# Stunning UI

A premium, adaptive, and physics-driven Flutter UI framework designed for next-generation Enterprise SaaS, Dashboards, and Gaming applications. 

Stop building boring flat screens. Stunning UI brings production-ready **Glassmorphism**, **Physics-based Animations**, and **Smart Components** out of the box.

## ✨ Features
* **Adaptive Theme Engine:** Switch between Gaming (Neon), Enterprise (Dark SaaS), and Minimal styles with one line of code.
* **Smart Data Tables:** Automatically detects statuses (Success, Pending, Failed) and converts them into glowing badges.
* **Physics-Driven Inputs:** TextFields, Switches, and Dropdowns that react elastically to user taps.
* **Holographic Modals & Toasts:** Floating 3D dialogs and bottom-sliding toasts with solid cores to prevent glass-bleed.
* **Zero Dependencies:** Built entirely using Flutter's native Canvas, BackdropFilter, and Animation engines for maximum 120fps performance.

## 🚀 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  stunning_ui: ^1.2.0

```

## 🛠️ Quick Start

Here is how you can initialize and use the components in your app.

### 1. Initialize the Theme

Wrap your `MaterialApp` with the `StunningTheme` to activate the global physics and styling engine.

import 'package:stunning_ui/stunning_ui.dart';

MaterialApp(
    theme: ThemeData(
        extensions: [
            StunningTheme.darkSaaS(), // Or use .gaming(), .minimal()
        ],
    ),
    home: const DashboardScreen(),
)


### 2. Use Components

Stunning UI components are plug-and-play. They automatically read the global theme.

**Floating Toast Notification:**

StunningToast.show(
    context: context,
    message: 'Payroll Report generated successfully.',
    icon: Icons.check_circle,
    overrideColor: Colors.blueAccent,
);

**Animated Bar Chart:**

StunningBarChart(
    data: const [12, 28, 18, 42],
    labels: const ['Jan', 'Feb', 'Mar', 'Apr'],
    maxValue: 50,
)

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!
