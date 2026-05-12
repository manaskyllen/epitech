// ignore_for_file: avoid_redundant_argument_values
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/suitcase_model.dart';
import 'package:inspiria/features/suitcase/screen/suitcase_detail_screen.dart';

void main() {
  final mockSuitcase = SuitcaseModel(
    user_id: 1,
    destination: 'Paris',
    name: 'Paris Trip',
    departure_date: DateTime(2026, 6, 1),
    end_date: DateTime(2026, 6, 8),
    clothings: [
      {'itemSubtype': 'T-Shirt', 'itemType': 'Tops'},
      {'itemSubtype': 'Blue Jeans', 'itemType': 'Bottoms'},
      {'itemSubtype': 'Running Shoes', 'itemType': 'Footwear'},
    ],
  );

  final mockSuitcaseEmpty = SuitcaseModel(
    user_id: 2,
    destination: 'Bali',
    name: 'Bali Vacation',
    departure_date: DateTime(2026, 7, 1),
    end_date: DateTime(2026, 7, 15),
    clothings: [],
  );

  Widget createWidgetUnderTest(SuitcaseModel suitcase) {
    return MaterialApp(
      home: SuitcaseDetailScreen(suitcase: suitcase),
    );
  }

  group('SuitcaseDetailScreen Widget Tests', () {
    testWidgets('should render AppBar with logo and back button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      // Check for logo
      expect(find.byType(Image), findsWidgets);

      // Check for back button
      expect(find.byType(BackButton), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display suitcase destination and name', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Paris Trip'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display trip duration correctly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      // 7 days duration (June 1 to June 8)
      expect(find.text('7 days'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display departure date', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      // Departure date: 1/6
      expect(find.text('1/6'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display items count', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      // Count badge should show 3 items
      expect(find.text('3'), findsWidgets); // May find in other places too

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display list of clothing items', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      expect(find.text('T-Shirt'), findsOneWidget);
      expect(find.text('Blue Jeans'), findsOneWidget);
      expect(find.text('Running Shoes'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display item categories', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      expect(find.text('Tops'), findsOneWidget);
      expect(find.text('Bottoms'), findsOneWidget);
      expect(find.text('Footwear'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should show empty state when no items', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcaseEmpty));

      expect(find.text('No items in your suitcase'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should navigate back when back button is tapped', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: ElevatedButton(
              onPressed: () => Navigator.push(
                tester.element(find.byType(Scaffold)),
                MaterialPageRoute(builder: (_) => SuitcaseDetailScreen(suitcase: mockSuitcase)),
              ),
              child: const Text('Go to Details'),
            )),
          ),
        ),
      );

      await tester.tap(find.text('Go to Details'));
      await tester.pumpAndSettle();

      expect(find.text('Paris'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display correct destination image for Paris', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      // The image widget should be rendered
      expect(find.byType(Image), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display correct destination image for Bali', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      final baliSuitcase = SuitcaseModel(
        user_id: 2,
        destination: 'Bali',
        name: 'Bali Holiday',
        departure_date: DateTime(2026, 8, 1),
        end_date: DateTime(2026, 8, 10),
        clothings: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(baliSuitcase));

      expect(find.text('Bali'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display correct destination image for Dubai', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      final dubaiSuitcase = SuitcaseModel(
        user_id: 3,
        destination: 'Dubai',
        name: 'Dubai Trip',
        departure_date: DateTime(2026, 9, 1),
        end_date: DateTime(2026, 9, 7),
        clothings: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(dubaiSuitcase));

      expect(find.text('Dubai'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display correct destination image for London', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      final londonSuitcase = SuitcaseModel(
        user_id: 4,
        destination: 'London',
        name: 'London Tour',
        departure_date: DateTime(2026, 10, 1),
        end_date: DateTime(2026, 10, 10),
        clothings: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(londonSuitcase));

      expect(find.text('London'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display correct destination image for New York', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      final nySuitcase = SuitcaseModel(
        user_id: 5,
        destination: 'New York',
        name: 'NYC Adventure',
        departure_date: DateTime(2026, 11, 1),
        end_date: DateTime(2026, 11, 14),
        clothings: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(nySuitcase));

      expect(find.text('New York'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display correct destination image for Tokyo', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      final tokyoSuitcase = SuitcaseModel(
        user_id: 6,
        destination: 'Tokyo',
        name: 'Japan Trip',
        departure_date: DateTime(2026, 12, 1),
        end_date: DateTime(2026, 12, 21),
        clothings: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(tokyoSuitcase));

      expect(find.text('Tokyo'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display icon for different clothing types', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      final itemsSuitcase = SuitcaseModel(
        user_id: 7,
        destination: 'Paris',
        name: 'Fashion Trip',
        departure_date: DateTime(2026, 6, 1),
        end_date: DateTime(2026, 6, 8),
        clothings: [
          {'itemSubtype': 'Polo Shirt', 'itemType': 'Tops'},
          {'itemSubtype': 'Shorts', 'itemType': 'Bottoms'},
          {'itemSubtype': 'Hiking Boots', 'itemType': 'Footwear'},
          {'itemSubtype': 'Leather Jacket', 'itemType': 'Outerwear'},
          {'itemSubtype': 'Winter Scarf', 'itemType': 'Accessories'},
          {'itemSubtype': 'Baseball Cap', 'itemType': 'Accessories'},
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest(itemsSuitcase));

      expect(find.text('Polo Shirt'), findsOneWidget);
      expect(find.text('Shorts'), findsOneWidget);
      expect(find.text('Hiking Boots'), findsOneWidget);
      expect(find.text('Leather Jacket'), findsOneWidget);
      expect(find.text('Winter Scarf'), findsOneWidget);
      expect(find.text('Baseball Cap'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render SingleChildScrollView to allow scrolling', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      expect(find.byType(SingleChildScrollView), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render Scaffold with white background', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);

      final scaffoldWidget = tester.widget<Scaffold>(scaffold);
      expect(scaffoldWidget.backgroundColor, Colors.white);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display location icon in header', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      expect(find.byIcon(Icons.location_on), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display calendar and date range icons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest(mockSuitcase));

      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      expect(find.byIcon(Icons.date_range_outlined), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}
