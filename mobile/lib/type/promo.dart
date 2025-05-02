import 'package:trinity/type/product.dart';

class Promo {
  final String id;
  final String name;
  final String description;
  final String discountType;
  final double discountValue;
  final String code;
  final String startDate;
  final String endDate;
  final List<Product> products;
  final double minPurchase;

  Promo({
    required this.id,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.code,
    required this.startDate,
    required this.endDate,
    required this.products,
    required this.minPurchase,
  });

  factory Promo.fromJson(Map<String, dynamic> json) {
    return Promo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discount_type'] ?? '',
      discountValue: (json['discount_value'] ?? 0).toDouble(),
      code: json['code'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      products: (json['products'] as List<dynamic>?)
          ?.map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      minPurchase: (json['min_purchase'] ?? 0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Promo(id: $id, name: $name, description: $description, discountType: $discountType, discountValue: $discountValue, code: $code, startDate: $startDate, endDate: $endDate, minPurchase: $minPurchase, products: $products)';
  }
}