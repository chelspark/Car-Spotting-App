import 'package:flutter_test/flutter_test.dart';
import 'package:car_spotting_app/screens/upload/upload_page.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Upload page has form fields and upload button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: UploadPage()));

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Car make'), findsOneWidget);
    expect(find.text('Car model'), findsOneWidget);
    expect(find.text('Year').at(0), findsOneWidget);
    expect(find.text('Location').at(0), findsOneWidget);
    expect(find.text('Description').at(0), findsOneWidget);
    expect(find.text('Post'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
  });

  testWidgets('Tap Post button without media shows error snackbar', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: UploadPage()));

    // Fill in all form fields
    await tester.enterText(find.widgetWithText(TextFormField, 'Add a title'), 'Test Car');
    await tester.enterText(find.widgetWithText(TextFormField, 'Make'), 'Toyota');
    await tester.enterText(find.widgetWithText(TextFormField, 'Model'), 'Supra');
    await tester.enterText(find.widgetWithText(TextFormField, 'Year'), '1998');
    await tester.enterText(find.widgetWithText(TextFormField, 'Location'), 'Tokyo, Japan');
    await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'A cool car spotted in Japan.');

    // Apply form input changes
    await tester.pump();

    // Tap the Post button
    await tester.tap(find.text('Post'));
    await tester.pump(const Duration(seconds: 3)); // Trigger animations

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Please select an image.'), findsOneWidget);
  });
}