import 'package:e_commerce/core/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      builder: (ctx) => AlertDialog(
        icon: Icon(
          success ? Icons.check_circle_rounded : Icons.error_rounded,
          color: success ? Colors.green : Colors.red,
          size: 48,
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 100, color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              const SizedBox(height: 24),
              Text("Your cart is empty", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Looks like you haven't added anything yet."),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text("Start Shopping"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: clearCart,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: "Clear All",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              padding: const EdgeInsets.all(AppPadding.medium),
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
            padding: const EdgeInsets.all(AppPadding.large),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _row("Items", "$totalItems"),
                  _row("Subtotal", "₹${totalPrice.toStringAsFixed(2)}"),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text("₹${totalPrice.toStringAsFixed(2)}", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _isPaymentLoading ? null : _handlePayment,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumBorderRadius),
                      ),
                      child: _isPaymentLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Proceed To Checkout"),
                    ),
                  ),
                ],
              ),
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