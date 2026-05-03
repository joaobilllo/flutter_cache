// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_problematico_catalog/domain/entities/cache_status.dart';
import 'package:flutter_problematico_catalog/domain/entities/product.dart';
import 'package:flutter_problematico_catalog/domain/repositories/product_repository.dart';
import 'package:flutter_problematico_catalog/domain/usecases/get_products.dart';
import 'package:flutter_problematico_catalog/main.dart';
import 'package:flutter_problematico_catalog/presentation/pages/product_list_page.dart';
import 'package:flutter_problematico_catalog/presentation/viewmodels/product_list_viewmodel.dart';
import 'package:flutter_problematico_catalog/presentation/widgets/offline_banner.dart';

class FakeProductRepository implements ProductRepository {
  final List<Product> productsToReturn;
  final CacheStatus statusToReturn;
  final DateTime? cachedAtToReturn;
  int callCount = 0;

  FakeProductRepository({
    this.productsToReturn = const [],
    this.statusToReturn = CacheStatus.network,
    this.cachedAtToReturn,
  });

  @override
  Future<ProductsResult> getProducts({
    int limit = 30,
    bool forceRefresh = false,
  }) async {
    callCount++;
    return (
      products: productsToReturn,
      status: statusToReturn,
      cachedAt: cachedAtToReturn ?? DateTime.now(),
    );
  }
}

class SlowFakeRepository implements ProductRepository {
  int callCount = 0;

  @override
  Future<ProductsResult> getProducts({
    int limit = 30,
    bool forceRefresh = false,
  }) async {
    callCount++;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return (
      products: <Product>[],
      status: CacheStatus.network,
      cachedAt: DateTime.now(),
    );
  }
}

void main() {
  testWidgets('App renders list scaffold', (WidgetTester tester) async {
    final getProducts = GetProducts(repository: FakeProductRepository());

    await tester.pumpWidget(MyApp(getProducts: getProducts));
    await tester.pump();

    expect(find.text('Catalogo Problematico'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('OfflineBanner aparece quando status do repositorio e offline',
      (WidgetTester tester) async {
    final repo = FakeProductRepository(
      productsToReturn: const [
        Product(
          id: 1,
          title: 'Produto X',
          description: 'd',
          category: 'c',
          price: 10,
          rating: 4.5,
          thumbnail: 'https://example.com/x.png',
          images: ['https://example.com/x.png'],
        ),
      ],
      statusToReturn: CacheStatus.offline,
      cachedAtToReturn: DateTime.now().subtract(const Duration(minutes: 3)),
    );
    final getProducts = GetProducts(repository: repo);

    await tester.pumpWidget(MaterialApp(
      home: ProductListPage(getProducts: getProducts),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.textContaining('Modo offline'), findsOneWidget);
  });

  testWidgets('OfflineBanner ausente quando status e network',
      (WidgetTester tester) async {
    final repo = FakeProductRepository(statusToReturn: CacheStatus.network);
    final getProducts = GetProducts(repository: repo);

    await tester.pumpWidget(MaterialApp(
      home: ProductListPage(getProducts: getProducts),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.byType(OfflineBanner), findsNothing);
  });

  test('ViewModel nao dispara duas chamadas em paralelo', () async {
    final repo = SlowFakeRepository();
    final viewModel = ProductListViewModel(
      getProducts: GetProducts(repository: repo),
    );

    // Dispara duas requisicoes ao mesmo tempo: a segunda deve ser ignorada.
    final f1 = viewModel.refresh();
    final f2 = viewModel.refresh();
    await Future.wait([f1, f2]);

    expect(repo.callCount, 1);
  });
}
