import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/screens/order_product_card.dart';
import 'package:trinity/stores/cart_store.dart';
import 'package:trinity/stores/user_store.dart';
import 'package:trinity/theme/app_colors.dart';
import 'package:paypal_native_checkout/paypal_native_checkout.dart';
import 'package:paypal_native_checkout/models/custom/currency_code.dart';
import 'package:paypal_native_checkout/models/custom/environment.dart';
import 'package:paypal_native_checkout/models/custom/order_callback.dart';
import 'package:paypal_native_checkout/models/custom/purchase_unit.dart';
import 'package:paypal_native_checkout/models/custom/user_action.dart';
import 'package:trinity/utils/api/product.dart';
import 'package:trinity/utils/http.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final paypal = PaypalNativeCheckout.instance;
  List<String> logQueue = [];

  @override
  void initState() {
    super.initState();
    // Schedule for after the first frame to avoid build-time state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchPromotions();
      }
    });
  }

  Future<void> _fetchPromotions() async {
    if (!mounted) return;
    final cartStore = Provider.of<CartStore>(context, listen: false);

    try {
      cartStore.setLoadingPromotions(true);
      final promotions = await ProductService.getUserRecommendedPromotions();
      cartStore.setAvailablePromotions(promotions);
    } catch (e) {
      cartStore.setPromoError(e.toString());
    } finally {
      cartStore.setLoadingPromotions(false);
    }
  }

  Future<void> initPayPal() async {
    // Enable debug mode for logging
    PaypalNativeCheckout.isDebugMode = true;

    // Initialize PayPal plugin
    await paypal.init(
      returnUrl: "com.baptistegrimaldi.trinity://paypalpay",
      clientID:
          "Afvtfw8rthmRoRP_bTNBGBM3_T9eFxxaLVfJhe7akCDaRgHj1jnO0IwwrFjfL-V0ITrOqOyPFyuEea-2",
      payPalEnvironment: FPayPalEnvironment.sandbox,
      currencyCode: FPayPalCurrencyCode.eur,
      action: FPayPalUserAction.payNow,
    );
    // Set PayPal order callbacks
    paypal.setPayPalOrderCallback(
      callback: FPayPalOrderCallback(
        onSuccess: (data) async {
          final paypalOrderId = data.orderId ?? '';
          if (paypalOrderId.isEmpty) {
            _safeShowResult(
              'Error: No PayPal order ID returned',
              isError: true,
            );
          }

          // Update order status in backend database with PayPal orderId
          await updateOrderInBackend(paypalOrderId, 'paid');
          paypal.removeAllPurchaseItems(); // Clear PayPal cart

          if (!mounted) return;

          // Get a local reference to CartStore before checking mounted
          final localCartStore = Provider.of<CartStore>(context, listen: false);

          // Check mounted status after async operation before using context again
          if (!mounted) return;
          localCartStore.clearCart(); // Clear local cart
        },
        onError: (data) {
          paypal.removeAllPurchaseItems();
          if (data.reason.contains('invalid client_ID or redirect_uri')) {
            _safeShowResult(
              'PayPal error: Invalid client ID or redirect URI. Check configuration.',
              isError: true,
            );
            debugPrint('PayPal OAuth error: ${data.toString()}');
          } else {
            _safeShowResult('Payment error: ${data.reason}', isError: true);
            debugPrint('PayPal error details: ${data.toString()}');
          }
        },
        onCancel: () {
          _safeShowResult('Payment cancelled', isError: true);
        },
        onShippingChange: (data) {
          _safeShowResult(
            'Shipping changed: ${data.shippingChangeAddress?.adminArea1 ?? ""}',
          );
        },
      ),
    );
  }

  Future<String> createOrderInBackend(List<Map<String, dynamic>> cart) async {
    try {
      final response = await ApiClient.auth.post(
        '/payment/create',
        data: {
          "cart":
              cart
                  .map(
                    (item) => {
                      "productId": item["id"],
                      "quantity": item["quantity"],
                    },
                  )
                  .toList(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['invoiceId'] as String;
      } else {
        throw Exception('Failed to create order in database: ${response.data}');
      }
    } catch (e) {
      // Improved error handling without context dependency
      throw Exception('Order creation failed: $e');
    }
  }

  Future<void> updateOrderInBackend(String paypalOrderId, String status) async {
    final response = await ApiClient.auth.post(
      '/payment/capture',
      data: {'paypalOrderId': paypalOrderId},
      options: Options(receiveTimeout: const Duration(seconds: 10)),
    );

    if (response.statusCode == 200) {
      _safeShowResult('Order updated successfully: $status');
    } else {
      _safeShowResult(
        'Failed to update order: ${response.data}',
        isError: true,
      );
    }
  }

  void initiatePaypalCheckout(BuildContext context) async {
    // Store context values before async operations
    final cartStore = Provider.of<CartStore>(context, listen: false);
    final userStore = Provider.of<UserStore>(context, listen: false);

    // Check if user is authenticated
    if (!userStore.isAuthenticated) {
      _safeShowResult('Please login to continue', isError: true);
      AppRoutes.of(context).navigateTo(AppRoutes.login);
      return;
    }

    await initPayPal();

    try {
      if (cartStore.items.isEmpty) {
        _safeShowResult('Cart is empty', isError: true);
        return;
      }

      // Step 1: Create order in backend database (pending status)
      final cart =
          cartStore.items
              .map(
                (item) => {
                  "id": item.id,
                  "quantity": item.quantity,
                  "price": item.price,
                },
              )
              .toList();

      try {
        createOrderInBackend(cart);
      } catch (orderCreationError) {
        _safeShowResult('Order creation failed', isError: true);
        return;
      }

      _safeShowResult('Backend order created');

      // Step 2: Add purchase units from CartStore
      for (var item in cartStore.items) {
        debugPrint(item.toString());
        paypal.addPurchaseUnit(
          FPayPalPurchaseUnit(
            amount: cartStore.getProductDiscountedPrice(
              item.id,
              quantity: item.quantity,
            ),
            referenceId: item.id,
          ),
        );
      }

      // Step 3: Start PayPal checkout
      await paypal.makeOrder(action: FPayPalUserAction.payNow);
    } catch (e) {
      _safeShowResult('Unexpected error: $e', isError: true);
    }
  }

  void _safeShowResult(String text, {bool isError = false}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showResult(context, text, isError: isError);
    });
  }

  void showResult(BuildContext context, String text, {bool isError = false}) {
    logQueue.add(text);
    if (!mounted) return;

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartStore = Provider.of<CartStore>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panier',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                cartStore.items.isEmpty
                    ? _buildEmptyCart(context)
                    : _buildCartItemsList(context, cartStore),
          ),
          if (cartStore.items.isNotEmpty) _buildCartSummary(context, cartStore),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final navigator = Navigator.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.green.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            "Votre panier est vide",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Scanner un produit et ajoutez-les à votre panier",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              navigator.pushReplacementNamed(AppRoutes.scan);
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text("Scan un produit"),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.primary.withAlpha(40),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(BuildContext context, CartStore cartStore) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartStore.items.length,
      itemBuilder: (context, index) {
        final item = cartStore.items[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            elevation: 2,
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OrderProductCard(
                      product: {
                        'name': item.name,
                        'description': '',
                        'image': item.imageUrl,
                        'price': item.price,
                        'quantity': item.quantity,
                        'total': cartStore.getProductDiscountedPrice(
                          item.id,
                          quantity: item.quantity,
                        ),
                      },
                    ),
                    if (cartStore.hasPromotion(item.id))
                      _buildPromotionBadges(cartStore, item.id),
                  ],
                ),
                _buildQuantitySelector(context, cartStore, item),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantitySelector(
    BuildContext context,
    CartStore cartStore,
    dynamic item,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Quantité:",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(158, 158, 158, 0.20),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onPressed: () => cartStore.decrementQuantity(item.id),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    item.quantity.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add,
                  onPressed: () => cartStore.incrementQuantity(item.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionBadges(CartStore cartStore, String productId) {
    final promos = cartStore.getProductPromotions(productId);

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: Wrap(
        spacing: 8.0,
        children:
            promos.map((promo) {
              String promoText = '';
              IconData promoIcon;
              Color promoColor;

              switch (promo.discountType) {
                case 'percentage':
                  promoText = '- ${promo.discountValue.toStringAsFixed(0)}%';
                  promoIcon = Icons.percent;
                  promoColor = Colors.orange;
                  break;
                case 'fixed':
                  promoText = '- ${promo.discountValue.toStringAsFixed(2)}€';
                  promoIcon = Icons.euro;
                  promoColor = Colors.blue;
                  break;
                case 'bogo':
                  promoText = 'Buy One Get One';
                  promoIcon = Icons.shopping_bag;
                  promoColor = Colors.purple;
                  break;
                default:
                  promoText = 'Promo';
                  promoIcon = Icons.discount;
                  promoColor = Colors.green;
              }

              return Chip(
                backgroundColor: promoColor.withAlpha(80),
                side: BorderSide(color: promoColor),
                avatar: Icon(promoIcon, color: promoColor, size: 16),
                label: Text(
                  promoText,
                  style: TextStyle(
                    color: promoColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartStore cartStore) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(bottom: 1, left: 6, right: 6),
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            offset: Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résumé de votre commande',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          // const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nombre d\'articles:', style: TextStyle(fontSize: 16)),
              Text(
                '${cartStore.items.fold(0, (sum, item) => sum + item.quantity)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (cartStore.discountAmount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sous-total:', style: TextStyle(fontSize: 16)),
                Text(
                  '${cartStore.subtotalPrice.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          if (cartStore.discountAmount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Réductions:',
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                Text(
                  '-${cartStore.discountAmount.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '${cartStore.totalPrice.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ShadButton.outline(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  onPressed:
                      cartStore.items.isNotEmpty
                          ? () {
                            cartStore.clearCart();
                          }
                          : null,
                  leading: const Icon(Icons.delete_outline),
                  backgroundColor: Colors.red,
                  child: const Text(
                    'Vider le panier',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ShadButton.outline(
                  onPressed: () => initiatePaypalCheckout(context),
                  leading: const Icon(Icons.check_circle_outline),
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  backgroundColor: Colors.green,
                  child: const Text(
                    'Valider',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
