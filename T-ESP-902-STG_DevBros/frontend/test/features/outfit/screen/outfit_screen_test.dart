import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/outfit/screen/outfit_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: OutfitScreen(),
    );
  }

  group('OutfitScreen Widget Tests', () {
    testWidgets('should render header with title and action buttons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('MY CLOSET'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render search bar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(TextField), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render view toggle buttons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      // Should have grid and list view toggle buttons
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.format_list_bulleted), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render update search query when typing', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'red');
      await tester.pump();

      expect(find.text('red'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });



    testWidgets('should render Row for horizontal alignment', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(Row), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}