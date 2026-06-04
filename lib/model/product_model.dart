class ProductModel {
  final String id;
  final String name;
  final double price;
  final String image;
  final String categoryId;
  final bool isRecommended;
  final double rating;
  final String? description;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.isRecommended,
    required this.rating,
    this.description,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      categoryId: json['category_id'] as String,
      isRecommended: json['is_recommended'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'image': image,
    'category_id': categoryId,
    'is_recommended': isRecommended,
    'rating': rating,
    'description': description,
  };
}
