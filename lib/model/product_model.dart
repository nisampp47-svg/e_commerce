class ProductModel {
  final String id;
  final String name;
  final double price;
  final String image;
  final String categoryId;
  final bool isRecommended;
  final double? rating;
  final String? description;
  final List<String>? reviews;
  final Map<String, String>? specifications;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.categoryId,
    this.rating,
    this.isRecommended = true,
    this.description,
    this.reviews,
    this.specifications,
  });
}
