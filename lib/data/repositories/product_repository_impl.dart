import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;

  const ProductRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<Product>> getProducts({int limit = 30}) async {
    final items = await remoteDatasource.fetchProducts(limit: limit);
    return items.map((item) => item.toEntity()).toList();
  }
}
