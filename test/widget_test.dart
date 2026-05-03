// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_problematico_catalog/domain/entities/product.dart';
import 'package:flutter_problematico_catalog/domain/repositories/product_repository.dart';
import 'package:flutter_problematico_catalog/domain/usecases/get_products.dart';
import 'package:flutter_problematico_catalog/main.dart';

class FakeProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts({int limit = 30}) async {
    return [];
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
}
