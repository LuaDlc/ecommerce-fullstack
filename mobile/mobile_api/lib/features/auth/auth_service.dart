import 'package:mobile_api/core/network/dio_client.dart';
import 'package:mobile_api/core/storage/token_storage.dart';

class AuthService {
  final DioClient _dioClient = DioClient();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<bool> login(String email, String password) async {
    print('--- TENTANDO LOGIN: INICIANDO ---');
    try {
      final response = await _dioClient.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      print('--- RESPOSTA RECEBIDA: ${response.statusCode} ---');

      if (response.statusCode == 200) {
        print('DADOS BRUTOS: ${response.data}');
        print('TIPO DOS DADOS: ${response.data.runtimeType}');
        final accessToken = response.data['accessToken'];
        final refreshToken = response.data['refreshToken'];
        print('TOKEN LIDO: $accessToken');

        print('TENTANDO SALVAR...');
        await _tokenStorage.saveTokens(accessToken, refreshToken);
        print('SALVO COM SUCESSO!');
      }
      return false;
    } catch (e) {
      //tratar outros erros 401 500 sem internet
      print('🔥🔥🔥 ERRO CRÍTICO ENCONTRADO: $e 🔥🔥🔥');
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
    //limpa o armazenamento local e o token
    await _tokenStorage.clearTokens();
  }
}
