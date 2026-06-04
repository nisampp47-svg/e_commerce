
abstract class CartRepository {
  Future<List<Map<String, dynamic>>> fetchAllItems();
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
  });
  Future<void> updateQuantity(String id, int quantity);
  Future<void> deleteItem(String id);
  Future<void> clearAll();
}