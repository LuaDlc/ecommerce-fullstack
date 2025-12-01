import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_api/core/storage/token_storage.dart';

class GraphQLConfig {
  static final HttpLink _httpLink = HttpLink(
    'http://10.0.2.2:5000/graphql', // para android
  ); //10.0.2.2 para android para ios: 'http://localhost:4000/graphql'

  static final AuthLink _authLink = AuthLink(
    getToken: () async {
      final token = await TokenStorage().getAccessToken();
      return 'Bearer $token';
    },
  );

  static final Link _link = _authLink.concat(_httpLink);

  static ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: _link,
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );
}
