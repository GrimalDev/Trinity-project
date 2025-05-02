import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:trinity/screens/product_page.dart';
import 'package:trinity/utils/api/product.dart';
import 'dart:ui';

class BarcodeScannerApp extends StatelessWidget {
  const BarcodeScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white,
          surface: Color(0xFF121212),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const BarcodeScannerScreen(),
    );
  }
}

// Scanner overlay with corner markers
class ScannerOverlay extends CustomPainter {
  final Color borderColor;
  final double cornerRadius;
  final double cornerWidth;

  ScannerOverlay({
    this.borderColor = const Color(0xFF6200EE),
    this.cornerRadius = 20,
    this.cornerWidth = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = borderColor
          ..strokeWidth = cornerWidth
          ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;
    final cornerSize = 30.0;

    // Draw top left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerSize)
        ..lineTo(0, 0)
        ..lineTo(cornerSize, 0),
      paint,
    );

    // Draw top right corner
    canvas.drawPath(
      Path()
        ..moveTo(width - cornerSize, 0)
        ..lineTo(width, 0)
        ..lineTo(width, cornerSize),
      paint,
    );

    // Draw bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, height - cornerSize)
        ..lineTo(0, height)
        ..lineTo(cornerSize, height),
      paint,
    );

    // Draw bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(width - cornerSize, height)
        ..lineTo(width, height)
        ..lineTo(width, height - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  final ProductService? productService;
  const BarcodeScannerScreen({super.key, this.productService});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String barcodeResult = "Pointez la camera vers un code-barre";
  bool _isLoading = false; // Indicateur de chargement
  String?
  _lastScannedBarcode; // Track the last scanned barcode to prevent duplicate navigations

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scanner de code-barre",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withAlpha(
                204,
              ), // equivalent to opacity 0.8 (0.8 * 255 = 204)
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      MobileScanner(
                        onDetect: (BarcodeCapture capture) {
                          final List<Barcode> barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty &&
                              barcodes.first.rawValue != null) {
                            final String scannedCode = barcodes.first.rawValue!;
                            // Only update and navigate if this is a new barcode
                            if (scannedCode != _lastScannedBarcode &&
                                !_isLoading) {
                              setState(() {
                                // barcodeResult = scannedCode;
                                _lastScannedBarcode = scannedCode;
                              });
                              // Automatically navigate to product page
                              _fetchProductAndNavigate(scannedCode);
                            }
                          }
                        },
                      ),
                      // Overlay with semitransparent dark background
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(
                            77,
                          ), // equivalent to opacity 0.3 (0.3 * 255 = 76.5, rounded to 77)
                        ),
                      ),
                      // Scanner area
                      Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: CustomPaint(
                            painter: ScannerOverlay(
                              borderColor:
                                  Theme.of(context).colorScheme.secondary,
                              cornerWidth: 5,
                            ),
                          ),
                        ),
                      ),
                      // Pulsating scan line animation
                      if (barcodeResult ==
                          "Pointez la camera vers un code-barre")
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Scannez un code-barre",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withAlpha(
                          204,
                        ), // equivalent to opacity 0.8 (0.8 * 255 = 204)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isLoading
                              ? Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(51),
                                ),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              )
                              : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surface.withAlpha(128),
                                ),
                                child: Text(
                                  barcodeResult,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour récupérer les données du produit et naviguer
  Future<void> _fetchProductAndNavigate(String barcode) async {
    final productService = widget.productService ?? ProductService();

    try {
      setState(() {
        _isLoading = true;
        barcodeResult = "Chargement du produit...";
      });

      // TODO: handle errors
      // Récupérer les données du produit depuis l'API
      final productData = await productService.getProductByBarcode(barcode);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Naviguer vers la page produit avec les données complètes
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductPage(product: productData),
        ),
      );

      // Reset the last scanned barcode when returning from product page
      // This allows the same barcode to be scanned again
      setState(() {
        _lastScannedBarcode = null;
        barcodeResult = "Pointez la camera vers un code-barre";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        barcodeResult = "Échec du scan. Réessayez dans un instant...";
      });

      // Determine the error message and color based on the exception type
      String errorMessage;
      Color backgroundColor;

      if (e is ProductNotFoundException) {
        errorMessage = e.toString();
        backgroundColor = Colors.orange; // Use orange for "not in stock" errors
      } else {
        errorMessage = 'Une erreur est survenue';
        backgroundColor = Colors.red; // Use red for other errors
      }

      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );

      // Add a delay before allowing another scan ONLY on failure
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      // Reset the last scanned barcode after the delay
      setState(() {
        _lastScannedBarcode = null; // Reset so user can try again
        barcodeResult = "Pointez la camera vers un code-barre";
      });
    }
  }
}
