import 'package:dio/dio.dart';
import 'package:trinity/type/product.dart';
import 'package:trinity/type/promo.dart';
import 'package:trinity/utils/http.dart';

class ProductService {
  // Méthode pour récupérer un produit par code-barres
  Future<Product> getProductByBarcode(String barcode) async {
    try {
      // Faire la requête API
      final response = await ApiClient.public.get(
        '/product/barcode/$barcode',
      );

      if (response.statusCode == 200) {
        // print(response.data);
        return Product.fromJson(response.data);
      } else {
        throw Exception('Erreur lors de la récupération du produit');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ProductNotFoundException(
            'Nous ne possédons pas ce produit en stock');
      } else {
        throw Exception(
            'Une erreur est survenue lors de la recherche du produit');
      }
    }
  }

  static Future<List<Product>> getProductsBySearch(String productName) async {
    try {
      final response = await ApiClient.public.get('/product/search/$productName');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => Product.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw ProductNotFoundException("Aucun produit trouvé.");
      } else {
        throw Exception('Erreur lors de la récupération des produits');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ProductNotFoundException("Aucun produit trouvé.");
      }
      throw Exception('Erreur API : ${e.message}');
    }
  }

  static Future<List<Promo>> getUserRecommendedPromotions() async {
    try {
      final response = await ApiClient.auth.get('/product/promo/self');

      if (response.statusCode == 200) {
        if (response.data != null && response.data is List) {
          List<dynamic> data = response.data;
          return data.map((json) => Promo.fromJson(json)).toList();
        } else {
          throw Exception('Les données reçues ne sont pas une liste ou sont nulles');
        }
      } else {
        throw Exception('Erreur HTTP ${response.statusCode}');
      }
    } on Error catch (e) {
      throw Exception('Erreur API : ${e.toString()}');
    }
  }
}

// Custom exception for product not found
class ProductNotFoundException implements Exception {
  final String message;
  ProductNotFoundException(this.message);

  @override
  String toString() => message;
}
