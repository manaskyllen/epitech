import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inspiria/features/suitcase/screen/suitcase_screen.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('SuitcaseScreen Widget Tests', () {
    testWidgets('SuitcaseScreen can be instantiated', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SuitcaseScreen()),
      );
      // Allow one frame for animations to initialize
      await tester.pump(const Duration(milliseconds: 100));
      
      // If we arrive here without error, test passes
      expect(find.byType(SuitcaseScreen), findsOneWidget);
    });

    testWidgets('SuitcaseScreen renders Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SuitcaseScreen()),
      );
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('SuitcaseScreen renders AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SuitcaseScreen()),
      );
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('SuitcaseScreen renders SingleChildScrollView', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SuitcaseScreen()),
      );
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('SuitcaseScreen renders Column with content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SuitcaseScreen()),
      );
      await tester.pump(const Duration(milliseconds: 100));
      
      expect(find.byType(Column), findsWidgets);
    });
  });
}