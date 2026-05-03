import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/product_local_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/usecases/get_products.dart';
import 'presentation/pages/product_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final client = http.Client();

  final remoteDatasource = ProductRemoteDatasource(
    client: client,
    baseUrl: 'https://dummyjson.com',
  );
  final localDatasource = ProductLocalDatasource(prefs: prefs);
  final repository = ProductRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );
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
