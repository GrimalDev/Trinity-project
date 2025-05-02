import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/screens/cart_page.dart';
import 'package:trinity/stores/cart_store.dart';
import 'package:trinity/type/cart_item.dart';
import 'package:trinity/type/product.dart' show Product;
import 'package:trinity/widgets/product/product_detail_tab.dart';
import 'package:trinity/widgets/product/product_info_tab.dart';
import 'package:trinity/widgets/product/product_header.dart';
import 'package:trinity/widgets/product/tab_selector.dart';
import 'package:trinity/theme/app_colors.dart';

/// A page that displays detailed information about a product
class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String selectedTab = 'produit'; // Default to 'produit'
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _getInitialTabIndex());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _getInitialTabIndex() => selectedTab == 'produit' ? 0 : 1;

  void _handleTabChange(int index) {
    setState(() {
      selectedTab = index == 0 ? 'produit' : 'details';
    });
  }

  void _navigateToTab(int tabIndex) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        tabIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleCancelPressed() {
    Navigator.pop(context);
  }

  _handleAddPressed(cartStore) {
    // Add product to cart
    final item = CartItem(
      id: widget.product.id,
      name: widget.product.name,
      price: widget.product.price,
      imageUrl: widget.product.imageUrl,
    );

    cartStore.addItem(item);

    // Show a visually appealing success alert
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              'Ajouté au panier',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.product.name} a été ajouté à votre panier',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );

    // Dismiss the dialog after a short delay and navigate back
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.of(context).pop(); // Close the dialog

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            try {
              AppRoutes.of(context).navigateTo(AppRoutes.cart);
            } catch (e) {
              // During tests, AppRoutes provider might not be available
              debugPrint('Navigation skipped (likely in test environment): $e');
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => CartPage()));
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartStore = Provider.of<CartStore>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.background,
        title: const Text(
          'Page produit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab selector
          TabSelector(
            selectedTab: selectedTab,
            onProduitTabPressed: () => _navigateToTab(0),
            onDetailTabPressed: () => _navigateToTab(1),
          ),

          // Tab content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Product header with image (now scrolls with content)
                  ProductHeader(product: widget.product),

                  // Tab content with fixed height for PageView
                  SizedBox(
                    height: 450, // Adjust this height as needed
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _handleTabChange,
                      children: [
                        // "Produit" page
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ProductInfoTab(product: widget.product),
                        ),
                        // "Detail" page
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ProductDetailTab(product: widget.product),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action buttons
          _buildActionButtons(cartStore),
        ],
      ),
    );
  }

  Widget _buildActionButtons(cartStore) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ShadButton(
              onPressed: _handleCancelPressed,
              backgroundColor: Colors.red,
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ShadButton(
              onPressed: () => _handleAddPressed(cartStore),
              child: const Text(
                'Ajouter',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
