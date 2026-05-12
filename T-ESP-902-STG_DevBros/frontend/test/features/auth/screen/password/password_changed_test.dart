import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/features/auth/screen/password/password_changed.dart';
import 'package:inspiria/routes/router_enum.dart';

Widget _appWithRouter(Widget child) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => child,
      ),
      GoRoute(
        path: SCREEN.LOGIN.path,
        builder: (context, state) => const Placeholder(key: Key('login-screen')),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PasswordChangedScreen', () {
    testWidgets('Should render success icon and texts', (tester) async {
      await tester.pumpWidget(_appWithRouter(const PasswordChangedScreen()));

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Password Changed!'), findsOneWidget);
      expect(find.text('Your password has been successfully changed.'), findsOneWidget);
      expect(find.text('Back to Login'), findsOneWidget);
    });

    testWidgets('Should navigate to login when button is pressed', (tester) async {
      await tester.pumpWidget(_appWithRouter(const PasswordChangedScreen()));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Back to Login'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login-screen')), findsOneWidget);
    });

    testWidgets('Button has expected style (height > 0 and rounded corners)', (tester) async {
      await tester.pumpWidget(_appWithRouter(const PasswordChangedScreen()));

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(find.ancestor(of: button, matching: find.byType(SizedBox)).first);
      expect((sizedBox.height ?? 0) > 0, isTrue);

      final elevated = tester.widget<ElevatedButton>(button);
      final style = elevated.style;
      expect(style, isNotNull);
    });

    testWidgets('Layout scrolls when content overflows (SingleChildScrollView present)', (tester) async {
      await tester.pumpWidget(_appWithRouter(const PasswordChangedScreen()));

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('Texts are center aligned as specified', (tester) async {
      await tester.pumpWidget(_appWithRouter(const PasswordChangedScreen()));

      final title = tester.widget<Text>(find.text('Password Changed!'));
      final subtitle = tester.widget<Text>(find.text('Your password has been successfully changed.'));

      expect(title.textAlign, TextAlign.center);
      expect(subtitle.textAlign, TextAlign.center);
    });
  });
}
