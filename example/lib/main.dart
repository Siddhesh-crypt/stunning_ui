import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stunning_ui/stunning_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stunning UI Suite',
      debugShowCheckedModeBanner: false,

      // Is line ko change kiya gaya hai:
      themeMode: ThemeMode.dark, // Ab ye humesha dark theme hi dikhayega
      // Light theme configuration rakh sakte ho in case future me refine karna ho,
      // par active sirf dark theme hi rahegi.
      theme: ThemeData.light().copyWith(
        extensions: <ThemeExtension<dynamic>>[StunningTheme.light()],
      ),
      darkTheme: ThemeData.dark().copyWith(
        extensions: <ThemeExtension<dynamic>>[StunningTheme.dark()],
      ),
      home: const ExampleDashboard(),
    );
  }
}

class ExampleDashboard extends StatefulWidget {
  const ExampleDashboard({super.key});

  @override
  State<ExampleDashboard> createState() => _ExampleDashboardState();
}

class _ExampleDashboardState extends State<ExampleDashboard> {
  int _currentNavIndex = 0; // Navigation state

  // Dummy pages for navigation test
  // example/lib/main.dart ke andar _ExampleDashboardState me:

  // example/lib/main.dart me _pages list ko isse replace karo:

  late final List<Widget> _pages = [
    // PAGE 1: Home (Showing 3D Carousel & Toast)
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Featured Collections',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),

        // 3D Carousel Implementation
        StunningCarousel(
          height: 320,
          items: [
            _buildCarouselCard(
              title: 'Neon Pack',
              icon: Icons.graphic_eq,
              color: Colors.purpleAccent,
            ),
            _buildCarouselCard(
              title: 'Glass Kit',
              icon: Icons.layers,
              color: Colors.blueAccent,
            ),
            _buildCarouselCard(
              title: 'Cyber UI',
              icon: Icons.memory,
              color: Colors.cyanAccent,
            ),
          ],
        ),
      ],
    ),

    // PAGE 2, 3, 4 (Placeholder)
    const SearchTabDemo(),

    const Center(
      child: Text(
        'Map Content',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
    const Center(
      child: Text(
        'Profile Content',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    ),
  ];

  // Helper method for generating Carousel Cards
  Widget _buildCarouselCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Builder(
      // Builder zaroori hai OverlayContext ke liye
      builder: (context) {
        return GestureDetector(
          onTap: () {
            // Triggering the custom toast on tap
            StunningToast.show(
              context: context,
              message: '$title selected successfully!',
              icon: Icons.check_circle_outline,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 60, color: color),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CRITICAL: Ye property background ko nav bar ke niche render hone deti hai
      // jisse glass blur sahi se dikhta hai
      extendBody: true,
      // NAYI LINE: Transparent App Bar with Drawer Icon
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // NAYI LINE: Hamara Glassmorphic Sidebar
      drawer: StunningSidebar(
        header: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.purpleAccent,
              child: Icon(Icons.person, size: 30, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Siddhesh Lad',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Premium User',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
        items: [
          StunningSidebarItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            isActive: true,
            onTap: () {},
          ),
          StunningSidebarItem(
            icon: Icons.analytics,
            title: 'Analytics',
            onTap: () {},
          ),
          StunningSidebarItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {},
          ),
        ],
      ),

      body: Stack(
        children: [
          // Global Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2564&auto=format&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Current Page Content (Animated for smooth transition)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_currentNavIndex],
          ),
        ],
      ),

      // Hamara Naya Stunning Nav Bar
      bottomNavigationBar: StunningBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
        items: const [
          StunningNavItem(icon: Icons.grid_view_rounded), // Home
          StunningNavItem(icon: Icons.search_rounded), // Search
          StunningNavItem(icon: Icons.map_rounded), // Map/Discover
          StunningNavItem(icon: Icons.person_rounded), // Profile
        ],
      ),
    );
  }
}

// Add this at the bottom of example/lib/main.dart
class SearchTabDemo extends StatefulWidget {
  const SearchTabDemo({super.key});

  @override
  State<SearchTabDemo> createState() => _SearchTabDemoState();
}

class _SearchTabDemoState extends State<SearchTabDemo> {
  int _selectedFilter = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading for 3 seconds then show data
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const Text(
            'Search & Filter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          // 1. Testing Segmented Control
          StunningSegmentedControl(
            options: const ['Trending', 'Recent', 'Favorites'],
            selectedIndex: _selectedFilter,
            onValueChanged: (index) {
              setState(() {
                _selectedFilter = index;
                _isLoading = true; // Re-trigger loading on filter change
              });
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) setState(() => _isLoading = false);
              });
            },
          ),

          const SizedBox(height: 40),

          // 2. Testing Shimmer Skeleton
          Expanded(
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return StunningShimmer(
                  isLoading: _isLoading,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: _isLoading
                        ? const SizedBox() // Blank container for shimmer to mask over
                        : const Center(
                            child: Text(
                              'Loaded Data Item',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
