import '../../../model/category_model.dart';
import '../../../model/product_model.dart';
import '../interfaces/catalog_repository.dart';
import '../product_data.dart';
import '../category_data.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  // Constructor injection (when you add real backend)
  // final SupabaseService supabaseService;
  // CatalogRepositoryImpl(this.supabaseService);

  @override
  Future<List<CategoryModel>> getCategories() async {
    // TODO: Replace with actual Supabase call
    // return await supabaseService.getCategories();

    // For now, return mock data
    return dummyCategories;
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    // TODO: Replace with actual Supabase call
    // return await supabaseService.getProducts();

    // For now, return mock data
    return products;
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    // TODO: Replace with actual Supabase call
    // return await supabaseService.getProductsByCategory(categoryId);

    // For now, filter mock data
    if (categoryId == 'all') {
      return products;
    }
    return products.where((p) => p.categoryId == categoryId).toList();
  }
}