import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:trinity/config/routes.dart';
import 'package:trinity/stores/user_store.dart';
import 'package:trinity/utils/jwt_handler.dart';

class AuthInterceptor extends Interceptor {
  final _storage = FlutterSecureStorage();
  final _jwtHandler = JwtHandler();
  final BuildContext? context;

  AuthInterceptor({this.context});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _jwtHandler.getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle token-related errors
    if (err.response != null) {
      final data = err.response!.data;

      if (data is Map) {
        final message = data['message']?.toString().toLowerCase() ?? '';
        final error = data['error']?.toString().toLowerCase() ?? '';

        if (message.contains('user') ||
            message.contains('token') ||
            message.contains('jwt') ||
            error.contains('user') ||
            error.contains('token') ||
            error.contains('jwt')) {
          _handleAuthError();
        }
      }
    }

    return handler.next(err);
  }

  Future<void> _handleAuthError() async {
    AppRoutes.navigateToLogin();
    await _storage.delete(key: 'token');
    if (context != null) {
      Provider.of<UserStore>(context!, listen: false).resetUser();
    }
  }

  //@override
  //Future<void> onResponse(
  //  Response response,
  //  ResponseInterceptorHandler handler,
  //) async {
  //  debugPrint('Response: ${response.data}');
  //  // Check for non-200 status codes and potential user/token related errors
  //  if (response.statusCode != 200) {
  //    final data = response.data;
  //
  //    if (data is Map) {
  //      final message = data['message']?.toString().toLowerCase() ?? '';
  //      final error = data['error']?.toString().toLowerCase() ?? '';
  //
  //      debugPrint('Response error: $error');
  //      debugPrint('Response message: $message');
  //
  //      if (message.contains('user') ||
  //          message.contains('token') ||
  //          error.contains('user') ||
  //          error.contains('token')) {
  //        await _storage.delete(key: 'token');
  //        Provider.of<UserStore>(context!, listen: false).resetUser();
  //        AppRoutes.of(context!).navigateTo(AppRoutes.login);
  //      }
  //    }
  //  }
  //
  //  return handler.next(response);
  //}
}
