import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_api/core/network/dio_client.dart';
import 'package:mobile_api/core/storage/token_storage.dart';

import 'package:mobile_api/features/auth/login_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QA: Fluxo de login e recuperacao de token expirado', (
    WidgetTester tester,
  ) async {
    Stripe.publishableKey =
        "pk_test_51SYCGcE8BL6ngJFa07aT2e0A7zdHerzicfBM5lCLsoBRZTzeALcXQ0ILnjJQRvOvKvneyxoVBUfY6271OxAPnTv300VFq7DsN6";
    await Stripe.instance.applySettings();

    await tester.pumpWidget(
      MaterialApp(
        title: 'App de Teste QA',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    print('--- ETAPA 1: REALIZANDO LOGIN ---');

    final textFields = find.byType(TextField);
    final btnEntrar = find.widgetWithText(ElevatedButton, 'ENTRAR');

    if (find.text('Produtos').evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.exit_to_app));
      await tester.pumpAndSettle();
    }

    await tester.enterText(textFields.at(0), 'teste@email.com');
    await tester.enterText(textFields.at(1), '123');
    await tester.tap(btnEntrar);

    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Produtos'), findsOneWidget);
    print(' Login realizado com sucesso.');

    print('--- ETAPA 2: SABOTANDO O TOKEN ---');

    final storage = TokenStorage();

    final refreshToken = await storage.getRefreshToken();

    await storage.saveTokens('TOKEN_ESTRAGADO_12345', refreshToken!);

    print('💀 Token de acesso corrompido manualmente.');

    print('--- ETAPA 3: TESTANDO RECUPERAÇÃO AUTOMÁTICA ---');

    bool recuperou = false;
    try {
      final response = await DioClient().dio.post(
        '/graphql',
        data: {"query": " { products { name } }"},
      );

      print('Status recebido: ${response.statusCode}');
      print('Dados recebidos: ${response.data}');

      if (response.statusCode == 200 && response.data['data'] != null) {
        recuperou = true;
      }
    } catch (e) {
      print('Falhou: $e');
    }

    await Future.delayed(const Duration(seconds: 2));

    expect(
      recuperou,
      isTrue,
      reason:
          'O app deveria ter renovado o token e completado a requisicao, mas falhou',
    );

    final newToken = await storage.getAccessToken();
    print('Token no final do teste: $newToken');
    expect(newToken, isNot('TOKEN_ESTRAGADO_12345'));

    print(
      ' SUCESSO: O App detectou o erro 401, renovou o token e buscou os dados!',
    );
  });
}
