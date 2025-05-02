import 'package:flutter/material.dart';
import 'package:trinity/type/product.dart';
import 'package:trinity/widgets/common/info_container.dart';
import 'package:trinity/widgets/common/detail_row.dart';

/// Displays the product details tab content
class ProductDetailTab extends StatelessWidget {
  final Product product;

  const ProductDetailTab({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Détails du Produit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildProductInfoSection(),
        const SizedBox(height: 20),
        _buildNutritionalInfoSection(),
      ],
    );
  }

  Widget _buildProductInfoSection() {
    return InfoContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(label: 'Référence', value: product.reference),
          const Divider(color: Colors.grey, height: 24),
          DetailRow(label: 'Marque', value: product.brand),
          const Divider(color: Colors.grey, height: 24),
          DetailRow(label: 'Catégorie', value: product.category),
        ],
      ),
    );
  }

  Widget _buildNutritionalInfoSection() {
    return InfoContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations Nutritionnelles :',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.nutritionalInformation,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
