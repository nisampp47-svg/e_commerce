import 'package:flutter/material.dart';

import '../../model/product_model.dart';
import '../core/service_locator.dart';
import '../data/repositories/interfaces/cart_repository.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository = getIt<CartRepository>();

  final List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => List.unmodifiable(_items);

  bool get isLoading => _isLoading;

  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);

  double get totalPrice =>
      _items.fold(0.0, (sum, i) => sum + i.product.price * i.quantity);

  // ── LOAD FROM DB on app start ───────────────────────────────────────────────
  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rows = await _cartRepository.fetchAllItems();
      _items.clear();

      for (final row in rows) {
        final product = ProductModel(
          id: row['id'] as String,
          categoryId: row['categoryId'] as String,
          name: row['name'] as String,
          price: (row['price'] as num).toDouble(),
          image: row['image'] as String,
          rating: (row['rating'] as num?)?.toDouble() ?? 0.0,
          description: row['description'] as String?,
          isRecommended: (row['isRecommended'] as int? ?? 0) == 1,
        );
        _items.add(CartItem(product: product, quantity: row['quantity'] as int));
      }
    } catch (e) {
      debugPrint('CartProvider.loadCart error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── ADD ─────────────────────────────────────────────────────────────────────
  Future<void> addToCart(ProductModel product) async {
    final index = _items.indexWhere((i) => i.product.id == product.id);

    if (index != -1) {
      _items[index].quantity++;
      await _cartRepository.updateQuantity(product.id, _items[index].quantity);
    } else {
      _items.add(CartItem(product: product));
      await _cartRepository.addItem(
        id: product.id,
        categoryId: product.categoryId,
        name: product.name,
        price: product.price,
        image: product.image,
        rating: product.rating,
        quantity: 1,
        description: product.description,
        isRecommended: product.isRecommended,
      );
    }

    notifyListeners();
  }

  // ── REMOVE ──────────────────────────────────────────────────────────────────
  Future<void> removeFromCart(String productId) async {
    _items.removeWhere((i) => i.product.id == productId);
    await _cartRepository.deleteItem(productId);
    notifyListeners();
  }

  // ── INCREMENT ───────────────────────────────────────────────────────────────
  Future<void> incrementQuantity(String productId) async {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index != -1) {
      _items[index].quantity++;
      await _cartRepository.updateQuantity(productId, _items[index].quantity);
      notifyListeners();
    }
  }

  // ── DECREMENT ───────────────────────────────────────────────────────────────
  Future<void> decrementQuantity(String productId) async {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index != -1) {
      if (_items[index].quantity <= 1) {
        await removeFromCart(productId);
      } else {
        _items[index].quantity--;
        await _cartRepository.updateQuantity(productId, _items[index].quantity);
        notifyListeners();
      }
    }
  }

  // ── CLEAR ALL ───────────────────────────────────────────────────────────────
  Future<void> clear() async {
    _items.clear();
    await _cartRepository.clearAll();
    notifyListeners();
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────────
  bool isInCart(String productId) =>
      _items.any((i) => i.product.id == productId);

  int quantityOf(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    return index != -1 ? _items[index].quantity : 0;
  }
}
