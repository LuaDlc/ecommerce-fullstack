import 'package:mobile_api/core/network/dio_client.dart';
import 'package:mobile_api/core/storage/token_storage.dart';

class AuthService {
  final DioClient _dioClient = DioClient();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        final refreshToken = response.data['refreshToken'];

        await _tokenStorage.saveTokens(accessToken, refreshToken);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      await _dioClient.dio.post(
        '/logout',
        data: {'refreshToken': refreshToken},
      );
    } catch (_) {}
    await _tokenStorage.clearTokens();
  }
}
