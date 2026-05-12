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

    testWidgets('should render search bar and view toggle', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.grid_view), findsOneWidget);
      expect(find.byIcon(Icons.format_list_bulleted), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should update search query when typing', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'test');
      await tester.pump();

      expect(find.text('test'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render basic layout structure', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      // Check basic widgets present
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Column), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
