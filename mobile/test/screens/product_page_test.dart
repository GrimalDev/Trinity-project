import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/screens/cart_page.dart';
import 'package:trinity/screens/product_page.dart';
import 'package:trinity/stores/cart_store.dart';
import 'package:trinity/type/product.dart';

void main() {
  final mockProduct = Product(
    id: '1',
    name: 'Test Product',
    price: 10.0,
    imageUrl: '',
    reference: '123456789',
    brand: 'Test Brand',
    category: 'Test Category',
    nutritionalInformation: 'Test Nutritional Info',
  );

  Widget createProductPage({
    CartStore? cartStore,
  }) {
    return MultiProvider(
      providers: [
        cartStore != null
            ? ChangeNotifierProvider.value(value: cartStore)
            : ChangeNotifierProvider(create: (context) => CartStore())
      ],
      child: ShadTheme(
        data: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme: const ShadZincColorScheme.dark(),
        ),
        child: MaterialApp(
          home: ProductPage(
            product: mockProduct,
          ),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }

  group('ProductPage', () {
    testWidgets('Initial state of product', (WidgetTester tester) async {
      await tester.pumpWidget(createProductPage());
      await tester.pumpAndSettle();

      // Check initial text
      expect(find.text('Produit'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Prix'), findsOneWidget);
      expect(find.text('10.00 €'), findsOneWidget);
      expect(find.text('Description du Produit'), findsOneWidget);
      expect(find.text('Test Category'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Ajouter'), findsOneWidget);

      // Check for MobileScanner widget
      expect(find.byType(ProductPage), findsOneWidget);
    });

    testWidgets('details state of product', (WidgetTester tester) async {
      await tester.pumpWidget(createProductPage());
      await tester.pumpAndSettle();

      expect(find.text('Details'), findsOneWidget);
      await tester.tap(find.text('Details'));

      await tester.pumpAndSettle(Duration(seconds: 2));

      expect(find.text('Détails du Produit'), findsOneWidget);
      expect(find.text('Référence'), findsOneWidget);
      expect(find.text('Marque'), findsOneWidget);
      expect(find.text('Catégorie'), findsOneWidget);
      expect(find.text('Informations Nutritionnelles :'), findsOneWidget);

      // Check for MobileScanner widget
      expect(find.byType(ProductPage), findsOneWidget);
    });

    testWidgets('cancel state of product', (WidgetTester tester) async {
      await tester.pumpWidget(createProductPage());
      await tester.pumpAndSettle();

      expect(find.text('Annuler'), findsOneWidget);
      await tester.tap(find.text('Annuler'));

      await tester.pumpAndSettle(Duration(seconds: 2));

      // Check for MobileScanner widget
      expect(find.byType(ProductPage), findsNothing);
    });

    testWidgets('add product to cart', (WidgetTester tester) async {
      await tester.pumpWidget(createProductPage());
      await tester.pumpAndSettle();

      expect(find.text('Ajouter'), findsOneWidget);
      await tester.tap(find.text('Ajouter'));

      await tester.pump();

      expect(find.text('Ajouté au panier'), findsOneWidget);

      await tester.pumpAndSettle(Duration(seconds: 2));

      expect(find.byType(CartPage), findsOneWidget);

      // Specific text checks for CartPage
      expect(find.text('Panier'), findsOneWidget);
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Nombre d\'articles:'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
      expect(find.text('Total:'), findsOneWidget);
      expect(find.text('10.00 €'), findsWidgets);
      expect(find.text('Valider'), findsOneWidget);
      expect(find.text('Vider le panier'), findsOneWidget);
    });
  });
}

// Mock Canvas for testing CustomPainter
class MockCanvas implements Canvas {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
