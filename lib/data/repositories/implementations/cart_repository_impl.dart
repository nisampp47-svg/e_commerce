import '../interfaces/cart_repository.dart';
import '../../cart_database_helper.dart';

class CartRepositoryImpl implements CartRepository {
  final CartDatabaseHelper _dbHelper = CartDatabaseHelper.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchAllItems() {
    return _dbHelper.fetchAllItems();
  }

  @override
  Future<void> addItem({
    required String id,
    required String name,
    required double price,
    required String image,
    required String categoryId,
    required double rating,
    required int quantity,
    String? description,
    required bool isRecommended,
  }) {
    return _dbHelper.upsertItem(
      id: id,
      name: name,
      price: price,
      image: image,
      categoryId: categoryId,
      rating: rating,
      quantity: quantity,
      description: description,
      isRecommended: isRecommended,
    );
  }

  @override
  Future<void> updateQuantity(String id, int quantity) {
    return _dbHelper.updateQuantity(id, quantity);
  }

  @override
  Future<void> deleteItem(String id) {
    return _dbHelper.deleteItem(id);
  }

  @override
  Future<void> clearAll() {
    return _dbHelper.clearAll();
  }
}
