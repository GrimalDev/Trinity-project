class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String reference;
  final String brand;
  final String category;
  final String nutritionalInformation;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.reference,
    required this.brand,
    required this.category,
    required this.nutritionalInformation,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: (json['name'] != null && json['name'] != '')
          ? json['name']
          : (json['brand'] ?? ''),
      price: (json['price_vat'] ?? 0).toDouble(),
      imageUrl: (json['images'] != null && json['images']['XL'] != null)
          ? json['images']['XL']
          : '',
      reference: json['reference'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      nutritionalInformation: json['nutritional_information'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, brand: $brand, category: $category)';
  }
}