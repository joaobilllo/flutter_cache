import '../entities/cache_status.dart';
import '../entities/product.dart';

typedef ProductsResult = ({
  List<Product> products,
  CacheStatus status,
  DateTime? cachedAt,
});

abstract class ProductRepository {
  Future<ProductsResult> getProducts({
    int limit = 30,
    bool forceRefresh = false,
  });
}
