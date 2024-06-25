import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLConfiguration {
  static Future<GraphQLClient> initGraphQL(String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('accessToken');

    print("token");
    print(token);

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );

    final HttpLink httpLink = HttpLink(
      url,
    );

    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }
}
