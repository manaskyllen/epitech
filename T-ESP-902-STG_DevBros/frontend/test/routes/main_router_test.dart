import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/routes/main_router.dart';
import 'package:inspiria/routes/router_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MainRouter Structure Tests', () {
    
    testWidgets('Initial configuration path check', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'is_first_launch': true});

      final router = setupRouter();

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      final String currentPath = router.routeInformationProvider.value.uri.path;
      
      expect(currentPath, equals(SCREEN.LAUNCHPAGE.path));
    });

    testWidgets('Should stay on LaunchPage if it is the first launch', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({'is_first_launch': true});
      
      final router = setupRouter();

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.pumpAndSettle();

      final String currentPath = router.routeInformationProvider.value.uri.path;
      expect(currentPath, equals(SCREEN.LAUNCHPAGE.path));
    });
  });
}