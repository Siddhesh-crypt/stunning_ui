// lib/src/components/navigation/stunning_sidebar.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/stunning_tappable.dart';
import '../../theme/stunning_theme.dart';

/// An individual menu item for the [StunningSidebar].
class StunningSidebarItem extends StatelessWidget {
  /// The icon displayed next to the title.
  final IconData icon;

  /// The text label for the menu item.
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const StunningSidebarItem({
    super.key,
    required this.icon,
    required this.title,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);
    final primary = st.primaryBrand;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: StunningTappable(
        onPressed: onTap,
        selected: isActive,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: st.motion(context),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive
                ? primary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? primary : st.iconColor, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? st.textPrimary : st.textSecondary,
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A glassmorphic drawer/sidebar with blurred backdrop effects and animated selection states.
class StunningSidebar extends StatelessWidget {
  /// The widget displayed at the top of the sidebar (e.g., user profile).
  final Widget header;

  /// The list of interactive menu items.
  final List<StunningSidebarItem> items;

  const StunningSidebar({super.key, required this.header, required this.items});

  @override
  Widget build(BuildContext context) {
    final st = StunningTheme.of(context);

    return Drawer(
      backgroundColor:
          Colors.transparent, // Background transparent rakha hai blur ke liye
      elevation: 0,
      width: 280, // Premium compact width
      child: Container(
        decoration: BoxDecoration(
          color: st.surfaceGlass,
          border: Border(
            right: BorderSide(
              color: st.borderColor,
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: st.glassBlurSigma,
              sigmaY: st.glassBlurSigma,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile or Logo Area
                  Padding(padding: const EdgeInsets.all(24.0), child: header),
                  Divider(
                    color: st.borderColor,
                    thickness: 1,
                    height: 1,
                  ),

                  // Menu Items
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      children: items,
                    ),
                  ),

                  // Footer Area (Optional Settings/Logout)
                  Divider(
                    color: st.borderColor,
                    thickness: 1,
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: StunningSidebarItem(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
