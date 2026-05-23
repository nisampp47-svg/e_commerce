import 'package:flutter/material.dart';

import '../../model/product_model.dart';
import '../services/supabase_images.dart';

class PopularItemCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const PopularItemCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the entire card in a GestureDetector
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [ 
            /// Product Image 
            /// Product Image
            SizedBox(
              height: 95,
              width: 95,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),

                child: Hero(
                  tag: 'popular_${product.id}',
                  child: Expanded(
                    child: SupabaseImage(
                      imageName: product.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            /// Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Category: ${product.categoryId}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            /// Arrow Button
            Container(
              height: 36,
              width: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE9E9E9),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF7A7A7A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}