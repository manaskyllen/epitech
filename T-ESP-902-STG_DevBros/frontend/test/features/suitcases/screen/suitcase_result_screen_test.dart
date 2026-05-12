import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/suitcase/screen/suitcase_result_screen.dart'; 

void main() {
  final mockResultData = {
    'suitcase': {
      'destination': 'Paris',
      'departure_date': '2026-03-10',
      'end_date': '2026-03-15',
      'clothings': [
        {
          'itemType': 't-shirt',
          'itemSubtype': 'T-shirt blanc',
          'fabric': 'Coton',
          'color': 'Blanc',
          'quantity': 2,
        },
      ],
    },
    'weather': {
      'temp_min': 12,
      'temp_max': 18,
      'condition': 'Ensoleillé',
    },
    'warnings': {
      'chaussettes': 5,
    },
  };

  Widget createWidgetUnderTest(Map<String, dynamic> data) {
    return MaterialApp(
      home: SuitcaseResultScreen(resultData: data),
    );
  }

  group('SuitcaseResultScreen Tests', () {
    testWidgets('should display destination and correct duration', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockResultData));

      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('5 days'), findsOneWidget);
    });

    testWidgets('should display weather information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockResultData));

      expect(find.text('12-18°C'), findsOneWidget);
      expect(find.text('Ensoleillé'), findsOneWidget);
    });

    testWidgets('should categorize clothing items correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockResultData));

      expect(find.text('TOPS'), findsOneWidget);
      expect(find.text('T-shirt blanc'), findsOneWidget);
      expect(find.text('2'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display empty message if no data is provided', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest({
        'suitcase': {
          'destination': '',
          'departure_date': null,
          'end_date': null,
          'clothings': []
        },
        'weather': null,
        'warnings': null
      }));

      await tester.pump();

      expect(find.text('Your suitcase is empty for the moment.'), findsOneWidget);
    });

    testWidgets('should open warning popup if warnings are present', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockResultData));
      await tester.pumpAndSettle();

      expect(find.text('Missing Items'), findsOneWidget);
      expect(find.text('Suggested 5'), findsOneWidget);
    });

    testWidgets('should close warning popup when close button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(mockResultData));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Missing Items'), findsNothing);
    });
  });
}