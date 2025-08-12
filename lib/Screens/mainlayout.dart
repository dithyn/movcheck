import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:movcheck/Screens/Homescreen.dart';
import 'package:movcheck/Screens/Searchpage.dart';
import 'package:movcheck/Screens/Wishlist.dart';
import 'package:movcheck/Screens/Accounts.dart';
import 'package:movcheck/Screens/categories_page.dart'; // Import the new page

class Mainlayout extends StatefulWidget {
  const Mainlayout({super.key});
  @override
  State<Mainlayout> createState() => _Layoutstate();
}

class _Layoutstate extends State<Mainlayout> {
  int _selectedIndex = 0;

  // UPDATED: Added CategoriesPage to the list
  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    SearchPage(),
    CategoriesPage(), // New page
    WishlistPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _pages.elementAt(_selectedIndex),
          Align(alignment: Alignment.bottomCenter, child: _buildCustomNavBar()),
        ],
      ),
    );
  }

  Widget _buildCustomNavBar() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double navBarWidth = screenWidth - 40; // Adjusted width for 5 items
    final double itemWidth = navBarWidth / _pages.length;

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color:
                (Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
                        Theme.of(context).colorScheme.surface)
                    .withOpacity(0.7),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
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
                // UPDATED: Added new nav item
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_rounded, 0),
                    _buildNavItem(Icons.search_rounded, 1),
                    _buildNavItem(Icons.category_outlined, 2), // New icon
                    _buildNavItem(Icons.favorite_border_rounded, 3),
                    _buildNavItem(Icons.person_outline_rounded, 4),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
