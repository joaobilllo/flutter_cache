import 'package:flutter/material.dart';

import '../../domain/entities/product.dart';
import '../widgets/product_image.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: product.images.length,
                    itemBuilder: (context, index) {
                      return ProductImage(
                        url: product.images[index],
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(product.category),
                            avatar: const Icon(Icons.category, size: 16),
                          ),
                          Chip(
                            label:
                                Text('R\$ ${product.price.toStringAsFixed(2)}'),
                            avatar: const Icon(Icons.attach_money, size: 16),
                            backgroundColor: Colors.green.shade100,
                          ),
                          Chip(
                            label: Text(product.rating.toStringAsFixed(1)),
                            avatar: const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Observação: ao voltar desta tela, a lista principal mantém o cache local - sem nova chamada de rede.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
