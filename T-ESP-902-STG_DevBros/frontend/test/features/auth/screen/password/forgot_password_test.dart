import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/auth/screen/password/forgot_password.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {});

  group('ForgotPasswordScreen', () {
    testWidgets('Should show error when email is empty and button pressed', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

      // Tap on Send Code without entering email
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email.'), findsOneWidget);
    });

    testWidgets('Should clear error message when user starts typing', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

      // Trigger empty email flow first
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Please enter your email.'), findsOneWidget);

      // Start typing
      await tester.enterText(find.byType(TextFormField), 'a');
      await tester.pump();

      expect(find.text('Please check your credentials. Try again.'), findsNothing);
      expect(find.text('Please enter your email.'), findsNothing);
    });
  });
}
