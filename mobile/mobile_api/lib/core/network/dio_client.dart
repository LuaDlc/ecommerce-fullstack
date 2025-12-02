import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mobile_api/core/storage/token_storage.dart';

class DioClient {
  ///TODO: QUANDO USAR
  ///Quando usar: Quando a lógica do interceptador é gigantesca ou quando você quer reutilizar esse mesmo interceptador em vários clientes Dio diferentes.
  ///class AuthInterceptor extends Interceptor {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio _dio;
  final TokenStorage _tokenStorage = TokenStorage();
  //IP (iOS: localhost | Android: 10.0.2.2)
  final String _baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:5000'
      : 'http://localhost:5000';

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        headers: {'Content-type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      ///TODO: InterceptorsWrapper => Ele permite injetar as funções (onRequest, onError) diretamente, sem precisar criar uma classe e um arquivo extra só para isso
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }
  Dio get dio => _dio;

  void _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Verifica se é uma resposta GraphQL com erro de Auth
    if (response.data != null && response.data['errors'] != null) {
      final errors = response.data['errors'] as List;
      final hasAuthError = errors.any(
        (e) =>
            e['message'].toString().contains('Nao autorizado') ||
            e['message'].toString().contains('Unauthorized'),
      );

      if (hasAuthError) {
        print('--- GRAPHQL AUTH ERROR DETECTADO (NO 200 OK) ---');

        // Tenta fazer o refresh manualmente aqui
        final newAccessToken = await _performRefreshToken();

        if (newAccessToken != null) {
          print('--- REFRESH SUCESSO (VIA onResponse) - RETENTANDO ---');

          // Atualiza o token na requisição original
          final options = response.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccessToken';

          try {
            // Retenta a requisição
            final retryResponse = await _dio.fetch(options);
            return handler.next(
              retryResponse,
            ); // Retorna a nova resposta de sucesso
          } catch (e) {
            // Se falhar de novo, deixa passar
          }
        }
      }
    }
    // Se não for erro de auth, segue a vida normal
    handler.next(response);
  }

  void _onError(DioException error, ErrorInterceptorHandler handler) async {
    print('--- DIO ERROR: ${error.response?.statusCode} ---');

    if (error.response?.statusCode == 401 &&
        !error.requestOptions.path.contains('/refresh-token')) {
      print('--- 401 DETECTADO - TENTANDO REFRESH ---');
      final newAccessToken = await _performRefreshToken();

      if (newAccessToken != null) {
        final options = error.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } catch (_) {}
      }
    }
    handler.next(error);
  }

  Future<String?> _performRefreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return null;

      // Cria instância nova para evitar loop
      final tempDio = Dio(BaseOptions(baseUrl: _baseUrl));
      final response = await tempDio.post(
        '/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        await _tokenStorage.saveTokens(newAccessToken, refreshToken);
        return newAccessToken;
      }
    } catch (e) {
      print('Erro no refresh: $e');
      await _tokenStorage.clearTokens();
    }
    return null;
  }
}
