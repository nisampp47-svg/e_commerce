import 'package:flutter/material.dart';

import '../../../data/repositories/product_data.dart';
import '../../widget/product_grid_view.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryId;
  final String title;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    /// Filter products by category
    final filteredProducts = categoryId == "all"
        ? products
        : products.where((p) => p.categoryId == categoryId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: ProductGridView(products: filteredProducts),
      ),
    );
  }
}
