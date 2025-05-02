import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trinity/utils/http.dart';

class PaymentService {
  /// Creates a payment order in the backend
  ///
  /// Returns the payment information with PayPal links for the order
  Future<Map<String, dynamic>> createPayment(String orderId) async {
    try {
      final response = await ApiClient.auth.post(
        '/payment/create',
        data: {'orderId': orderId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment: ${response.data}');
      }

      return json.decode(response.data);
    } catch (e) {
      debugPrint('Error creating payment: $e');
      rethrow;
    }
  }

  /// Captures a payment after user approval in PayPal UI
  Future<Map<String, dynamic>> capturePayment({
    required String orderId,
    required String paypalOrderId,
    required String invoiceId,
  }) async {
    try {
      final response = await ApiClient.auth.post(
        '/payment/capture',
        data: {
          'orderId': orderId,
          'paypalOrderId': paypalOrderId,
          'invoiceId': invoiceId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to capture payment: ${response.data}');
      }

      return json.decode(response.data);
    } catch (e) {
      debugPrint('Error capturing payment: $e');
      rethrow;
    }
  }
}
