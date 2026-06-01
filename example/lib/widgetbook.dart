// Stunning UI — Widgetbook component gallery.
//
// Browse every component across the enterprise / minimal / gaming themes (and
// light/dark) with the theme switcher in the toolbar. Build for the web and
// deploy to GitHub Pages:
//   flutter build web -t lib/widgetbook.dart
//
// Run locally:  flutter run -t lib/widgetbook.dart -d chrome
import 'package:flutter/material.dart';
import 'package:stunning_ui/stunning_ui.dart';
import 'package:widgetbook/widgetbook.dart';

void main() => runApp(const StunningWidgetbook());

Widget _frame(Widget child) => Center(
  child: Padding(padding: const EdgeInsets.all(24), child: child),
);

class StunningWidgetbook extends StatelessWidget {
  const StunningWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      appBuilder: (context, child) =>
          Material(type: MaterialType.transparency, child: child),
      addons: <WidgetbookAddon<dynamic>>[
        MaterialThemeAddon(
          themes: <WidgetbookTheme<ThemeData>>[
            WidgetbookTheme(
              name: 'Gaming · dark',
              data: StunningTheme.dark(
                seedColor: Colors.cyanAccent,
                style: StunningUIStyle.gaming,
              ).toThemeData(),
            ),
            WidgetbookTheme(
              name: 'Minimal · light',
              data: StunningTheme.light(
                seedColor: const Color(0xFF6C5CE7),
                style: StunningUIStyle.minimal,
              ).toThemeData(),
            ),
            WidgetbookTheme(
              name: 'Enterprise · dark',
              data: StunningTheme.enterprise(
                seedColor: const Color(0xFF3B82F6),
              ).toThemeData(),
            ),
          ],
        ),
        TextScaleAddon(),
      ],
      directories: <WidgetbookNode>[
        WidgetbookCategory(
          name: 'Buttons',
          children: <WidgetbookNode>[
            WidgetbookComponent(
              name: 'StunningButton',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Variants',
                  builder: (context) => _frame(
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
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
                          text: 'Danger',
                          variant: StunningButtonVariant.danger,
                          onPressed: () {},
                        ),
                        StunningButton(
                          icon: Icons.add,
                          text: 'Icon',
                          onPressed: () {},
                        ),
                        const StunningButton(text: 'Disabled'),
                      ],
                    ),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Sizes',
                  builder: (context) => _frame(
                    Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        StunningButton(
                          text: 'Small',
                          size: StunningButtonSize.small,
                          onPressed: () {},
                        ),
                        StunningButton(text: 'Medium', onPressed: () {}),
                        StunningButton(
                          text: 'Large',
                          size: StunningButtonSize.large,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Inputs',
          children: <WidgetbookNode>[
            WidgetbookComponent(
              name: 'StunningCheckbox',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _frame(
                    StatefulBuilder(
                      builder: (context, setState) => StunningCheckbox(
                        value: _checkbox,
                        onChanged: (v) => setState(() => _checkbox = v),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningRadio',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Group',
                  builder: (context) => _frame(
                    StatefulBuilder(
                      builder: (context, setState) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (var i = 0; i < 3; i++)
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: StunningRadio<int>(
                                value: i,
                                groupValue: _radio,
                                onChanged: (v) =>
                                    setState(() => _radio = v ?? 0),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningSwitch',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _frame(
                    StatefulBuilder(
                      builder: (context, setState) => StunningSwitch(
                        value: _switch,
                        onChanged: (v) => setState(() => _switch = v),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningSlider',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _frame(
                    SizedBox(
                      width: 260,
                      child: StatefulBuilder(
                        builder: (context, setState) => StunningSlider(
                          value: _slider,
                          onChanged: (v) => setState(() => _slider = v),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningSelect',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _frame(
                    SizedBox(
                      width: 240,
                      child: StatefulBuilder(
                        builder: (context, setState) => StunningSelect<String>(
                          items: const <String>['Alpha', 'Beta', 'Gamma'],
                          value: _select,
                          onChanged: (v) => setState(() => _select = v),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningTextField',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'With icon',
                  builder: (context) => _frame(
                    const SizedBox(
                      width: 280,
                      child: StunningTextField(
                        hintText: 'Search…',
                        prefixIcon: Icons.search,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningSegmentedControl',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _frame(
                    StatefulBuilder(
                      builder: (context, setState) => StunningSegmentedControl(
                        options: const <String>['Day', 'Week', 'Month'],
                        selectedIndex: _segment,
                        onValueChanged: (i) => setState(() => _segment = i),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningTabs',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _frame(
                    StatefulBuilder(
                      builder: (context, setState) => StunningTabs(
                        tabs: const <String>[
                          'Overview',
                          'Activity',
                          'Settings',
                        ],
                        selectedIndex: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Display',
          children: <WidgetbookNode>[
            WidgetbookComponent(
              name: 'StunningBadge',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Standalone + anchored',
                  builder: (context) => _frame(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        StunningBadge(label: '9+', standalone: true),
                        SizedBox(width: 24),
                        StunningBadge(
                          label: '3',
                          child: Icon(Icons.notifications_rounded, size: 32),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningAvatar',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Initials / icon',
                  builder: (context) => _frame(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        StunningAvatar(initials: 'SL'),
                        SizedBox(width: 16),
                        StunningAvatar(icon: Icons.person, radius: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningProgress',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Bar + ring',
                  builder: (context) => _frame(
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        SizedBox(
                          width: 240,
                          child: StunningProgressBar(value: 0.6),
                        ),
                        SizedBox(height: 24),
                        StunningProgressRing(value: 0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningTooltip',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Hover the icon',
                  builder: (context) => _frame(
                    const StunningTooltip(
                      message: 'Helpful hint',
                      child: Icon(Icons.info_outline, size: 32),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'StunningTiltCard',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _frame(
                    StunningTiltCard(
                      width: 240,
                      height: 150,
                      child: Builder(
                        builder: (context) => Text(
                          'Tilt me',
                          style: TextStyle(
                            color: StunningTheme.of(context).textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'GlassSurface',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => _frame(
                    SizedBox(
                      width: 240,
                      height: 130,
                      child: GlassSurface(
                        borderRadius: 24,
                        child: Builder(
                          builder: (context) => Center(
                            child: Text(
                              '.glass()',
                              style: TextStyle(
                                color: StunningTheme.of(context).textPrimary,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        WidgetbookCategory(
          name: 'Feedback',
          children: <WidgetbookNode>[
            WidgetbookComponent(
              name: 'StunningDialog',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Confirm',
                  builder: (context) => _frame(
                    SizedBox(
                      width: 360,
                      child: StunningDialog.confirm(
                        title: 'Delete file?',
                        message: 'This action cannot be undone.',
                        primaryAction: StunningButton(
                          text: 'Delete',
                          onPressed: () {},
                        ),
                        secondaryAction: StunningButton(
                          text: 'Cancel',
                          variant: StunningButtonVariant.ghost,
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// Simple shared state for the interactive use-cases.
bool _checkbox = true;
int _radio = 1;
bool _switch = true;
double _slider = 0.5;
String? _select = 'Alpha';
int _segment = 0;
int _tab = 0;
