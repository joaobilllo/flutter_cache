import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';

class ProductListViewModel extends ChangeNotifier {
  final GetProducts getProducts;

  bool isLoading = false;
  String? errorMessage;
  List<Product> products = [];

  ProductListViewModel({required this.getProducts});

  Future<void> loadProducts() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await getProducts();
      products = result;
    } catch (e) {
      errorMessage = 'Falha ao carregar produtos: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
