import 'package:dio/dio.dart';
import 'package:trinity/utils/http.dart';

class HistoryApi {
  Future<Response> getOrderHistory() async {
    try {
      final response = await ApiClient.auth.get(
        '/invoice/history/self',
      );
      return response;
    } on DioException catch (e) {
      throw Exception("Failed to load order history: ${e.response?.data}");
    }
  }
}
