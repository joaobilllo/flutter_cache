import 'package:flutter/material.dart';

import '../../domain/entities/cache_status.dart';
import '../../domain/entities/product.dart';
import '../../domain/exceptions/network_unavailable_exception.dart';
import '../../domain/usecases/get_products.dart';

class ProductListViewModel extends ChangeNotifier {
  final GetProducts getProducts;

  bool isLoading = false;
  String? errorMessage;
  List<Product> products = [];
  CacheStatus? lastStatus;
  DateTime? lastSyncedAt;

  bool _inFlight = false;

  ProductListViewModel({required this.getProducts});

  bool get isOffline => lastStatus == CacheStatus.offline;

  Future<void> load() => _fetch(forceRefresh: false);

  Future<void> refresh() => _fetch(forceRefresh: true);

  Future<void> _fetch({required bool forceRefresh}) async {
    if (_inFlight) {
      return;
    }
    _inFlight = true;

    // Mantem a lista em tela enquanto revalida; spinner full so quando vazio.
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await getProducts(forceRefresh: forceRefresh);
      products = result.products;
      lastStatus = result.status;
      lastSyncedAt = result.cachedAt;
    } on NetworkUnavailableException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Falha ao carregar produtos: $e';
    } finally {
      isLoading = false;
      _inFlight = false;
      notifyListeners();
    }
  }
}
