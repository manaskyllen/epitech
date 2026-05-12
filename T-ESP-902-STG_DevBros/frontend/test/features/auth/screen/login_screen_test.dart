import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/auth/screen/login_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('should render all input fields and login button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Welcome back!'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      // Login button has text 'Login'
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should toggle password visibility when eye icon is pressed', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());

      final Finder passwordFieldFinder = find.descendant(
        of: find.byType(TextFormField).last,
        matching: find.byType(TextField),
      );

      expect(tester.widget<TextField>(passwordFieldFinder).obscureText, isTrue);

     
      final Finder eyeButton = find.byType(IconButton);
      
      await tester.ensureVisible(eyeButton);
      
      await tester.tap(eyeButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      final TextField updatedWidget = tester.widget<TextField>(passwordFieldFinder);
      expect(updatedWidget.obscureText, isFalse);
      
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should show error message when email or password is empty', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      // Ensure the login button is visible and tap it
      await tester.ensureVisible(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Login'));
      
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should find the forgot password button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Forgot Password?'), findsOneWidget);
      
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should contain back button and register link', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      // Check for back button (IconButton with arrow_back_ios icon)
      expect(
        find.byType(IconButton),
        findsWidgets,
      );

      // Check for register link - it contains "Sign up" not "Register Now"
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && 
          widget.text.toPlainText().contains('Sign up'),
        ),
        findsOneWidget,
      );
      
      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}