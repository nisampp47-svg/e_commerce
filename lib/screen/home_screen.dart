
import 'package:e_commerce/screen/product_screen.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/category_data.dart';
import '../../../data/repositories/product_data.dart';
import '../../../model/category_model.dart';
import '../../widget/category_icons.dart';
import '../../widget/home_banner.dart';
import '../../widget/populer_item_card.dart';
import '../../widget/product_card.dart';
import '../../widget/search_bar.dart';
import '../../widget/shimmer_title.dart';
import '../model/product_model.dart';
import 'category_product_screen.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({
    super.key,
    required List<dynamic> categories,
    required List<ProductModel> products,
  });

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {

  late final List<CategoryModel> categories = dummyCategories;

  String selectedCategory = "all";

  @override
  Widget build(BuildContext context) {
    final recommendedProducts = products.where((p) => p.isRecommended).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              color: Colors.green,
            ),
            SizedBox(width: 4), // small gap
            ShimmerText(text: "Get Faster Delivery ", fontSize: 18, color: Colors.black87,)
          ],
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              /// 🔍 Search Bar
              const MySearchBar(icon: Icons.notification_add_outlined),

              const SizedBox(height: 30),

              /// 🪑 Categories Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = "all";
                      });
                    },
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CategoryProductsScreen(
                              categoryId: "all",
                              title: "All Products",
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "See All",
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// 🎯 Full Width Categories
              Row(
                children: List.generate(
                  categories.length-1,
                      (index) => CategoryIcons(
                    category: categories[index],
                    onTap: () {
                      setState(() {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(milliseconds: 600),
                            pageBuilder: (_, animation, secondaryAnimation) =>
                            CategoryProductsScreen(categoryId: categories[index].categoryId, title: categories[index].categoryTitle),
                            transitionsBuilder: (_, animation, secondaryAnimation, child) {
                              return child; // no fade, only Hero animates
                            },
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              HomeBanner(),
              const SizedBox(height: 30),

              /// ⭐ Recommended Section
              const Text(
                "Recommended for You",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 320,
                child: ListView.builder(

                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedProducts.length,
                  // ... inside MyHomeScreen ListView.builder
                  itemBuilder: (context, index) {
                    final product = recommendedProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ProductListCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductHeroScreen(product: product,), // Navigate to your hero screen
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              const Text(
                "Popular Now",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              Column(
                children: products.take(4).map((product) {
                  return PopularItemCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductHeroScreen(product: product),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
