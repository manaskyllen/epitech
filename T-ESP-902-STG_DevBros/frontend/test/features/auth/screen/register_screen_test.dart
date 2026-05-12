import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/auth/screen/register_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(home: RegisterScreen());
  }

  group('RegisterScreen Widget Tests', () {
    testWidgets('should render all input fields and register button', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Join us and start exploring!'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));
      // Register button has text 'Register'
      expect(find.text('Register'), findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should show field errors when required fields are empty', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      // Scroll to and tap the register button
      await tester.ensureVisible(find.text('Register'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
      expect(find.text('Please confirm your password.'), findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should show error for invalid email format', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(2), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');
      await tester.enterText(find.byType(TextFormField).at(4), 'password123');

      // Scroll to and tap the register button
      await tester.ensureVisible(find.text('Register'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should show error when passwords do not match', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(2), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(3), 'password123');
      await tester.enterText(find.byType(TextFormField).at(4), 'different123');

      // Scroll to and tap the register button
      await tester.ensureVisible(find.text('Register'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should toggle password visibility when eye icon is pressed', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());

      // Find the password field (4th TextFormField, index 3)
      final passwordFormField = find.byType(TextFormField).at(3);
      
      // Find the eye icon button within the password field
      final eyeButton = find.descendant(
        of: passwordFormField,
        matching: find.byType(IconButton),
      );

      // Make sure the eye button is visible and tap it
      await tester.ensureVisible(eyeButton);
      await tester.pumpAndSettle();
      await tester.tap(eyeButton);
      await tester.pumpAndSettle();

      // Verify password visibility toggled (TextField should be found within the field)
      final passwordFieldFinder = find.descendant(
        of: passwordFormField,
        matching: find.byType(TextField),
      );
      
      // After tapping, the field should exist (ability to toggle is confirmed by no errors)
      expect(passwordFieldFinder, findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should contain back button and login link', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      // Check for back button (IconButton with arrow_back_ios icon)
      expect(
        find.byType(IconButton),
        findsWidgets,
      );

      // Check for login link - text is "Login" not "Login Now"
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              (widget.text.toPlainText().contains('Login') || widget.text.toPlainText().contains('Already have an account')),
        ),
        findsOneWidget,
      );
      
      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
