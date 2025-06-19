// login_page.dart
// 
// This screen provides a login form for users to authenticate into the Car Spotting app using email and password.
// Users can enter their credentials, validate inputs, and log in via Firebase Authentication.
// If login fails (e.g., user not found, wrong password), appropriate error messages are shown.
// The screen also provides navigation options to the registration page.
import 'package:car_spotting_app/screens/auth_screen/register_page.dart';
import 'package:car_spotting_app/screens/navigation/feed_navigation_page.dart';
import 'package:flutter/material.dart';
import 'package:car_spotting_app/colours/app_colours.dart';
import 'package:firebase_auth/firebase_auth.dart';

// The LoginPage widget provides the login interface for the Car Spotting app.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// State class for LoginPage. Handles form validation, login logic,
// error handling, and navigation to the main app on success.
class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  String? emailNoExists;
  String? isPassword;
  String? isLoginFailed;

  // Handles login authentication using FirebaseAuth with email and password.
  // Displays error messages for various failure scenarios.
  Future<void> _handleLogin(context) async {
    // Simple login handling
    final email = _loginEmailController.text;
    final password = _loginPasswordController.text;

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      setState(() {
        emailNoExists = null;
        isPassword = null;
        isLoginFailed = null;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FeedNavigationPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          emailNoExists = 'No user found. Please try again.';  
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          isPassword = 'Incorrect password.';
        });
      } else if  (e.code == 'invalid-credential') {
        setState(() {
          isPassword = 'Email or Password is incorrect.';
        });
      }
    } catch (e) {
      setState(() {
        isLoginFailed = 'Unexpected Login Failure Occured. Please try again.';
      });
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
                      'Sign into your',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: GlobalColours.primaryText,
                      ),
                    ),
                    Text(
                      'Account',
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: GlobalColours.primaryText,
                      ),
                    ),
                    const SizedBox(height: 30,),
                    Text(
                      'Sign into Account',
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
              _buildLoginFrom(context),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the login form with email and password fields, validation, and submit button.
  Widget _buildLoginFrom(context) {
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
              controller: _loginEmailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: emailNoExists,
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
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                // Validate email field using regex pattern.
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
              controller: _loginPasswordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: isPassword,
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
                return null;
              },
            ),
            const SizedBox(height: 10),
            if (isLoginFailed != null) ...[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'An unexpected error occured during login. Please try again.',
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
                  ),
                ],
              ),
            ],
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _handleLogin(context);
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
                  'Login',
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
                  "Don't have an account?",
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
                      MaterialPageRoute(builder: (context) => RegisterPage())
                    );
                  },
                  child: Text(
                    'Register',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.normal,
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