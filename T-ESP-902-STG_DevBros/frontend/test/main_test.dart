import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(fileInput: 'BASE_URL=https://api.test.com');
  });

  group('MyApp Tests', () {
    testWidgets('MyApp should build without exploding', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MyApp should have the correct title and font theme', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final MaterialApp app = tester.widget(find.byType(MaterialApp));

      expect(app.title, 'Inspiria');

      expect(app.theme?.textTheme.bodyLarge?.fontFamily, 'Poppins');
      expect(app.theme?.useMaterial3, isTrue);
    });
  });
}