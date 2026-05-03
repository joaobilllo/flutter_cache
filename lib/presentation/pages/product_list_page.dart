import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products.dart';
import '../viewmodels/product_list_viewmodel.dart';
import '../widgets/product_image.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  final GetProducts getProducts;

  const ProductListPage({super.key, required this.getProducts});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final ProductListViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ProductListViewModel(getProducts: widget.getProducts);
    viewModel.loadProducts();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> openDetails(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(product: product),
      ),
    );

    if (!mounted) {
      return;
    }

    await viewModel.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Catalogo Problematico'),
            actions: [
              IconButton(
                onPressed: viewModel.loadProducts,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              if (viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (viewModel.errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          viewModel.errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: viewModel.loadProducts,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: viewModel.products.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = viewModel.products[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ProductImage(
                      url: product.thumbnail,
                      width: 72,
                      height: 72,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${product.category} • R\$ ${product.price.toStringAsFixed(2)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => openDetails(product),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
