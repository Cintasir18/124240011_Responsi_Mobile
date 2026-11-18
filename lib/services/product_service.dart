
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../models/product.dart';

class ProductService {

  Future<List<Product>> getProducts() async {
    final response = await http
        .get(Uri.parse(AppConfig.productURL))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final List<dynamic> data =
          jsonDecode(response.body) as List<dynamic>;

      return data
          .map(
            (item) => Product.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Gagal mengambil produk: ${response.statusCode}',
    );
  }

  Future<Product> getProductById(int id) async {
    final response = await http
        .get(Uri.parse('${AppConfig.productURL}$id'))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      return Product.fromJson(data);
    }

    throw Exception(
      'Gagal mengambil detail produk: ${response.statusCode}',
    );
  }
}
