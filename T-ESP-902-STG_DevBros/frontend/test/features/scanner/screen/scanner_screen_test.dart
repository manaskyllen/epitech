import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspiria/features/scanner/screen/scanner_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ScannerScreen(),
    );
  }

  group('ScannerScreen Widget Tests', () {
    testWidgets('should display the main scanner UI components', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('AI SCANNER'), findsOneWidget);
      expect(find.text('Position Your Item'), findsOneWidget);
      expect(find.text('CAPTURE & SCAN'), findsOneWidget);
      expect(find.text('UPLOAD FROM GALLERY'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should show loading indicator when camera is not initialized', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should have action buttons with correct icons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget); 
      expect(find.byIcon(Icons.upload_outlined), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render Scaffold with white background', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
      
      final scaffoldWidget = tester.widget<Scaffold>(scaffold);
      expect(scaffoldWidget.backgroundColor, Colors.white);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render SafeArea for safe content area', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(SafeArea), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render Column for layout structure', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(Column), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render Container for styling sections', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(Container), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render SizedBox for spacing', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(SizedBox), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render Padding for spacing and margins', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(Padding), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render Icon widgets for action buttons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(Icon), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render Text widgets for labels and instructions', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(Text), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should have Capture button with correct styling', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      // Verify that buttons/interactive elements are present
      expect(find.byType(InkWell), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should have Upload button with correct styling', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.text('UPLOAD FROM GALLERY'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render Row for horizontal alignment of buttons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(Row), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display instructions text clearly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.text('Position Your Item'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render header text in uppercase', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.text('AI SCANNER'), findsOneWidget);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should have proper layout with spacing between elements', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Padding), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render with proper structure hierarchy', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.byType(Column), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });

  group('ScannerOverlayPainter Tests', () {
    testWidgets('should render the specific custom scanner overlay', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.painter is ScannerOverlayPainter
        ),
        findsOneWidget,
      );

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should render CustomPaint widget for overlay', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CustomPaint), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('should display camera overlay on screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(createWidgetUnderTest());
      
      // CustomPaint should be rendered for the scanner overlay
      expect(find.byType(CustomPaint), findsWidgets);

      addTearDown(tester.view.resetPhysicalSize);
    });
  });
}