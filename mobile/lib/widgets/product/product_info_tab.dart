import 'package:flutter/material.dart';
import 'package:trinity/type/product.dart';
import 'package:trinity/widgets/common/info_container.dart';

/// Displays the product information tab content
class ProductInfoTab extends StatelessWidget {
  final Product product;

  const ProductInfoTab({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        if (product.price > 0) ...[
          _buildPriceSection(),
          const SizedBox(height: 20),
        ],
        _buildDescriptionSection(),
      ],
    );
  }

  Widget _buildPriceSection() {
    return InfoContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      hasBorder: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Prix',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${product.price.toStringAsFixed(2)} €',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return InfoContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description du Produit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 12),
          Text(
            product.category,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
