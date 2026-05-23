import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/product_model.dart';
import '../../widget/expantable_text.dart';
import '../providers/cart_provider.dart';
import '../services/supabase_images.dart';

class ProductHeroScreen extends StatefulWidget {
  final ProductModel product;


  const ProductHeroScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductHeroScreen> createState() => _ProductHeroScreenState();
}

class _ProductHeroScreenState extends State<ProductHeroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ===============================
            // HERO IMAGE
            // ===============================
            SizedBox(
              height: size.height * 0.45,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: SupabaseImage(
                        imageName: product.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===============================
            // PRODUCT DETAILS
            // ===============================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ============================
                        // NAME + PREMIUM PRICE RIGHT
                        // ============================
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Premium Right Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "\$${product.price.toStringAsFixed(2)}",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 16, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      product.rating?.toStringAsFixed(1) ?? "0.0",
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ============================
                        // DESCRIPTION TITLE
                        // ============================
                        Text(
                          "DESCRIPTION",
                          style: theme.textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ============================
                        // EXPANDABLE DESCRIPTION
                        // ============================
                        ExpandableText(
                          text:
                          "Experience premium comfort with this beautifully handcrafted piece. "
                              "Designed with high-density foam cushions and a solid wood frame, "
                              "this furniture item brings elegance and durability to your living space. "
                              "Perfect for modern and classic interiors alike.",
                        ),

                        const Spacer(),

                        // PRIMARY BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              final cart = Provider.of<CartProvider>(context, listen: false);
                              await cart.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${product.name} added to cart')),
                              );
                            },
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text("Add to Cart"),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // SECONDARY BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text("Buy Now"),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}