import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository repository;

  const GetProducts({required this.repository});

  Future<List<Product>> call({int limit = 30}) {
    return repository.getProducts(limit: limit);
  }
}
