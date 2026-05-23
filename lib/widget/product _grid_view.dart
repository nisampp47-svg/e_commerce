import 'package:flutter/material.dart';
import '../../model/product_model.dart';
import '../screen/product_screen.dart';
import 'product_card.dart';

class ProductGridView extends StatelessWidget {
  final List<ProductModel> products;

  const ProductGridView({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true, // ✅ VERY IMPORTANT
      physics: const NeverScrollableScrollPhysics(), // ✅ VERY IMPORTANT
      padding: const EdgeInsets.only(top: 16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        return ProductListCard(
          product: products[index],
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 600),
                pageBuilder: (_, animation, secondaryAnimation) =>
                    ProductHeroScreen(product: products[index], ),
                transitionsBuilder: (_, animation, secondaryAnimation, child) {
                  return child; // no fade, only Hero animates
                },
              ),
            );
          },
        );
      },
    );
  }
}
