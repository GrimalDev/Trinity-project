import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'interceptor.dart';

class ApiClient {
  // Authenticated client with auth interceptor
  static final Dio _authDio = Dio(
    BaseOptions(
      baseUrl: 'https://trinity.baptistegrimaldi.com/api',
      //baseUrl: "http://192.168.100.43:8080",
      // baseUrl: "http://192.168.1.76:8080",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  // Non-authenticated client without auth interceptor
  static final Dio _publicDio = Dio(
    BaseOptions(
      baseUrl: 'https://trinity.baptistegrimaldi.com/api',
      //baseUrl: "http://192.168.100.43:8080",
      // baseUrl: "http://192.168.1.76:8080",
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  static void initialize(BuildContext context) {
    // Setup authenticated client with auth interceptor
    _authDio.interceptors.addAll([
      AuthInterceptor(context: context),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);

    // Setup public client with only logging
    _publicDio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  // Get authenticated client instance
  static Dio get auth => _authDio;

  // Get public client instance (no auth)
  static Dio get public => _publicDio;

  // For backward compatibility
  static Dio get instance => _authDio;
}
