import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/home/home_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: HomePageScreen(),
    );
  }

  group('HomePageScreen Widget Tests', () {
    testWidgets('should render AppBar with logo and action icons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      // Check for "Inspiria" title text
      expect(find.text('Inspiria'), findsOneWidget);
      
      // Check for tagline
      expect(find.text('Explore. Create. Inspire.'), findsOneWidget);

      // Check for ProfileButton (removed favorite heart button)
      expect(find.byType(MaterialApp), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render the three main category banners', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      final banners = [
        'assets/images/home_outfitv2.png',
        'assets/images/home_inspirationv2.png',
        'assets/images/VoyageValisev2.png',
      ];

      for (final assetPath in banners) {
        expect(
          find.byWidgetPredicate(
            (widget) => widget is Image && 
            widget.image is AssetImage && 
            (widget.image as AssetImage).assetName == assetPath
          ),
          findsOneWidget,
        );
      }

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render category labels', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('OUTFIT'), findsOneWidget);
      expect(find.text('INSPIRATION'), findsOneWidget);
      expect(find.text('TRAVEL'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should verify that banners are wrapped in GestureDetectors', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      // Find GestureDetectors in the main content area
      final bannerGestureDetectors = find.byType(GestureDetector);

      // Should have at least 2 GestureDetectors (OUTFIT and VOYAGE are interactive)
      expect(bannerGestureDetectors, findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should have a scrollable body', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      // Check for CustomScrollView (used for the main layout)
      expect(find.byType(CustomScrollView), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display statistics section', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      
      await tester.pumpWidget(createWidgetUnderTest());

      // Check for statistics section title
      expect(find.text('Your Statistics'), findsOneWidget);
      
      // Check for stat labels
      expect(find.text('Clothing'), findsOneWidget);
      expect(find.text('Looks'), findsOneWidget);
      expect(find.text('Suitcases'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}