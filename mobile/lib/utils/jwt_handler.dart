import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles JSON Web Token (JWT) storage and management using secure storage
///
/// This class provides methods to securely store, retrieve, and remove authentication tokens
/// using Flutter's secure storage mechanism.
class JwtHandler {
  /// Secure storage instance for storing sensitive data
  final _storage = const FlutterSecureStorage();

  /// Stores a JWT token in secure storage
  ///
  /// [jwt] The JSON Web Token to be stored
  ///
  /// Example:
  /// ```dart
  /// jwtHandler.setToken('your.jwt.token');
  /// ```
  Future<void> setToken(String jwt) async {
    await _storage.write(key: 'token', value: jwt);
  }

  /// Retrieves the stored JWT token from secure storage
  ///
  /// Returns a [Future] that completes with the stored token or null if no token exists
  ///
  /// Example:
  /// ```dart
  /// final token = await jwtHandler.getToken();
  /// if (token != null) {
  ///   // Use the token
  /// }
  /// ```
  Future<String?> getToken() async {
    final jwt = await _storage.read(key: 'token');
    return jwt;
  }

  /// Removes the stored JWT token from secure storage
  ///
  /// Example:
  /// ```dart
  /// jwtHandler.removeToken();
  /// ```
  void removeToken() {
    _storage.delete(key: 'token');
  }
}
