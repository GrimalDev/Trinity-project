import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/screens/deals_page.dart';
import 'package:trinity/screens/home_page.dart';
import 'package:trinity/screens/login_page.dart';
import 'package:trinity/screens/promotions_page.dart';
import 'package:trinity/screens/recipe_page.dart';
import 'package:trinity/screens/search_product_page.dart';
import 'package:trinity/screens/shopping_lists_page.dart';
import 'package:trinity/stores/user_store.dart';
import 'package:trinity/type/user.dart';

void main() {
  Widget createHomePage([UserStore? userStore]) {
    return MultiProvider(
      providers: [
        userStore != null
            ? ChangeNotifierProvider.value(value: userStore)
            : ChangeNotifierProvider(create: (context) => UserStore())
      ],
      child: ShadTheme(
        data: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme: const ShadZincColorScheme.dark(),
        ),
        child: MaterialApp(
          home: HomePage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }

  group('HomePage', () {
    testWidgets('Initial state of HomePage', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());
      await tester.pumpAndSettle();

      // expect(find.byType(Text), findsOneWidget);

      // Check initial text
      expect(find.text('Promotions'), findsOneWidget);
      expect(find.text('Bons plans'), findsOneWidget);
      expect(find.text('Ma liste'), findsOneWidget);
      expect(find.text('Recettes'), findsOneWidget);
      expect(find.text('Rechercher un produit'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);

      // Check for MobileScanner widget
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('state when logged in', (WidgetTester tester) async {
      // Create a mock UserStore with a logged-in state
      final userStore = UserStore();

      final testUser = User(
          id: "1234",
          lastName: 'Test User',
          firstName: 'Test',
          archived: false,
          email: "test@test.com",
          roles: []);

      userStore.setUser(testUser);

      // Create a widget with the mocked UserStore
      await tester.pumpWidget(createHomePage(userStore));

      // Trigger a rebuild
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Check logged-in state elements
      expect(find.text('Rechercher un produit'), findsOneWidget);
      expect(find.text('Se connecter'), findsNothing);
      expect(find.text('Bienvenue Test !'), findsOneWidget);

      // Check for specific logged-in page elements (adjust based on your actual implementation)
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('product search', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Check initial text
      expect(find.text('Rechercher un produit'), findsOneWidget);
      await tester.tap(find.text('Rechercher un produit'));

      await tester.pumpAndSettle();

      // Check for MobileScanner widget
      expect(find.byType(ProductSearchPage), findsOneWidget);

      expect(find.text('Découvrez nos produits'), findsOneWidget);
    });

    testWidgets('go to promo not loged in', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Check initial text
      expect(find.text('Promotions'), findsOneWidget);
      await tester.tap(find.text('Promotions'));

      await tester.pumpAndSettle();

      // Check for MobileScanner widget
      expect(find.byType(PromotionsPage), findsOneWidget);

      await tester.pumpAndSettle(Duration(seconds: 5));

      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('go to promo loged in', (WidgetTester tester) async {
      final userStore = UserStore();

      final testUser = User(
          id: "1234",
          lastName: 'Test User',
          firstName: 'Test',
          archived: false,
          email: "test@test.com",
          roles: []);

      userStore.setUser(testUser);

      // Create a widget with the mocked UserStore
      await tester.pumpWidget(createHomePage(userStore));

      // Check initial text
      expect(find.text('Promotions'), findsOneWidget);
      await tester.tap(find.text('Promotions'));

      await tester.pumpAndSettle();

      // Check for MobileScanner widget
      expect(find.byType(PromotionsPage), findsOneWidget);

      await tester.pumpAndSettle(Duration(seconds: 5));

      expect(find.byType(PromotionsPage), findsOneWidget);
    });

    testWidgets('go to recipe', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      await tester.pumpAndSettle(Duration(seconds: 5));

      // Check initial text
      expect(find.text('Recettes'), findsOneWidget);
      await tester.tap(find.text('Recettes'));

      await tester.pumpAndSettle();

      // Check for MobileScanner widget
      expect(find.byType(RecipesPage), findsOneWidget);
    });

    testWidgets('go to deals', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Check initial text
      expect(find.text('Bons plans'), findsOneWidget);
      await tester.tap(find.text('Bons plans'));

      await tester.pumpAndSettle();

      // Check for MobileScanner widget
      expect(find.byType(DealsPage), findsOneWidget);
    });

    testWidgets('go to my list', (WidgetTester tester) async {
      await tester.pumpWidget(createHomePage());

      // Check initial text
      expect(find.text('Ma liste'), findsOneWidget);
      await tester.tap(find.text('Ma liste'));

      await tester.pumpAndSettle();

      // Check for MobileScanner widget
      expect(find.byType(ShoppingListsPage), findsOneWidget);
    });
  });
}

// Mock Canvas for testing CustomPainter
class MockCanvas implements Canvas {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
