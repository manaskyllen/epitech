import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/routes/router_enum.dart';

void main() {
  group('SCREEN Enum Extension Tests', () {
    
    test('Should return the correct path for each SCREEN', () {
      expect(SCREEN.LAUNCHPAGE.path, '/');
      expect(SCREEN.PRELOGIN.path, '/prelogin');
      expect(SCREEN.LOGIN.path, '/login');
      expect(SCREEN.HOMEPAGE.path, '/homepage');
      
      expect(SCREEN.PARAMETRE.path, '/products/:id');
      
      expect(SCREEN.REGISTER.path, '/register');
      expect(SCREEN.VALIDATEEMAIL.path, '/validateemail');
      expect(SCREEN.SCANNER.path, '/scanner');
    });

    test('Each SCREEN should have a unique path', () {
      final paths = SCREEN.values.map((screen) => screen.path).toList();
      final uniquePaths = paths.toSet();

      expect(
        paths.length, 
        uniquePaths.length, 
        reason: 'Multiple screens are sharing the same URL path, which will cause navigation conflicts.'
      );
    });

    test('All paths must start with a forward slash', () {
      for (final screen in SCREEN.values) {
        expect(
          screen.path.startsWith('/'), 
          isTrue, 
          reason: "The path for ${screen.name} ('${screen.path}') must start with '/' to be valid in GoRouter."
        );
      }
    });

    test('All screens must be defined in the path switch', () {
      for (final screen in SCREEN.values) {
        try {
          final path = screen.path;
          expect(path, isA<String>());
        } catch (e) {
          fail('Path not defined for SCREEN.${screen.name}');
        }
      }
    });
  });
}