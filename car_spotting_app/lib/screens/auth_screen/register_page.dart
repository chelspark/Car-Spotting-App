// register_page.dart
// This file implements the RegisterPage screen, allowing users to sign up with email and password.
// It handles Firebase authentication and user profile creation in Firestore.
import 'package:car_spotting_app/screens/auth_screen/auth_screen.dart';
import 'package:car_spotting_app/screens/navigation/feed_navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:car_spotting_app/colours/app_colours.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// A stateful widget for user registration using email and password.
// Displays a registration form and creates a new user in Firebase Authentication and Firestore.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();

  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  String? emailExists;
  String? isRegisterFailed;

  // Handles the user registration logic using Firebase Authentication.
  // Creates a new user and saves basic profile info in Firestore.
  // Navigates to the FeedNavigationPage on success.
  Future<void> _handleRegister(context) async {
    final email = _registerEmailController.text;
    final password = _registerPasswordController.text;
    final confirmPassword = _registerConfirmPasswordController.text;

    // Ensure password and confirmation match before proceeding
    if (password != confirmPassword) {
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      final userEmail = credential.user?.email;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': userEmail,
        'name': '',
        'profileImage': '',
        'bio': '',
        'createdAt': DateTime.now(),
      });
      setState(() {
        emailExists = null;  
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FeedNavigationPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // print('he password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          emailExists = 'The email address is already in use by another account';
        });
      }
    } catch (e) {
      setState(() {
        isRegisterFailed = 'Unexpected Registration Failure Occured. Please Try again.';
      });
      // print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: GlobalColours.background,
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Register',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: GlobalColours.primaryText,
                      ),
                    ),
                    const SizedBox(height: 30,),
                    Text(
                      'Create your account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                        color: GlobalColours.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 0.5,
                color: GlobalColours.primaryText,
                height: 1,
              ),
              const SizedBox(height: 30),
              _buildRegisterFrom(context),
            ],
          ),
        ),
      ),
    );
  }

  // Registration form fields for email, password, and confirmation
  Widget _buildRegisterFrom(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.84,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 5),
            TextFormField(
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: GlobalColours.primaryText,
              ),
              controller: _registerEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: emailExists,
                errorMaxLines: 2,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                floatingLabelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: GlobalColours.primaryText,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: const BorderSide(color: AuthColours.inputBorder),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                // Email format validation using regex
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            TextFormField(
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: GlobalColours.primaryText,
              ),
              controller: _registerPasswordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorMaxLines: 2,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                floatingLabelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: GlobalColours.primaryText,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: const BorderSide(color: AuthColours.inputBorder),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password is required';
                // Password requires at least 8 characters and a number
                final passwordRegex = RegExp(r'^(?=.*[0-9]).{8,}$');
                if (!passwordRegex.hasMatch(value)) {
                  return 'Password must be at least 8 characters and include a number';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            TextFormField(
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: GlobalColours.primaryText,
              ),
              controller: _registerConfirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                floatingLabelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: GlobalColours.primaryText,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: const BorderSide(
                    color: AuthColours.inputBorder,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Confirmation Password is required';
                if (value != _registerPasswordController.text) return "Password does not match";
                return null;
              },
            ),
            const SizedBox(height: 10),
            if (isRegisterFailed != null) ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'An unexpected error occurred during registration.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color.fromARGB(255, 185, 0, 0),
                    ),
                  ),
                  Text(
                    'Please try again.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color.fromARGB(255, 185, 0, 0),
                    ),
                  )
                ],
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _handleRegister(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlobalColours.primaryAction,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 18),
                ),
                child: Text(
                  'Register',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'I have an account?',
                  // textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: AuthColours.secondaryText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuthScreen())
                    );
                  },
                  child: Text(
                    'Log in',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: GlobalColours.primaryAction,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}