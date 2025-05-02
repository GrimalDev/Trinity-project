import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/screens/cart_page.dart';
import 'package:trinity/screens/scan_page.dart';
import 'package:trinity/stores/cart_store.dart';
import 'package:trinity/type/cart_item.dart';
import 'package:trinity/type/product.dart';

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

void main() {
  Widget createCartPage({
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
          home: CartPage(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }

  group('ProductPage', () {
    testWidgets('Initial state of empty cart', (WidgetTester tester) async {
      await tester.pumpWidget(createCartPage());
      await tester.pumpAndSettle();

      // Check initial text
      expect(find.text('Panier'), findsOneWidget);
      expect(find.text('Votre panier est vide'), findsOneWidget);
      expect(find.text('Scanner un produit et ajoutez-les à votre panier'),
          findsOneWidget);
      expect(find.bySubtype<ElevatedButton>(), findsOneWidget);
      expect(find.text('Scan un produit'), findsOneWidget);

      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('Initial state of empty cart', (WidgetTester tester) async {
      await tester.pumpWidget(createCartPage());
      await tester.pumpAndSettle();

      // Check initial text
      expect(find.text('Panier'), findsOneWidget);
      expect(find.text('Votre panier est vide'), findsOneWidget);
      expect(find.text('Scan un produit'), findsOneWidget);

      await tester.tap(find.text('Scan un produit'));
      await tester.pumpAndSettle();

      expect(find.byType(BarcodeScannerApp), findsOneWidget);
    });

    testWidgets('Initial state of cart with item', (WidgetTester tester) async {
      final cartStore = CartStore();

      final item = CartItem(
        id: mockProduct.id,
        name: mockProduct.name,
        price: mockProduct.price,
        imageUrl: mockProduct.imageUrl,
      );

      cartStore.addItem(item);

      await tester.pumpWidget(createCartPage(cartStore: cartStore));
      await tester.pumpAndSettle();

      // Check initial text
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('10.00 × 1'), findsOneWidget);

      // Find the white '10.00 €' text
      final whiteTextFinder = find.byWidgetPredicate((Widget widget) =>
          widget is Text &&
          widget.data == '10.00 €' &&
          widget.style?.color == Colors.white);

      // Verify the white text exists and has correct value
      expect(whiteTextFinder, findsOneWidget);
      final whiteTextWidget = tester.widget<Text>(whiteTextFinder);
      expect(whiteTextWidget.data, '10.00 €');

      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('add or remove', (WidgetTester tester) async {
      final cartStore = CartStore();

      final item = CartItem(
        id: mockProduct.id,
        name: mockProduct.name,
        price: mockProduct.price,
        imageUrl: mockProduct.imageUrl,
      );

      cartStore.addItem(item);

      await tester.pumpWidget(createCartPage(cartStore: cartStore));
      await tester.pumpAndSettle();

      // Find and tap the add icon button
      final addIconFinder = find.byIcon(Icons.add);
      expect(addIconFinder, findsOneWidget);
      await tester.tap(addIconFinder);
      await tester.pump();

      // Check initial text
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('10.00 × 2'), findsOneWidget);

      // Find the white '10.00 €' text
      final whiteTextFinder = find.byWidgetPredicate((Widget widget) =>
          widget is Text &&
          widget.data == '20.00 €' &&
          widget.style?.color == Colors.white);

      // Verify the white text exists and has correct value
      expect(whiteTextFinder, findsOneWidget);
      final whiteTextWidget = tester.widget<Text>(whiteTextFinder);
      expect(whiteTextWidget.data, '20.00 €');
      expect(find.text('2'), findsAtLeast(2));

      final removeIconFinder = find.byIcon(Icons.remove);
      expect(removeIconFinder, findsOneWidget);
      await tester.tap(removeIconFinder);
      await tester.pump();

      expect(find.text('10.00 × 1'), findsOneWidget);

      // Find the white '10.00 €' text
      final whiteTextFinder2 = find.byWidgetPredicate((Widget widget) =>
          widget is Text &&
          widget.data == '10.00 €' &&
          widget.style?.color == Colors.white);

      // Verify the white text exists and has correct value
      expect(whiteTextFinder2, findsOneWidget);
      final whiteTextWidget2 = tester.widget<Text>(whiteTextFinder2);
      expect(whiteTextWidget2.data, '10.00 €');
      expect(find.text('1'), findsAtLeast(2));

      await tester.tap(removeIconFinder);
      await tester.pump();

      expect(find.text('Test Product'), findsNothing);
      expect(find.text('20.00 €'), findsNothing);

      expect(find.byType(CartPage), findsOneWidget);
    });

    testWidgets('clear cart', (WidgetTester tester) async {
      final cartStore = CartStore();

      final item = CartItem(
        id: mockProduct.id,
        name: mockProduct.name,
        price: mockProduct.price,
        imageUrl: mockProduct.imageUrl,
      );

      cartStore.addItem(item);

      await tester.pumpWidget(createCartPage(cartStore: cartStore));
      await tester.pumpAndSettle();

      // Check initial text
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('10.00 × 1'), findsOneWidget);

      // Find the white '10.00 €' text

      await tester.tap(find.text("Vider le panier"));
      await tester.pump();

      expect(find.text('Test Product'), findsNothing);
      expect(find.text('10.00 × 1'), findsNothing);

      expect(find.byType(CartPage), findsOneWidget);
    });
  });
}

// Mock Canvas for testing CustomPainter
class MockCanvas implements Canvas {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
