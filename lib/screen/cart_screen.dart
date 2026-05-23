import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../providers/cart_provider.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_images.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Razorpay _razorpay = Razorpay();
  bool isPaymentLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    // Ensure cart is loaded from DB
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
    });
  }

  // ─────────────────────────────────────────────
  // RAZORPAY INITIALIZE
  // ─────────────────────────────────────────────

  void _initializeRazorpay() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // ─────────────────────────────────────────────
  // PAYMENT SUCCESS
  // ─────────────────────────────────────────────

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    setState(() {
      isPaymentLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful! ID: ${response.paymentId}'),
        backgroundColor: Colors.green,
      ),
    );

    await context.read<CartProvider>().clear();
  }

  // ─────────────────────────────────────────────
  // PAYMENT ERROR
  // ─────────────────────────────────────────────

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;

    setState(() {
      isPaymentLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Payment Failed'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // EXTERNAL WALLET
  // ─────────────────────────────────────────────

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${response.walletName}')),
    );
  }

  // ─────────────────────────────────────────────
  // OPEN PAYMENT
  // ─────────────────────────────────────────────

  void _processPayment(CartProvider cart) {
    if (cart.totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    setState(() {
      isPaymentLoading = true;
    });

    final authService = SupabaseAuthService();

    final options = {
      'key': 'rzp_test_Ss2b3toLNSblG9',
      'amount': (cart.totalPrice * 100).toInt(),
      'name': 'E-Commerce Store',
      'description': 'Order payment - ${cart.totalItems} items',
      'prefill': {
        'contact': '9999999999',
        'email': authService.userEmail,
      },
      'method': {
        'upi': true,
        'card': true,
        'wallet': true,
        'netbanking': true,
      },
      'theme': {
        'color': '#3399cc',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isPaymentLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.read<CartProvider>().clear(),
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cart.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              // CART ITEMS
              Expanded(
                child: ListView.builder(
                  itemCount: cart.items.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final cartItem = cart.items[index];

                    return _CartItemCard(
                      cartItem: cartItem,
                      onAdd: () => cart.incrementQuantity(cartItem.product.id),
                      onRemove: () => cart.decrementQuantity(cartItem.product.id),
                      onDelete: () => cart.removeFromCart(cartItem.product.id),
                    );
                  },
                ),
              ),

              // PAYMENT SUMMARY
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow('Items', '${cart.totalItems}'),
                    _buildRow('Subtotal', '₹${cart.totalPrice.toStringAsFixed(2)}'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: isPaymentLoading ? null : () => _processPayment(cart),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isPaymentLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Pay ₹${cart.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CART ITEM CARD
// ─────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final CartItem cartItem;

  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.cartItem,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = cartItem.product;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // PRODUCT IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SupabaseImage(
              imageName: product.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // PRODUCT DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text('₹${product.price}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.remove),
                    ),
                    Text('${cartItem.quantity}'),
                    IconButton(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
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





















