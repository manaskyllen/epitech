import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:inspiria/features/home/widgets/bottom_navigation_widget.dart';
import 'package:inspiria/routes/router_enum.dart';

void main() {
  GoRouter createTestRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return BottomNavigationWidget(child: child);
          },
          routes: [
            GoRoute(
              path: SCREEN.LAUNCHPAGE.path,
              builder: (context, state) => const Scaffold(body: Text('Home Page')),
            ),
            GoRoute(
              path: SCREEN.TRAVEL.path,
              builder: (context, state) => const Scaffold(body: Text('Travel Page')),
            ),
            GoRoute(
              path: SCREEN.SCANNER.path,
              builder: (context, state) => const Scaffold(body: Text('Scanner Page')),
            ),
            GoRoute(
              path: '/resultat-test',
              builder: (context, state) => const Scaffold(body: Text('Favorites Page')),
            ),
            GoRoute(
              path: SCREEN.MYCHARACTER.path,
              builder: (context, state) => const Scaffold(body: Text('Profile Page')),
            ),
          ],
        ),
      ],
    );
  }

  group('BottomNavigationWidget Tests', () {
    testWidgets('should select index 0 when on LaunchPage', (WidgetTester tester) async {
      final router = createTestRouter(SCREEN.LAUNCHPAGE.path);
      
      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));

      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, 0);
    });

    testWidgets('should select index 2 when on /resultat-test route', (WidgetTester tester) async {
      final router = createTestRouter('/resultat-test');

      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));

      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, 2); 
    });

    testWidgets('should navigate to profile route when profile icon (index 4) is tapped', (WidgetTester tester) async {
      final router = createTestRouter(SCREEN.LAUNCHPAGE.path);

      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));

      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      expect(router.routerDelegate.currentConfiguration.last.matchedLocation, SCREEN.MYCHARACTER.path);
    });

    testWidgets('should display selection dot on the active index', (WidgetTester tester) async {
      final router = createTestRouter(SCREEN.LAUNCHPAGE.path);

      await tester.pumpWidget(MaterialApp.router(
        routerConfig: router,
      ));

      await tester.pumpAndSettle();

      final circleFinder = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).shape == BoxShape.circle);

      expect(circleFinder, findsWidgets);
    });
  });
}