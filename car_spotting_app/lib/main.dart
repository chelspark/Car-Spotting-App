// main entry point of the Car Spotting App
// Initializes Firebase, App Check, and sets up authentication-based navigation.
import 'package:car_spotting_app/screens/navigation/feed_navigation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:car_spotting_app/firebase_options.dart';
import 'package:car_spotting_app/screens/auth_screen/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  // Ensures Flutter bindings are initialized before Firebase setup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific configurations
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activate Firebase App Check for enhanced security (debug mode used here)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug
  );

  // Start the app and determine home screen based on authentication state
  runApp(
    MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.beVietnamProTextTheme(),   // Set global font style
      ),
      // StreamBuilder monitors FirebaseAuth state and switches between authenticated and unauthenticated screens
      home: StreamBuilder<User?>(
        // Listen for FirebaseAuth state changes to determine login state
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            // If user is logged in, go to FeedNavigationPage; otherwise, show AuthScreen
            return user != null ? const FeedNavigationPage() : const AuthScreen();
          }
          // Show loading spinner while authentication state is loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      ),
    )
  );
}