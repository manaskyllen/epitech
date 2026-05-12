import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirstLaunchService {
  @visibleForTesting
  static FlutterSecureStorage storage = const FlutterSecureStorage();
  
  static const String _firstLaunchKey = 'is_first_launch';

  /// Check if it's the first launch of the app
  static Future<bool> isFirstLaunch() async {
    try {
      final String? value = await storage.read(key: _firstLaunchKey);
      return value == null; 
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirstLaunchService.isFirstLaunch error: $e');
      }
      return true;
    }
  }

  /// Mark that the app has already been launched
  static Future<void> setFirstLaunchCompleted() async {
    try {
      await storage.write(key: _firstLaunchKey, value: 'true');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirstLaunchService.setFirstLaunchCompleted error: $e');
      }
    }
  }

  static Future<void> resetFirstLaunch() async {
    try {
      await storage.delete(key: _firstLaunchKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FirstLaunchService.resetFirstLaunch error: $e');
      }
    }
  }
}