import 'package:flutter/material.dart';
import '../../../data/cart_database_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = true;
  bool _isPaymentLoading = false;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  /// LOAD CART
  Future<void> loadCart() async {
    final data = await CartDatabaseHelper.instance.fetchAllItems();
    setState(() {
      cartItems = data;
      isLoading = false;
    });
  }

  /// INCREMENT
  Future<void> increment(Map<String, dynamic> item) async {
    final qty = item['quantity'] + 1;
    await CartDatabaseHelper.instance.updateQuantity(item['id'], qty);
    loadCart();
  }

  /// DECREMENT
  Future<void> decrement(Map<String, dynamic> item) async {
    int qty = item['quantity'];
    if (qty <= 1) {
      await CartDatabaseHelper.instance.deleteItem(item['id']);
    } else {
      await CartDatabaseHelper.instance.updateQuantity(item['id'], qty - 1);
    }
    loadCart();
  }

  /// DELETE
  Future<void> deleteItem(String id) async {
    await CartDatabaseHelper.instance.deleteItem(id);
    loadCart();
  }

  /// CLEAR
  Future<void> clearCart() async {
    await CartDatabaseHelper.instance.clearAll();
    loadCart();
  }

  /// TOTAL PRICE
  double get totalPrice {
    double total = 0;
    for (var item in cartItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  /// TOTAL ITEMS
  int get totalItems {
    int count = 0;
    for (var item in cartItems) {
      count += item['quantity'] as int;
    }
    return count;
  }

  /// PAY


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (cartItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Cart")),
        body: const Center(child: Text("Your cart is empty")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
        actions: [
          TextButton(onPressed: clearCart, child: const Text("Clear All")),
        ],
      ),
      body: Column(
        children: [
          /// CART LIST
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return _CartItemCard(
                  item: item,
                  onAdd: () => increment(item),
                  onRemove: () => decrement(item),
                  onDelete: () => deleteItem(item['id']),
                );
              },
            ),
          ),

          /// SUMMARY
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(255),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                _row("Items", "$totalItems"),
                _row("Subtotal", "₹${totalPrice.toStringAsFixed(2)}"),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,

                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CART ITEM CARD (unchanged)
// ─────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int qty = item['quantity'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              item['image'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text("₹${item['price']}"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: onRemove,
                    ),
                    Text("$qty"),
                    IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
