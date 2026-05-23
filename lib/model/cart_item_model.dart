class CartItemIteModel {
  final int? id;
  final String productId;
  final String name;
  final double price;
  final String image;
  final int quantity;

  CartItemIteModel({
    this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }

  factory CartItemIteModel.fromMap(Map<String, dynamic> map) {
    return CartItemIteModel(
      id: map['id'],
      productId: map['productId'],
      name: map['name'],
      price: map['price'],
      image: map['image'],
      quantity: map['quantity'],
    );
  }
}