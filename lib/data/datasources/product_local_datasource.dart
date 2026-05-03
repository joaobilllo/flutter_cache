import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_dto.dart';

typedef LocalCacheEntry = ({List<ProductDto> products, DateTime cachedAt});

class ProductLocalDatasource {
  static const _productsKey = 'products_cache';
  static const _cachedAtKey = 'products_cache_at';

  final SharedPreferences prefs;

  const ProductLocalDatasource({required this.prefs});

  Future<LocalCacheEntry?> read() async {
    final raw = prefs.getString(_productsKey);
    final cachedAtMillis = prefs.getInt(_cachedAtKey);

    if (raw == null || cachedAtMillis == null) {
      return null;
    }

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final products = list
          .map((item) => ProductDto.fromMap(item as Map<String, dynamic>))
          .toList();
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);
      return (products: products, cachedAt: cachedAt);
    } catch (_) {
      // Cache corrompido: descarta para evitar travas.
      await clear();
      return null;
    }
  }

  Future<void> save(List<ProductDto> products, DateTime at) async {
    final encoded = jsonEncode(products.map((dto) => dto.toMap()).toList());
    await prefs.setString(_productsKey, encoded);
    await prefs.setInt(_cachedAtKey, at.millisecondsSinceEpoch);
  }

  Future<void> clear() async {
    await prefs.remove(_productsKey);
    await prefs.remove(_cachedAtKey);
  }
}
