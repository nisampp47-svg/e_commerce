import 'package:e_commerce/core/app_constants.dart';
import 'package:e_commerce/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:e_commerce/data/repositories/category_data.dart';
import 'package:e_commerce/data/repositories/product_data.dart';
import 'package:e_commerce/model/category_model.dart';
import 'package:e_commerce/widget/category_icons.dart';
import 'package:e_commerce/widget/home_banner.dart';
import 'package:e_commerce/widget/populer_item_card.dart';
import 'package:e_commerce/widget/product_card.dart';
import 'package:e_commerce/widget/search_bar.dart';
import 'package:e_commerce/model/product_model.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final List<CategoryModel> categories = dummyCategories;
  String selectedCategoryId = "all";

  // ── helpers ───────────────────────────────────────────────────────────────

  List<ProductModel> get _filteredProducts => selectedCategoryId == "all"
      ? products
      : products.where((p) => p.categoryId == selectedCategoryId).toList();

  List<ProductModel> get _recommendedProducts =>
      _filteredProducts.where((p) => p.isRecommended).toList();

  String get _sectionTitle {
    if (selectedCategoryId == "all") return "Recommended for You";
    final category = categories.firstWhere(
          (c) => c.categoryId == selectedCategoryId,
      orElse: () => categories.first,
    );
    return "Results for ${category.categoryTitle}";
  }

  Widget _buildSectionHeader(
      BuildContext context, {
        required String title,
        VoidCallback? onSeeAll,
      }) {
    final theme = Theme.of(context);
    return Padding(
      padding: AppPadding.horizontalPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text("See All")),
        ],
      ),
    );
  }

  // ── theme toggle (extracted to avoid AppBar rebuild lag) ──────────────────

  Widget _buildThemeToggle() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () {
            // Direct update is faster and prevents the "freeze"
            themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
          },
        );
      },
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Location",
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                const Text(
                  "New York, USA",
                  style:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          _buildThemeToggle(), // ✓ extracted — only this widget rebuilds on toggle
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            const Padding(
              padding: AppPadding.screenPadding,
              child: MySearchBar(icon: Icons.tune),
            ),

            // Banner
            const HomeBanner(),

            const SizedBox(height: AppPadding.large),

            // Categories header
            _buildSectionHeader(
              context,
              title: "Categories",
              onSeeAll: () => context.pushNamed('catalog'),
            ),

            const SizedBox(height: AppPadding.small),

            // Categories list
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.medium),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryIcons(
                    category: category,
                    isSelected: selectedCategoryId == category.categoryId,
                    onTap: () => setState(
                            () => selectedCategoryId = category.categoryId),
                  );
                },
              ),
            ),

            const SizedBox(height: AppPadding.large),

            // Recommended header
            _buildSectionHeader(context, title: _sectionTitle),

            const SizedBox(height: AppPadding.medium),

            // Recommended horizontal list
            SizedBox(
              height: 300,
              child: ListView.builder(
                key: ValueKey('recommended_$selectedCategoryId'), // ✓ rebuilds on category change
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.medium),
                itemCount: _recommendedProducts.length,
                itemBuilder: (context, index) {
                  final product = _recommendedProducts[index];
                  return Padding(
                    padding:
                    const EdgeInsets.only(right: AppPadding.medium),
                    child: SizedBox(
                      width: 180,
                      child: ProductListCard(
                        product: product,
                        onTap: () => context.pushNamed(
                          'product_detail',
                          pathParameters: {'id': product.id},
                          extra: product,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppPadding.large),

            // Popular items header
            _buildSectionHeader(context, title: "Popular Items"),

            // Popular items vertical list
            // ✓ fix: key forces full rebuild when category changes
            ListView.builder(
              key: ValueKey('popular_$selectedCategoryId'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: AppPadding.screenPadding,
              itemCount: _filteredProducts.length.clamp(0, 4),
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return PopularItemCard(
                  product: product,
                  onTap: () => context.pushNamed(
                    'product_detail',
                    pathParameters: {'id': product.id},
                    extra: product,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}