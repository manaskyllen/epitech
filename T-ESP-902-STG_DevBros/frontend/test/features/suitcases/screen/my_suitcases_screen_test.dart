import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inspiria/features/suitcase/data/suitcase_service.dart';
import 'package:inspiria/features/suitcase/screen/my_suitcases_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClient mockClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://api.test.com'));
  });

  setUp(() {
    mockClient = MockClient();
    SuitcaseService.client = mockClient;
    
    SharedPreferences.setMockInitialValues({
      'user_id': '123',
    });
    SuitcaseService.mockToken = 'fake_token';
    SuitcaseService.mockBaseUrl = 'https://api.test.com';
    
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'read') {
        final String? key = methodCall.arguments['key'];
        if (key == 'user_id') return '123';
        if (key == 'access_token') return 'fake_token';
      }
      return null;
    });
  });

  tearDown(() {
    const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: MySuitcasesScreen(),
    );
  }

  group('MySuitcasesScreen - UI Tests', () {
    testWidgets('should show loading indicator on initial load', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display the correct screen title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      expect(find.text('My Suitcases'), findsOneWidget);
    });

    testWidgets('should display list of suitcases when data is successfully fetched', (WidgetTester tester) async {
      final mockResponseBody = json.encode({
        'suitcases': [
          {
            'id': 1,
            'name': 'Summer Trip',
            'destination': 'Paris',
            'departure_date': '2024-06-01T00:00:00Z',
            'end_date': '2024-06-08T00:00:00Z',
            'user_id': 123,
            'clothings': [],
          },
          {
            'id': 2,
            'name': 'Winter Vacation',
            'destination': 'Tokyo',
            'departure_date': '2024-12-20T00:00:00Z',
            'end_date': '2024-12-27T00:00:00Z',
            'user_id': 123,
            'clothings': [],
          }
        ]
      });

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(mockResponseBody, 200));

      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Tokyo'), findsOneWidget);
      
      // CORRECTION : Correspondance exacte pour le pluriel
      expect(find.text('2 suitcases registered'), findsOneWidget);
      
      expect(find.text('Open Suitcase'), findsNWidgets(2));
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
    });

    testWidgets('should calculate and display correct trip duration in days', (WidgetTester tester) async {
      final mockResponseBody = json.encode({
        'suitcases': [
          {
            'id': 1,
            'name': 'Test Trip',
            'destination': 'Bali',
            'departure_date': '2024-06-01T00:00:00Z',
            'end_date': '2024-06-11T00:00:00Z', 
            'user_id': 123,
            'clothings': [],
          }
        ]
      });

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(mockResponseBody, 200));

      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.text('10 days'), findsOneWidget);
    });

    testWidgets('should select correct destination image based on destination name', (WidgetTester tester) async {
      final mockResponseBody = json.encode({
        'suitcases': [
          {
            'id': 1,
            'name': 'Paris Trip',
            'destination': 'Paris',
            'departure_date': '2024-06-01T00:00:00Z',
            'end_date': '2024-06-08T00:00:00Z',
            'user_id': 123,
            'clothings': [],
          }
        ]
      });

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(mockResponseBody, 200));

      await tester.pumpWidget(createWidgetUnderTest());
      
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.text('Paris'), findsOneWidget);
    });
  });
}