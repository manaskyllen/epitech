import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/scanner/screen/scanner_successfull.dart';



void main() {
  final mockData = {
    'imageFile': File('dummy_path.png'), 
    'aiData': {
      'message': 'Success',
      'data': {
        'ItemType': 'top',
        'ItemSubtype': 'Sweatshirt',
        'Color': ['Blue'], 
        'Season': 'Winter',
        'Size': 'L',
        'Gender': 'unisex',
        'style': 'streetwear',
        'texture': 'cotton',
        'clothingModel_id': 10,
      }
    }
  };

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ScannerSuccessfull(
        data: mockData, 
      ),
    );
  }

  group('ScannerSuccessfull Widget Tests', () {
    
    testWidgets('should display attributes with correct case', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('top'), findsOneWidget);
      
      expect(find.text('Blue'), findsOneWidget);
    });

    testWidgets('should show dynamic AI style suggestion', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('AI STYLE SUGGESTION'), findsOneWidget);
      
      expect(find.text('Streetwear'), findsOneWidget);
    });

    testWidgets('should show save button with correct text', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('CONFIRM & SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });
  });
}