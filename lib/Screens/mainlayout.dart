import 'package:flutter/material.dart';

import 'dart:ui'; // Import this for the blur effect
import 'package:movcheck/Screens/Homescreen.dart';
import 'package:movcheck/Screens/Searchpage.dart';
import 'package:movcheck/Screens/Wishlist.dart';
import 'package:movcheck/providers/theme_provider.dart';
import 'package:provider/provider.dart';

// --- Placeholder pages (no changes needed here) ---


class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Account'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dark Mode', style: TextStyle(fontSize: 18)),
            Switch.adaptive(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                final provider = Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                );
                provider.toggleTheme(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
// ----------------------------------------------------

class Mainlayout extends StatefulWidget {
  const Mainlayout({super.key});
  @override
  State<Mainlayout> createState() => _Layoutstate();
}

class _Layoutstate extends State<Mainlayout> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    SearchPage(),
    WishlistPage(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Keep this to draw behind the nav bar
      body: Stack(
        children: [
          _pages.elementAt(_selectedIndex),
          Align(alignment: Alignment.bottomCenter, child: _buildCustomNavBar()),
        ],
      ),
    );
  }

  /// Builds the custom animated navigation bar.
  Widget _buildCustomNavBar() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double navBarWidth = screenWidth - 70;
    final double itemWidth = navBarWidth / _pages.length;

    // This outer container is now just for positioning and shadow.
    return Container(
      height: 70,
      width: navBarWidth,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // We use ClipRRect to contain the blur effect within the rounded corners.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            // This container provides the semi-transparent "glass" color.
            color:
                (Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
                        Theme.of(context).colorScheme.surface)
                    .withOpacity(0.4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.decelerate,
                  left: _selectedIndex * itemWidth,
                  top: 0,
                  height: 70,
                  width: itemWidth,
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_rounded, 0),
                    _buildNavItem(Icons.search_rounded, 1),
                    _buildNavItem(Icons.favorite_border_rounded, 2),
                    _buildNavItem(Icons.person_outline_rounded, 3),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper widget to build each individual navigation item.
  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.translucent,
        child: Center(
          child: Icon(
            icon,
            size: 28,
            color: isSelected
                ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                : Theme.of(
                    context,
                  ).bottomNavigationBarTheme.unselectedItemColor,
          ),
        ),
      ),
    );
  }
}
