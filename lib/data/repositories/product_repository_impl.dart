import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../domain/entities/cache_status.dart';
import '../../domain/exceptions/network_unavailable_exception.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  static const Duration cacheTtl = Duration(minutes: 2);

  final ProductRemoteDatasource remoteDatasource;
  final ProductLocalDatasource localDatasource;

  const ProductRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<ProductsResult> getProducts({
    int limit = 30,
    bool forceRefresh = false,
  }) async {
    final cached = await localDatasource.read();
    final now = DateTime.now();

    if (!forceRefresh &&
        cached != null &&
        now.difference(cached.cachedAt) < cacheTtl) {
      return (
        products: cached.products.map((dto) => dto.toEntity()).toList(),
        status: CacheStatus.fresh,
        cachedAt: cached.cachedAt,
      );
    }

    try {
      final fresh = await remoteDatasource.fetchProducts(limit: limit);
      await localDatasource.save(fresh, now);
      return (
        products: fresh.map((dto) => dto.toEntity()).toList(),
        status: CacheStatus.network,
        cachedAt: now,
      );
    } on SocketException {
      return _fallbackOrThrow(cached);
    } on TimeoutException {
      return _fallbackOrThrow(cached);
    } on http.ClientException {
      return _fallbackOrThrow(cached);
    }
  }

  ProductsResult _fallbackOrThrow(LocalCacheEntry? cached) {
    if (cached != null) {
      return (
        products: cached.products.map((dto) => dto.toEntity()).toList(),
        status: CacheStatus.offline,
        cachedAt: cached.cachedAt,
      );
    }
    throw const NetworkUnavailableException();
  }
}
