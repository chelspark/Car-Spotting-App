// feed_navigation_page.dart
// This file defines the `FeedNavigationPage`, the main navigation page 
// for the Car Spotting App. It includes a bottom navigation bar with 
// three main screens: Home Feed, Upload, and Profile.
//
// Features:
// - BottomNavigationBar for navigation.
// - Custom slide-up transition when opening the Upload page.
// - Manages state to highlight the selected tab.
import 'package:car_spotting_app/screens/home_screen/home_feed_page.dart';
import 'package:car_spotting_app/screens/profile/profile_page.dart';
import 'package:car_spotting_app/screens/upload/upload_page.dart';
import 'package:flutter/material.dart';
import 'package:car_spotting_app/colours/app_colours.dart';

class FeedNavigationPage extends StatefulWidget {
  const FeedNavigationPage({super.key});

  @override
  State<FeedNavigationPage> createState() => _FeedNavigationPageState();
}

class _FeedNavigationPageState extends State<FeedNavigationPage> {
  int _selectedIndex = 0;

  // List of pages corresponding to the BottomNavigationBar tabs.
  final List<Widget> _pages = [
    HomeFeedPage(),
    UploadPage(),
    ProfilePage(),
  ];

  // Handles tap events on the BottomNavigationBar.
  // If the Upload tab is tapped (index 1), opens the Upload page with a slide-up animation.
  // For other tabs, updates the selected index to show the corresponding page.
  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const UploadPage(),
          transitionsBuilder: (context, animation, secondadryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          }
        )
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Builds the scaffold for the navigation page, including the current screen and bottom navigation bar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: GlobalColours.background,
        selectedItemColor: GlobalColours.primaryAction,
        unselectedItemColor: Color(0xFFFFFFFF),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ]
      ),
    );
  }
}