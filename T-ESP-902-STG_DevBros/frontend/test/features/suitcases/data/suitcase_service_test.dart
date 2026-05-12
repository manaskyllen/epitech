import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inspiria/features/suitcase/data/suitcase_service.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClient mockClient;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockClient = MockClient();
    SuitcaseService.client = mockClient;
    SuitcaseService.mockToken = 'fake_token_123';
    SuitcaseService.mockBaseUrl = 'https://api.test.com';
  });

  group('SuitcaseService - Tests avec Injection', () {
    test('Should return SuitcaseResponces with list on 200', () async {
      final mockJson = {
        'suitcases': [
          {
            'id': 1,
            'name': 'Test',
            'departure_date': '2026-03-20T15:00:00Z',
            'end_date': '2026-03-27T15:00:00Z',
            'destination': 'Paris',
            'user_id': 1
          }
        ]
      };

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(json.encode(mockJson), 200));

      final result = await SuitcaseService.getAllSuitcaseByUserId('123');

      expect(result?.statusCode, 200);
    });

    test('Should return true on 204 delete', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('', 204));

      final result = await SuitcaseService.deleteSuitcase('1');

      expect(result, isTrue);
    });
  });
}