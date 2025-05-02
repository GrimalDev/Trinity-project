import 'package:dio/dio.dart';
import 'package:trinity/utils/http.dart';

class OrderDetailsApi {
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await ApiClient.auth.get(
        '/invoice/self/$orderId',
      );

      var orderDetails = response.data;

      var products = orderDetails['order'] != null &&
              orderDetails['order']['products'] != null
          ? orderDetails['order']['products'].map((productData) {
              return {
                'name': productData['product']['name'],
                'description': productData['product']['description'],
                'image': productData['product']['images']['S'],
                'price': productData['price'],
                'quantity': productData['quantity'],
                'total': productData['price'] * productData['quantity'],
              };
            }).toList()
          : [];

      var orderData = {
        'id': orderDetails['id'],
        'date': orderDetails['date'],
        'totalPrice': orderDetails['totalPrice'],
        'subtotal': orderDetails['subtotal'],
        'discountAmount': orderDetails['discountAmount'],
        'products': products,
      };

      return orderData;
    } on DioException catch (e) {
      throw Exception("Failed to load order details: ${e.response?.data}");
    }
  }
}
