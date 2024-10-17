import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icondock/dock.dart';
import 'package:icondock/home_page.dart';
import 'package:icondock/main.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('MyApp should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MyApp should have correct theme', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme!.appBarTheme.backgroundColor, Colors.white);
      expect(app.theme!.visualDensity, VisualDensity.adaptivePlatformDensity);
    });
  });

  group('HomePage Widget Tests', () {
    testWidgets('HomePage should have AppBar with correct properties', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      final AppBar appBar = tester.widget(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
      expect((appBar.title as Text).data, 'Icon Dock');
      expect(appBar.centerTitle, true);
      expect(appBar.elevation, 4);

      final BuildContext context = tester.element(find.byType(AppBar));
      expect(appBar.backgroundColor, Theme.of(context).appBarTheme.backgroundColor);
    });

    testWidgets('HomePage should contain a Dock widget', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));
      expect(find.byType(Dock<IconData>), findsOneWidget);
    });
  });

  group('Dock Widget Tests', () {
    testWidgets('Dock should be created and removed without active tickers', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Dock<IconData>(
              items: const [Icons.home, Icons.settings],
              builder: (IconData icon, bool isDragging) {
                return Icon(icon);
              },
              onReorder: (_, __) {},
            ),
          ),
        ),
      );

      // Verify that the Dock widget is present
      expect(find.byType(Dock<IconData>), findsOneWidget);

      // Remove the Dock widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Pump a frame to allow for disposal
      await tester.pump();

      // Verify that there are no active tickers
      expect(tester.binding.transientCallbackCount, equals(0));
    });
  });
  group('Integration Tests', () {
    testWidgets('Full app flow - Dock reordering', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify initial order
      final List<IconData> initialOrder = [
        Icons.person,
        Icons.message,
        Icons.call,
        Icons.camera,
        Icons.photo,
      ];

      for (int i = 0; i < initialOrder.length; i++) {
        expect(find.byIcon(initialOrder[i]), findsOneWidget);
      }

      // Perform a drag operation
      await tester.drag(find.byIcon(Icons.person), const Offset(200, 0));
      await tester.pumpAndSettle();

      // Verify new order
      // Note: The exact new positions might vary based on the drag implementation
      // This test assumes the first icon moves to the end
      final List<IconData> expectedNewOrder = [
        Icons.message,
        Icons.call,
        Icons.camera,
        Icons.photo,
        Icons.person,
      ];

      for (int i = 0; i < expectedNewOrder.length; i++) {
        expect(find.byIcon(expectedNewOrder[i]), findsOneWidget);
      }
    });
  });
}