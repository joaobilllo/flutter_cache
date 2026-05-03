import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  const GetProducts({required this.repository});

  Future<ProductsResult> call({
    int limit = 30,
    bool forceRefresh = false,
  }) {
    return repository.getProducts(
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
