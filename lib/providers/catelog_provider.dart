import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../data/repositories/interfaces/catalog_repository.dart';
import '../model/product_model.dart';
import '../model/category_model.dart';

class CatalogProvider extends ChangeNotifier {
  final CatalogRepository _repository = getIt<CatalogRepository>();

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _filteredProducts;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _products = await _repository.getProducts();
      _filteredProducts = _products;
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> filterByCategory(String categoryId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _filteredProducts = await _repository.getProductsByCategory(categoryId);
    } catch (e) {
      debugPrint('Error filtering products: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}