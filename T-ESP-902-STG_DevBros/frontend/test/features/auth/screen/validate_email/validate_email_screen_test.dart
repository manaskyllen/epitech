import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/auth/screen/validate_email/validate_email_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ValidateEmailScreen(email: 'test@example.com'),
    );
  }

  group('ValidateEmailScreen Widget Tests', () {
    testWidgets('should display header texts and 6 OTP input fields', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('OTP Verification'), findsOneWidget);
      expect(find.text('Verify your email'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(6));
    });

    testWidgets('should show error message when OTP is empty and verify button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final verifyButton = find.widgetWithText(ElevatedButton, 'Verify Email');
      await tester.tap(verifyButton);
      await tester.pump();

      expect(find.text('Please enter your OTP.'), findsOneWidget);
    });

    testWidgets('should update OTP value and move focus when entering digits', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField).at(0), '1');
      await tester.pump();
      
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('should display error message when an invalid OTP is provided', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      for (int i = 0; i < 6; i++) {
        await tester.enterText(find.byType(TextField).at(i), '0');
      }
      
      final verifyButton = find.widgetWithText(ElevatedButton, 'Verify Email');
      await tester.tap(verifyButton);
      await tester.pump();

      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should contain a functional back button and resend email link', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Image && 
          widget.image is AssetImage && 
          (widget.image as AssetImage).assetName == 'assets/images/back.png'
        ),
        findsOneWidget,
      );

      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && 
          widget.text.toPlainText().contains('Resend Email'),
        ),
        findsOneWidget,
      );
    });
  });
}