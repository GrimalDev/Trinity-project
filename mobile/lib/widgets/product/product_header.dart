import 'package:flutter/material.dart';
import 'package:trinity/type/product.dart';

/// Displays the product name and image
class ProductHeader extends StatelessWidget {
  final Product product;

  const ProductHeader({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            product.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildProductImage(),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: product.imageUrl.isNotEmpty
            ? Image.network(
                product.imageUrl,
                fit: BoxFit.contain,
              )
            : const Icon(
                Icons.image_not_supported,
                size: 64,
                color: Colors.grey,
              ),
      ),
    );
  }
}
