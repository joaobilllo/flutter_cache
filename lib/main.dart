import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/get_products.dart';
import 'presentation/pages/product_list_page.dart';

void main() {
  final client = http.Client();
  final datasource = ProductRemoteDatasource(
    client: client,
    baseUrl: 'https://dummyjson.com',
  );
  final repository = ProductRepositoryImpl(remoteDatasource: datasource);
  final getProducts = GetProducts(repository: repository);

  runApp(MyApp(getProducts: getProducts));
}

class MyApp extends StatelessWidget {
  final GetProducts getProducts;

  const MyApp({super.key, required this.getProducts});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catalogo Problematico',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ProductListPage(getProducts: getProducts),
    );
  }
}
