// settings_page.dart
// This page displays the app's settings screen, including a logout option.
// Users can sign out and return to the authentication screen.
import 'package:car_spotting_app/screens/auth_screen/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:car_spotting_app/colours/app_colours.dart';
import 'package:google_sign_in/google_sign_in.dart';

// The Settings page where users can manage their account and logout.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with back button and title
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: GlobalColours.primaryText,
          ),
        ),
        centerTitle: true,
        backgroundColor: GlobalColours.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: GlobalColours.primaryText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      // Settings body with logout option
      body: Container(
        width: double.infinity,
        color: GlobalColours.background,
        child: Column(
          children: [
            const Divider(   // Divider above the logout option
              thickness: 1,
              color: SettingsColours.divider,
            ),
            LogoutWidget(),   // The logout button
            const Divider(   // Divider below the logout option
              thickness: 1,
              color: SettingsColours.divider,
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable widget that handles the user logout functionality.
class LogoutWidget extends StatelessWidget {
  const LogoutWidget({super.key});

  // Signs the user out of Firebase Auth and navigates to the AuthScreen.
  // Uses pushAndRemoveUntil to clear navigation stack.
  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    if (context.mounted) {
       Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.90,
        child: TextButton(   // Button for logging out
          onPressed: () => _handleLogout(context),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.logout, color: GlobalColours.primaryText),
                  const SizedBox(width: 10),
                  Text(
                    'Logout',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: GlobalColours.primaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}