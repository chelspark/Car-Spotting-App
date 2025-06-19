import 'package:flutter_test/flutter_test.dart';
import 'package:car_spotting_app/screens/auth_screen/auth_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('AuthScreen displays Google and Email signup buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign Up with Email'), findsOneWidget);
  });

  // testWidgets('Tapping Sign Up with Email navigates to RegisterPage', (WidgetTester tester) async {
  //   await tester.pumpWidget(MaterialApp(home: AuthScreen()));

  //   await tester.tap(find.text('Sign Up with Email'));
  //   await tester.pumpAndSettle();

  //   expect(find.text('Register'), findsAtLeast(2));
  // });

}
