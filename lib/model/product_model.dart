class ProductModel {
  final String id;
  final String name;
  final double price;
  final String image; //asset path
  final String categoryId;
  final bool isRecommended;
  final double? rating;


  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.categoryId,
     this.rating,
    this.isRecommended = true,
  });

}
