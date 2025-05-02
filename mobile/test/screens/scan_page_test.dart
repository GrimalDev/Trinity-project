import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/screens/scan_page.dart';
import 'package:trinity/screens/product_page.dart';
import 'package:trinity/stores/cart_store.dart';
import 'package:trinity/type/product.dart';
import 'package:trinity/utils/api/product.dart';

@GenerateMocks([ProductService])
import 'scan_page_test.mocks.dart';

void main() {
  late MockProductService mockProductService;
  late CartStore cartStore;

  setUp(() {
    mockProductService = MockProductService();
    cartStore = CartStore();
  });

  Widget createScanPage() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartStore>.value(value: cartStore),
        Provider<ProductService>.value(value: mockProductService),
      ],
      child: ShadTheme(
        data: ShadThemeData(
          brightness: Brightness.dark,
          colorScheme: const ShadZincColorScheme.dark(),
        ),
        child: MaterialApp(
          home: BarcodeScannerScreen(
            productService: mockProductService,
          ),
        ),
      ),
    );
  }

  group('BarcodeScannerScreen', () {
    testWidgets('Initial state of BarcodeScannerScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createScanPage());

      // Check initial text
      expect(find.text('Scanner de code-barre'), findsOneWidget);
      expect(find.text('Pointez la camera vers un code-barre'), findsOneWidget);

      // Check for MobileScanner widget
      expect(find.byType(MobileScanner), findsOneWidget);
    });

    testWidgets('Successful product fetch and navigation',
        (WidgetTester tester) async {
      // Mock product data
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
      when(mockProductService.getProductByBarcode('123456789'))
          .thenAnswer((_) async => mockProduct);

      await tester.pumpWidget(createScanPage());

      // Simulate barcode detection
      // First, find the MobileScanner widget
      final mobileScannerFinder = find.byType(MobileScanner);
      expect(mobileScannerFinder, findsOneWidget);

      // Get the MobileScanner widget
      final MobileScanner scanner = tester.widget(mobileScannerFinder);

      // Simulate a barcode detection
      final barcodeCapture = BarcodeCapture(
        barcodes: [
          Barcode(
            rawValue: '123456789',
            displayValue: '123456789',
            format: BarcodeFormat.ean13,
            type: BarcodeType.product,
            corners: [],
          ),
        ],
        image: null,
      );

      // Call the onDetect callback directly
      scanner.onDetect!(barcodeCapture);

      // Allow the UI to update
      await tester.pumpAndSettle();

      // Verify product service was called
      verify(mockProductService.getProductByBarcode('123456789')).called(1);

      expect(find.byType(ProductPage), findsOneWidget);
    });

    testWidgets('Product not found error handling',
        (WidgetTester tester) async {
      // Setup mock service to throw ProductNotFoundException
      when(mockProductService.getProductByBarcode(any)).thenThrow(
          ProductNotFoundException(
              'Nous ne possédons pas ce produit en stock'));

      await tester.pumpWidget(createScanPage());

      // Simulate barcode detection
      // First, find the MobileScanner widget
      final mobileScannerFinder = find.byType(MobileScanner);
      expect(mobileScannerFinder, findsOneWidget);

      // Get the MobileScanner widget
      final MobileScanner scanner = tester.widget(mobileScannerFinder);
      // Simulate a barcode detection
      final barcodeCapture = BarcodeCapture(
        barcodes: [
          Barcode(
            rawValue: '123456789',
            displayValue: '123456789',
            format: BarcodeFormat.ean13,
            type: BarcodeType.product,
            corners: [],
          ),
        ],
        image: null,
      );

      // Call the onDetect callback directly
      scanner.onDetect!(barcodeCapture);

      await tester.pumpAndSettle();

      // Check for error message
      expect(find.text('Échec du scan. Réessayez dans un instant...'),
          findsOneWidget);
      expect(find.text('Nous ne possédons pas ce produit en stock'),
          findsOneWidget);

      //wait for the error message to disappear
      await tester.pumpAndSettle(Duration(seconds: 4));
    });

    testWidgets('Api error error handling', (WidgetTester tester) async {
      // Setup mock service to throw ProductNotFoundException
      when(mockProductService.getProductByBarcode(any)).thenThrow(
          Exception('Une erreur est survenue lors de la recherche du produit'));

      await tester.pumpWidget(createScanPage());

      // Simulate barcode detection
      // First, find the MobileScanner widget
      final mobileScannerFinder = find.byType(MobileScanner);
      expect(mobileScannerFinder, findsOneWidget);

      // Get the MobileScanner widget
      final MobileScanner scanner = tester.widget(mobileScannerFinder);
      // Simulate a barcode detection
      final barcodeCapture = BarcodeCapture(
        barcodes: [
          Barcode(
            rawValue: '123456789',
            displayValue: '123456789',
            format: BarcodeFormat.ean13,
            type: BarcodeType.product,
            corners: [],
          ),
        ],
        image: null,
      );

      // Call the onDetect callback directly
      scanner.onDetect!(barcodeCapture);

      await tester.pumpAndSettle();

      // Check for error message
      expect(find.text('Échec du scan. Réessayez dans un instant...'),
          findsOneWidget);
      expect(find.text('Une erreur est survenue'), findsOneWidget);

      //wait for the error message to disappear
      await tester.pumpAndSettle(Duration(seconds: 4));
    });
  });
}

// Mock Canvas for testing CustomPainter
class MockCanvas implements Canvas {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
