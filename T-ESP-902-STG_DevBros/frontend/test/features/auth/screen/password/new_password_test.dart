import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/auth/screen/password/new_password.dart';

Widget _materialApp(Widget child) {
  return MaterialApp(
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NewPasswordScreen', () {
    testWidgets('Should show error when password fields are empty and button pressed', (tester) async {
      await tester.pumpWidget(_materialApp(const NewPasswordScreen(email: 'a@b.com', otp: '123456')));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email and password.'), findsOneWidget);
    });

    testWidgets('Should clear error message when user starts typing (first field)', (tester) async {
      await tester.pumpWidget(_materialApp(const NewPasswordScreen(email: 'a@b.com', otp: '123456')));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Please enter your email and password.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'x');
      await tester.pump();

      expect(find.text('Please enter your email and password.'), findsNothing);
      expect(find.text('Please check your credentials. Try again.'), findsNothing);
    });

    testWidgets('Should clear error message when user starts typing (confirm field)', (tester) async {
      await tester.pumpWidget(_materialApp(const NewPasswordScreen(email: 'a@b.com', otp: '123456')));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(find.text('Please enter your email and password.'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(1), 'y');
      await tester.pump();

      expect(find.text('Please enter your email and password.'), findsNothing);
    });

    testWidgets('Should toggle obscure text when eye icon pressed', (tester) async {
      await tester.pumpWidget(_materialApp(const NewPasswordScreen(email: 'a@b.com', otp: '123456')));

      final editable = find.byType(EditableText).first;
      expect(editable, findsOneWidget);

      EditableText editableWidget = tester.widget(editable);
      expect(editableWidget.obscureText, isTrue);

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      editableWidget = tester.widget(editable);
      expect(editableWidget.obscureText, isFalse);
    });

    testWidgets('Should keep button enabled and submit when both fields filled (no crash smoke test)', (tester) async {
      await tester.pumpWidget(_materialApp(const NewPasswordScreen(email: 'a@b.com', otp: '123456')));

      await tester.enterText(find.byType(TextFormField).at(0), 'Password123!');
      await tester.enterText(find.byType(TextFormField).at(1), 'Password123!');

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your email and password.'), findsNothing);
    });
  });
}
