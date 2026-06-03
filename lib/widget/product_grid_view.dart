import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../model/product_model.dart';
import 'product_card.dart';

class ProductGridView extends StatelessWidget {
  final List<ProductModel> products;

  const ProductGridView({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductListCard(
          product: product,
          onTap: () => context.pushNamed(
            'product_detail',
            pathParameters: {'id': product.id},
            extra: product,
          ),
        );
      },
    );
  }
}
