import 'package:flutter/material.dart';

class OrderProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const OrderProductCard({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String name = product['name'] ?? 'Nom du produit non disponible';

    String image = product['image'] ?? '';
    double price = product['price']?.toDouble() ?? 0.0;
    int quantity = product['quantity'] ?? 0;
    double total = (product['total'] ?? (price * quantity)).toDouble();
    String description = product['description'] ?? '';

    // Colors optimized for dark theme
    final cardColor = isDark ? Color(0xFF2A2A2A) : Colors.white;
    final descriptionColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final accentColor = isDark ? Colors.green : theme.primaryColor;
    final imageBackgroundColor = isDark ? Color(0xFF1A1A1A) : Color(0xFFF0F0F0);
    final totalBgColor = isDark
        ? accentColor.withAlpha(38) // 0.15 opacity = ~38 alpha
        : theme.primaryColor.withAlpha(30);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(76) // 0.3 opacity = ~76 alpha
                  : Colors.black.withAlpha(25), // 0.1 opacity = ~25 alpha
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: imageBackgroundColor,
                ),
                child: image.isNotEmpty
                    ? Image.network(
                        image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'lib/images/defaut.jpg',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'lib/images/defaut.jpg',
                        fit: BoxFit.cover,
                      ),
              ),
            ),

            SizedBox(width: 16),

            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (description.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: descriptionColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  SizedBox(height: 8),

                  // Price per unit with quantity
                  Row(
                    children: [
                      Icon(
                        Icons.euro,
                        size: 16,
                        color: accentColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "${price.toStringAsFixed(2)} × $quantity",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Total price
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: totalBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: accentColor
                            .withAlpha(76), // 0.3 opacity = ~76 alpha
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Total: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          "${total.toStringAsFixed(2)} €",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
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
      ),
    );
  }
}
