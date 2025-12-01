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
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
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

  void _onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/refresh-token')) {
      try {
        final newAcessToken = await _performRefreshToken();
        if (newAcessToken != null) {
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAcessToken';
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        }
      } catch (e) {
        return _tokenStorage.clearTokens();
      }
    }

    handler.next(err);
  }

  Future<String?> _performRefreshToken() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      //cria instancia nova pra nao entrar em loop
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
    } catch (_) {}
    return null;
  }
}
