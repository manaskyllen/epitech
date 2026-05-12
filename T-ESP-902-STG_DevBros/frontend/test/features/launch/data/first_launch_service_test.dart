import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/launch/data/first_launch_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockSecureStorage();
    FirstLaunchService.storage = mockStorage;
  });

  group('FirstLaunchService - Tests', () {
    
    test('isFirstLaunch returns true when storage is empty (null)', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final result = await FirstLaunchService.isFirstLaunch();

      expect(result, isTrue);
      verify(() => mockStorage.read(key: 'is_first_launch')).called(1);
    });

    test('isFirstLaunch returns false when app was already launched', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'true');

      final result = await FirstLaunchService.isFirstLaunch();

      expect(result, isFalse);
    });

    test('isFirstLaunch returns true (fallback) when storage throws error', () async {
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenThrow(Exception('Storage error'));

      final result = await FirstLaunchService.isFirstLaunch();

      expect(result, isTrue);
    });

    test('setFirstLaunchCompleted writes "true" to storage', () async {
      when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async => {});

      await FirstLaunchService.setFirstLaunchCompleted();

      verify(() => mockStorage.write(key: 'is_first_launch', value: 'true')).called(1);
    });

    test('resetFirstLaunch deletes the key from storage', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async => {});

      await FirstLaunchService.resetFirstLaunch();

      verify(() => mockStorage.delete(key: 'is_first_launch')).called(1);
    });
  });
}