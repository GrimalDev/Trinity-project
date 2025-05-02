import 'package:dio/dio.dart';
import 'package:trinity/type/user.dart';
import 'package:trinity/utils/http.dart';

class UserApi {
  Future<User> getUser() async {
    try {
      final response = await ApiClient.auth.get('/user/self');

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception("User information retrival failed: ${e.response?.data}");
    }
  }

  Future<User> getUserDetails() async {
    try {
      final response = await ApiClient.auth.get('/user/details/self');

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception("User information retrival failed: ${e.response?.data}");
    }
  }
}
