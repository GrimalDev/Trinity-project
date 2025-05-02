import 'package:dio/dio.dart';
import 'package:trinity/utils/http.dart';
import 'package:trinity/utils/jwt_handler.dart';

class AuthService {
  final _jwtHandler = JwtHandler();

  ///example of a login method
  ///```dart
  ///try {
  ///  final response = await _authService.login("username", "password");
  ///  // Update the UI with a success message.
  ///  setState(() {
  ///     _responseMessage = "Login Successful: ${response.data}";
  ///  });
  ///} catch (e) {
  ///  // Handle errors by updating the UI or showing a message.
  ///  setState(() {
  ///    _responseMessage = "Login failed: $e";
  ///  });
  ///}
  ///```
  Future<Response> login(String username, String password) async {
    // Prepare your request data. Adjust keys as required by your API.
    final data = {"email": username, "password": password};

    // Hardcoded data for testing purposes.
    // final data = {
    //   "email": "john.doe@mail.com",
    //   "password":
    //       "b2867617492e26c338ab49f72afabc984d798b59755a27e312b953716ae964d7",
    // };

    try {
      // Make a POST request to the login endpoint.
      final response = await ApiClient.public.post('/user/login', data: data);
      // Handle response data, e.g., saving token or navigating based on response.

      final jwtToken = response.data['token'];

      // Securely store the JWT token
      await _jwtHandler.setToken(jwtToken);

      return response;
    } on DioException catch (e) {
      // Handle errors appropriately.
      // You might want to parse the error response or show a message to the user.
      throw Exception("Login failed: ${e.response?.data}");
    }
  }

  //register methode
  Future<Response> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final data = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
    };

    try {
      final response = await ApiClient.public.post('/user', data: data);
      return response;
    } on DioException catch (e) {
      throw Exception("Sing up failed: ${e.response?.data}");
    }
  }
}
