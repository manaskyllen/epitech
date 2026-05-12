import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/core/model/user_model.dart';
import 'package:inspiria/features/profil/profil_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ProfileScreen(),
    );
  }

  group('ProfileScreen Widget Tests', () {
    testWidgets('should render AppBar with logo and settings icon', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(BackButton), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Image && 
          widget.image is AssetImage && 
          (widget.image as AssetImage).assetName == 'assets/images/InspiriaLogoV2.png'
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should verify layout structure of FutureBuilder', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(FutureBuilder<UserModel?>), findsOneWidget);
    });
  });
}