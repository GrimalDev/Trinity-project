import 'package:flutter/material.dart';
import 'package:trinity/screens/order_product_card.dart';
import 'package:trinity/utils/api/detalscommand.dart';
import 'package:trinity/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart' as lucide;

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({required this.orderId, super.key});

  @override
  OrderDetailsPageState createState() => OrderDetailsPageState();
}

class OrderDetailsPageState extends State<OrderDetailsPage> {
  late Map<String, dynamic> orderDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final orderDetailsApi = OrderDetailsApi();
      final response = await orderDetailsApi.getOrderDetails(widget.orderId);

      debugPrint("Réponse de l'API : $response");

      if (response.containsKey('products') && response['products'] != null) {
        setState(() {
          orderDetails = response;
        });
      } else {
        debugPrint("Aucune clé 'products' dans la réponse");
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des détails de la commande: $e");
      setState(() {
        orderDetails = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orderDetails.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Détails de la commande')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    var products = [];
    debugPrint("test $orderDetails");
    double subtotalAmount = orderDetails['subtotal'].toDouble();
    double totaltest = 0.0;
    double totalAmount = orderDetails['totalPrice'].toDouble();
    double discountAmount = orderDetails['discountAmount'].toDouble();

    if (orderDetails.containsKey('products') &&
        orderDetails['products'] != null) {
      debugPrint(totaltest.toString());
      products = orderDetails['products'].map((productData) {
        return {
          'name': productData['name'],
          'description': productData['description'],
          'image': productData['image'],
          'price': productData['price'],
          'quantity': productData['quantity'],
          'total': productData['total'],
        };
      }).toList();
    } else {
      debugPrint("Aucun produit trouvé dans la réponse");
    }

    if (products.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Détails de la commande')),
        body: Center(
          child: Text(
            'Il n\'y a actuellement aucun produit dans cette commande.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la commande'),
        backgroundColor: AppColors.cardBackground,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return OrderProductCard(product: products[index]);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                )
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (discountAmount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sous-total',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        Text(
                          '${subtotalAmount.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (discountAmount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              lucide.LucideIcons.tag,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Réduction',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '-${discountAmount.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                Divider(color: Colors.grey.shade700),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${totalAmount.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
