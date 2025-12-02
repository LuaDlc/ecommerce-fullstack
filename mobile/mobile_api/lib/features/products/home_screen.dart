import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_api/core/network/dio_client.dart';
import 'package:mobile_api/core/network/graphql_config.dart';
import 'package:mobile_api/features/auth/auth_service.dart';
import 'package:mobile_api/features/auth/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final String backendUrl = "http://localhost:5000";

  final String readProducts = """
query {
products {
id
name
price
image
}}
""";

  Future<void> _createPaymentIntent(BuildContext context) async {
    try {
      final response = await DioClient().dio.post('/create-payment-intent');
      final clientSecret = response.data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Lojinha flutter',
          // style: ThemeMode.dark,
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pagamento realizado com sucesso')),
      );

      // if (kDebugMode) {
      //   print("Failed to create payment intent: ${response}");
      // }
      // return null;
    } on StripeException catch (e) {
      if (kDebugMode) {
        print("Pagemento cancelado ou falhou ${e.error.localizedMessage}");
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pagamento Cancelado')));
    } catch (e) {
      print('Erro Geral: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao processar pagamento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: GraphQLConfig.client,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _createPaymentIntent(context),
          label: const Text('finalizar compra'),
          icon: const Icon(Icons.payment),
        ),
        appBar: AppBar(
          title: const Text('Produtos'),
          actions: [
            IconButton(
              onPressed: () {
                AuthService().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.exit_to_app),
            ),
          ],
        ),
        body: Query(
          options: QueryOptions(document: gql(readProducts)),
          builder:
              (
                QueryResult result, {
                VoidCallback? refetch,
                FetchMore? fetchMore,
              }) {
                if (result.hasException) {
                  return Center(
                    child: Text('Erro: ${result.exception.toString()}'),
                  );
                }

                if (result.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final List products = result.data?['products'] ?? [];

                if (products.isEmpty) {
                  return const Center(child: Text('Nenhum produto encontrado'));
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(product['image'] ?? ''),
                        onBackgroundImageError: (exception, stackTrace) {
                          print(
                            "Erro ao carregar imagem (ignorado pelo teste): $exception",
                          );
                        },
                        child: const Icon(Icons.image_not_supported, size: 16),
                      ),
                      title: Text(product['name']),
                      subtitle: Text('R\$ ${product['price']}'),
                      trailing: IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Adicionado')),
                          );
                        },
                        icon: Icon(Icons.add_shopping_cart),
                      ),
                    );
                  },
                );
              },
        ),
      ),
    );
  }
}
