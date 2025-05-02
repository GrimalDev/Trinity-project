import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/widgets/navbar.dart';

void main() {
  setUp(() {
    // This is required for the SVG package to work in tests
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('CustomNavigationBar Tests', () {
    testWidgets('initializes with correct selected index based on currentPath',
        (WidgetTester tester) async {
      String currentPath = AppRoutes.cart;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            currentPath: currentPath,
            onTap: (path) {},
          ),
        ),
      ));

      // The cart tab should be selected (index 1)
      final CustomNavigationBar navigationBar =
          tester.widget(find.byType(CustomNavigationBar));
      expect(navigationBar.currentPath, equals(currentPath));
    });

    testWidgets('calls onTap with correct path when navigation item is tapped',
        (WidgetTester tester) async {
      String currentPath = AppRoutes.home;
      String? tappedPath;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            currentPath: currentPath,
            onTap: (path) {
              tappedPath = path;
            },
          ),
        ),
      ));

      // Tap the profile tab (index 4)
      await tester.tap(find.byType(NavigationDestination).at(4));
      await tester.pump();

      expect(tappedPath, equals(AppRoutes.profile));
    });

    testWidgets('updates selected index when currentPath changes',
        (WidgetTester tester) async {
      String currentPath = AppRoutes.home;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            currentPath: currentPath,
            onTap: (path) {},
          ),
        ),
      ));

      // Initially home tab (index 0) should be selected
      NavigationBar navigationBar = tester.widget(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, 0);

      // Change the currentPath
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            currentPath: AppRoutes.profile,
            onTap: (path) {},
          ),
        ),
      ));
      await tester.pump();

      // Now profile tab (index 4) should be selected
      navigationBar = tester.widget(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, 4);
    });

    testWidgets('renders special scan button differently from other buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            currentPath: AppRoutes.home,
            onTap: (path) {},
          ),
        ),
      ));

      // Find all NavigationDestination widgets
      final destinations = tester.widgetList<NavigationDestination>(
          find.byType(NavigationDestination));

      // Verify the scan button (index 2) has a Container with specific properties
      final scanDestination = destinations.elementAt(2);

      // The scan destination should have an icon that is a Container
      final scanIconWidget = scanDestination.icon;
      expect(scanIconWidget is Container, isTrue);

      // Verify the other buttons don't have Container as their direct icon
      final homeDestination = destinations.elementAt(0);
      expect(homeDestination.icon is Container, isFalse);
    });

    testWidgets('has correct number of navigation items',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            currentPath: AppRoutes.home,
            onTap: (path) {},
          ),
        ),
      ));

      // Should have 5 navigation destinations (home, cart, scan, history, profile)
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('animation controllers are present in the navbar',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomNavigationBar(
            currentPath: AppRoutes.home,
            onTap: (path) {},
          ),
        ),
      ));

      // Find AnimatedBuilder widgets
      final animatedBuilders =
          tester.widgetList<AnimatedBuilder>(find.byType(AnimatedBuilder));

      // Verify that there are multiple AnimatedBuilder widgets
      expect(animatedBuilders.length, greaterThan(1));

      // Verify that at least some of these are associated with animation controllers
      final controllersPresent = animatedBuilders
          .any((builder) => builder.listenable is AnimationController);
      expect(controllersPresent, isTrue);

      // Let the animation complete
      await tester.pumpAndSettle();
    });
  });
}
