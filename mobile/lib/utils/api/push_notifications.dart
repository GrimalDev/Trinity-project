import 'package:trinity/utils/http.dart';

Future<void> sendTokenToBackend(String token) async {
  await ApiClient.auth.post(
    '/push-notification/register-token',
    data: {'token': token},
  );
}
