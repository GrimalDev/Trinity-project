import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trinity/screens/product_page.dart';
import 'package:trinity/stores/user_store.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/theme/app_colors.dart';
import 'package:trinity/utils/api/product.dart';
import '../type/promo.dart';

class PromotionsPage extends StatefulWidget {
  const PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  List<Promo> _promotions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    final userStore = Provider.of<UserStore>(context, listen: false);

    if (!userStore.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navigator = Navigator.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vous devez être connecté pour voir les promotions."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            navigator.pushReplacementNamed(AppRoutes.login);
          }
        });
      });
    } else {
      _fetchPromotions();
    }
  }

  Future<void> _fetchPromotions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      List<Promo> promotions =
          await ProductService.getUserRecommendedPromotions();

      setState(() {
        _promotions = promotions.cast<Promo>();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes promotions')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage.isNotEmpty)
              Center(
                  child:
                      Text(_errorMessage, style: TextStyle(color: Colors.red)))
            else if (_promotions.isEmpty)
              Center(child: Text("Aucune promotion disponible."))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _promotions.length,
                  itemBuilder: (context, index) {
                    final promo = _promotions[index];
                    return Card(
                      color: AppColors.cardBackground,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 3,
                      child: ListTile(
                        leading: Image.network(
                          promo.products[0].imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image_not_supported, size: 50);
                          },
                        ),
                        title: Text(promo.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Description: ${promo.description}"),
                            Text("Réduction: ${promo.discountValue}€"),
                            Text("Code Promo: ${promo.code}"),
                            Text(
                                "Valable du: ${promo.startDate} au ${promo.endDate}"),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          if (promo.products.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductPage(product: promo.products[0]),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
