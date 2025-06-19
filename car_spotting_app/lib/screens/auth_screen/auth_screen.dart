// auth_screen.dart
// This screen provides entry points for user authentication in the Car Spotting App.
// It allows users to sign in using Google, sign up via email, or log in if they have an existing account.
// It also handles first-time Google sign-in user data creation in Firestore.
//
// Dependencies:
// - FirebaseAuth for authentication
// - GoogleSignIn for OAuth flow
// - Firestore for user profile storage
import 'package:car_spotting_app/screens/auth_screen/login_page.dart';
import 'package:car_spotting_app/screens/auth_screen/register_page.dart';
import 'package:car_spotting_app/screens/navigation/feed_navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:car_spotting_app/colours/app_colours.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// The AuthScreen serves as the landing page for authentication.
// It offers options to:
// - Sign in with Google (using FirebaseAuth and GoogleSignIn)
// - Register with email
// - Log in for existing users
// It also initializes Firestore user data for new Google sign-ins.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  // Handles the Google sign-in flow using Firebase Authentication and GoogleSignIn.
  // If the user is signing in for the first time, it creates a new user document in Firestore.
  // Returns the UserCredential after successful sign-in.
  Future<void> signInWithGoogle(BuildContext context) async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // If the user cancels sign-in, throw an error
  if(googleUser == null) {
    return Future.error('Sign-in aborted');
  }

  // Retrieve authentication details from Google
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  
  // Sign in with Firebase using the credential
  final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  final user = userCredential.user;

  // Check Firestore: If this user is new, create a user document
  final docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
  final docSnapshot = await docRef.get();

  if (!docSnapshot.exists) {
    await docRef.set({
      'email': user.email,
      'name': user.displayName ?? '',
      'profileImage': user.photoURL ?? '',
      'bio': '',
      'createdAt': Timestamp.now(),
    });
  }
  // Once signed in, return the UserCredential
  if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FeedNavigationPage()),
        (route) => false,
      );
    }
}
  // Builds the UI for the authentication landing page.
  // Provides buttons for Google sign-in, email sign-up, and log in.
  @override
  Widget build(context) {
    return Scaffold(
      body: Container(
        color: GlobalColours.background,
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 60),
              Text(   // App title
                "Car Spotter",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: GlobalColours.primaryText,
                ),
              ),
              SizedBox(height: 15),
              Image.asset(   // App branding image
                'assets/images/car_spotter_bg_img.png'
              ),
              SizedBox(height: 20),
              Text(   // App subtitle text
                "The world's best car",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: GlobalColours.primaryText,
                ),
              ),
              Text(   // App subtitle text
                "spotting community",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: GlobalColours.primaryText,
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 48,
                child: ElevatedButton(   // Button: Continue with Google
                  onPressed: () => signInWithGoogle(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LandingColours.btnBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue with Google',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: GlobalColours.primaryText,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 48,
                child: ElevatedButton(   // Button: Sign Up with Email
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder:(context) => RegisterPage(),)
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LandingColours.btnBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Sign Up with Email',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: GlobalColours.primaryText,
                    ),
                  ),
                ),
              ),
              TextButton(   // TextButton: Navigate to LoginPage
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder:(context) => LoginPage())
                  );
                },
                child: Text(
                  'Have an account already? Log in.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF888E9C),
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.5,
                      decorationColor: Color(0xFF888E9C),
                    ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}