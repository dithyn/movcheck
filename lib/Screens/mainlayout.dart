import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:movcheck/Screens/Homescreen.dart';
// <-- IMPORTANT: Replace
// I've renamed 'first.dart' to 'home_screen.dart' to follow Flutter conventions.
// Make sure you rename your file and the class inside it to 'HomeScreen'.

// --- Placeholder pages to prevent navigation errors ---
// You will replace these with your actual screen widgets later.
// ---------------------------------------------------------

class Mainlayout extends StatefulWidget {
  const Mainlayout({super.key});
  @override
  State<Mainlayout> createState() => Layoutstate();
}

class Layoutstate extends State<Mainlayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.decelerate));
  }

  void toggleDrawer() {
    if (_controller.isCompleted) {
      _controller.reverse(); // hide
    } else {
      _controller.forward(); // show
    }
  }

  int index = 0;
  List<int> history = [0];

  // This list now contains your HomeScreen and placeholder widgets for the other pages.
  // This is crucial to prevent "index out of range" errors when you navigate.
  final List<Widget> pages = [
    HomeScreen(), // Index 3
    // Add more pages here as needed
  ];

  void onnavigate(int newindex) {
    // Check if the index is valid before navigating
    if (newindex >= 0 && newindex < pages.length) {
      setState(() {
        index = newindex;
        history.add(index);
      });
    } else {
      print("Error: Invalid page index $newindex");
    }
  }

  Future<bool> _willpop() async {
    if (history.length > 1) {
      setState(() {
        history.removeLast();
        index = history.last;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willpop,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            PageTransitionSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              // The key ensures the transition happens when the index changes.
              child: IndexedStack(index: index, children: pages),
            ),
            // Your slide-out drawer menu
            // SlideTransition(
            //   position: _slideAnimation,
            //   child: ClipRRect(
            //     borderRadius: const BorderRadius.only(
            //       // <-- FIX: Was BorderRadiusGeometry.only
            //       topRight: Radius.circular(30),
            //       bottomRight: Radius.circular(30),
            //     ),
            //     child: Container(
            //       width: MediaQuery.of(context).size.width - 30,
            //       decoration: BoxDecoration(
            //         // Added a backdrop blur to make it look nice
            //         color: Colors.grey.shade900.withOpacity(0.8),
            //         border: Border.all(width: 2, color: Colors.black26),
            //         borderRadius: const BorderRadius.only(
            //           bottomRight: Radius.circular(30),
            //           topRight: Radius.circular(30),
            //         ),
            //       ),
            //       child: BackdropFilter(
            //         filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            //         child: Padding(
            //           padding: const EdgeInsets.only(
            //             left: 20,
            //             top: 60,
            //           ), // Adjusted top padding
            //           child: Column(
            //             // <-- FIX: Removed invalid 'spacing' property
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Row(
            //                 // <-- FIX: Removed invalid 'spacing' property
            //                 children: const [
            //                   CircleAvatar(
            //                     backgroundImage: AssetImage(
            //                       'assets/users/me.jpg',
            //                     ),
            //                     radius: 30,
            //                   ),
            //                   SizedBox(width: 20), // Use SizedBox for spacing
            //                   Text(
            //                     "Hello, Adithyan!",
            //                     style: TextStyle(
            //                       fontFamily: 'HelveticaNeue',
            //                       fontSize: 20,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //               const SizedBox(
            //                 height: 40,
            //               ), // Use SizedBox for spacing
            //               // --- Navigation Buttons ---
            //               _buildNavButton(text: "Account", onPressed: () {}),
            //               _buildNavButton(
            //                 text: "Cart",
            //                 onPressed: () {
            //                   // Navigate to CartScreen (index 1)
            //                   toggleDrawer();
            //                 },
            //               ),
            //               _buildNavButton(
            //                 text: "Wishlist",
            //                 onPressed: () {
            //                   toggleDrawer();
            //                 },
            //               ),
            //               _buildNavButton(
            //                 text: "Settings",
            //                 onPressed: () {
            //                   toggleDrawer();
            //                 },
            //               ),
            //               _buildNavButton(text: "About", onPressed: () {}),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Helper method to avoid repeating button code
  Widget _buildNavButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.1),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          fixedSize: const Size(280, 50),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontFamily: 'Helvetica')),
      ),
    );
  }
}
