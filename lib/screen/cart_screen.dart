import 'package:flutter/material.dart';
import '../../../data/cart_database_helper.dart';
import '../services/phone_pay_service.dart';
import '../widget/cart_item_card.dart';

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

  Future<void> loadCart() async {
    final data = await CartDatabaseHelper.instance.fetchAllItems();
    setState(() {
      cartItems = data;
      isLoading = false;
    });
  }

  Future<void> increment(Map<String, dynamic> item) async {
    await CartDatabaseHelper.instance.updateQuantity(item['id'], item['quantity'] + 1);
    loadCart();
  }

  Future<void> decrement(Map<String, dynamic> item) async {
    int qty = item['quantity'];
    if (qty <= 1) {
      await CartDatabaseHelper.instance.deleteItem(item['id']);
    } else {
      await CartDatabaseHelper.instance.updateQuantity(item['id'], qty - 1);
    }
    loadCart();
  }

  Future<void> deleteItem(String id) async {
    await CartDatabaseHelper.instance.deleteItem(id);
    loadCart();
  }

  Future<void> clearCart() async {
    await CartDatabaseHelper.instance.clearAll();
    loadCart();
  }

  double get totalPrice {
    return cartItems.fold(0, (sum, item) => sum + item['price'] * item['quantity']);
  }

  int get totalItems {
    return cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  // ─── PAY ──────────────────────────────────────────────────────────────────
  Future<void> _handlePayment() async {
    setState(() => _isPaymentLoading = true);

    final result = await PhonePePaymentService.instance.startPayment(
      context: context,
      amountInRupees: totalPrice,
      userId: 'USER_001', // replace with your actual logged-in user ID
    );

    setState(() => _isPaymentLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      // ✅ Payment succeeded — clear cart and show success
      await clearCart();
      _showResultDialog(
        success: true,
        title: 'Payment Successful!',
        message: 'Transaction ID: ${result['transactionId']}',
      );
    } else {
      // ❌ Payment failed or cancelled
      _showResultDialog(
        success: false,
        title: 'Payment Failed',
        message: result['message'] ?? 'Something went wrong. Please try again.',
      );
    }
  }

  void _showResultDialog({
    required bool success,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: Icon(
          success ? Icons.check_circle_rounded : Icons.error_rounded,
          color: success ? Colors.green : Colors.red,
          size: 48,
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  // ──────────────────────────────────────────────────────────────────────────

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
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return CartItemCard(
                  item: item,
                  onAdd: () => increment(item),
                  onRemove: () => decrement(item),
                  onDelete: () => deleteItem(item['id']),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08), // fixed: was withAlpha(255) which is full black
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
                  child: ElevatedButton(
                    onPressed: _isPaymentLoading ? null : _handlePayment,
                    child: _isPaymentLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                        : const Text("Proceed To Payment"),
                  ),
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