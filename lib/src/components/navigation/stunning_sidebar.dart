// lib/src/components/navigation/stunning_sidebar.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:stunning_ui/src/theme/stunning_theme.dart';

// The Individual Menu Item
class StunningSidebarItem extends StatelessWidget {
  final IconData icon;
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
    final theme = Theme.of(context).extension<StunningTheme>();
    final primary = theme?.primaryBrand ?? Colors.purpleAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? primary.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? primary.withOpacity(0.5) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? primary : Colors.white70,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
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

// The Main Sidebar Wrapper
class StunningSidebar extends StatelessWidget {
  final Widget header;
  final List<StunningSidebarItem> items;

  const StunningSidebar({
    super.key,
    required this.header,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<StunningTheme>();

    return Drawer(
      backgroundColor: Colors.transparent, // Background transparent rakha hai blur ke liye
      elevation: 0,
      width: 280, // Premium compact width
      child: Container(
        decoration: BoxDecoration(
          color: theme?.surfaceGlass ?? Colors.black.withOpacity(0.5),
          border: Border(
            right: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile or Logo Area
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: header,
                  ),
                  Divider(color: Colors.white.withOpacity(0.1), thickness: 1, height: 1),

                  // Menu Items
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      children: items,
                    ),
                  ),

                  // Footer Area (Optional Settings/Logout)
                  Divider(color: Colors.white.withOpacity(0.1), thickness: 1, height: 1),
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