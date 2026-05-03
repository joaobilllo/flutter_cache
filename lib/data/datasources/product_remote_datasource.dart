import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_dto.dart';

class ProductRemoteDatasource {
  final http.Client client;
  final String baseUrl;

  const ProductRemoteDatasource({
    required this.client,
    required this.baseUrl,
  });

  Future<List<ProductDto>> fetchProducts({int limit = 30}) async {
    final uri = Uri.parse('$baseUrl/products?limit=$limit');
    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar produtos');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rawProducts = data['products'] as List<dynamic>;

    return rawProducts
        .map((item) => ProductDto.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
