import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLService {
  late GraphQLClient _client;
  late HttpLink _httpLink;
  AuthLink? _authLink;

  GraphQLService(String url) {
    _httpLink = HttpLink(url);
    _initializeClient();
  }

  GraphQLClient get client => _client;

  Future<void> _initializeClient() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token != null) {
      _authLink = AuthLink(
        getToken: () async => 'Bearer $token',
      );
      final Link link = _authLink!.concat(_httpLink);
      _client = GraphQLClient(
        cache: GraphQLCache(),
        link: link,
      );
    } else {
      _client = GraphQLClient(
        cache: GraphQLCache(),
        link: _httpLink,
      );
    }
  }

  Future<void> setToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);

    _authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );

    final Link link = _authLink!.concat(_httpLink);

    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }
}
