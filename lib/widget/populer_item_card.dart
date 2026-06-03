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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow, // ✓ theme-aware
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha(20),   // ✓ theme-aware
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image — ✓ removed invalid Expanded inside Hero
            SizedBox(
              height: 95,
              width: 95,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Hero(
                  tag: 'popular_${product.id}',
                  child: SupabaseImage(
                    imageName: product.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Text section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Category: ${product.categoryId}",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant, // ✓ theme-aware
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary, // ✓ theme-aware
                    ),
                  ),
                ],
              ),
            ),

            // Arrow button
            Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest, // ✓ theme-aware
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant, // ✓ theme-aware
              ),
            ),
          ],
        ),
      ),
    );
  }
}