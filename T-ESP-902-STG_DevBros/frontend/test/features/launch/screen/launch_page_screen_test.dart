import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/launch/launch_page_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: LaunchPageScreen(),
    );
  }

  group('LaunchPageScreen Widget Tests', () {
    testWidgets('should update text when carousel page changes', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final carousel = find.byType(FlutterCarousel);
      await tester.drag(carousel, const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Scan your clothes \nand create your wardrobe'), findsOneWidget);
    });

    testWidgets('should show correct images in carousel', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Image && 
          widget.image is AssetImage && 
          (widget.image as AssetImage).assetName == 'assets/images/first_image_carousel.png'
        ),
        findsOneWidget,
      );
    });

    testWidgets('should trigger skip action on Skip text tap', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final skipButton = find.text('Skip');
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      expect(find.byType(LaunchPageScreen), findsOneWidget);
    });
  });
}