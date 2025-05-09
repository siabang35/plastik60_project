import 'package:flutter/material.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/models/cart.dart';
import 'package:plastik60_app/services/cart_service.dart';
import 'package:plastik60_app/utils/formatters.dart';
import 'package:plastik60_app/widgets/cart/cart_item_card.dart';
import 'package:plastik60_app/widgets/common/custom_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final CartService _cartService;

  Cart? _cart;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Fix 4: Handle the case where fetchCart might return a boolean
      final result = await _cartService.fetchCart();

      // Check if the result is a Cart object
      if (result is Cart) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      } else {
        // If it's a boolean, we need to handle it differently
        // This is a workaround - you might need to adjust based on your actual implementation
        if (result == true) {
          // If true, maybe we need to fetch the cart again or use a different method
          // For now, let's just set an empty cart
          setState(() {
            _cart = Cart.empty();
          });
        } else {
          throw Exception('Failed to load cart');
        }
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fix 2 & 3: Update the method to use the correct parameter names
  Future<void> _updateCartItem(String itemId, int quantity) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Use the correct method name and parameter names
      await _cartService.updateCartItemQuantity(
        itemId, // gunakan ID item dalam cart, bukan productId
        quantity,
      );
      await _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update cart: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _removeCartItem(String itemId) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await _cartService.removeFromCart(itemId);
      await _loadCart();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Item removed from cart')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          if (_cart != null && _cart!.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearCartDialog(),
              tooltip: 'Clear Cart',
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCart,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_cart == null || _cart!.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text('Your cart is empty', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              },
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadCart,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cart!.items.length,
            itemBuilder: (context, index) {
              final item = _cart!.items[index];
              return CartItemCard(
                cartItem: item,
                onQuantityChanged: (quantity) {
                  // Use productId instead of id
                  _updateCartItem(item.productId, quantity);
                },
                onRemove: () {
                  // Use productId instead of id
                  _removeCartItem(item.productId);
                },
              );
            },
          ),
        ),
        if (_isUpdating)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    if (_cart == null || _cart!.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display coupon code if available
            if (_cart!.couponCode != null && _cart!.couponCode!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.discount_outlined,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Coupon: ${_cart!.couponCode}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                    Text(
                      '- ${Formatters.formatCurrency(_cart!.discount ?? 0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:', style: TextStyle(fontSize: 16)),
                Text(
                  Formatters.formatCurrency(_cart!.subtotal),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Display tax if applicable
            if (_cart!.tax > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax:', style: TextStyle(fontSize: 14)),
                    Text(
                      Formatters.formatCurrency(_cart!.tax),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Display shipping if applicable
            if (_cart!.shipping > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Shipping:', style: TextStyle(fontSize: 14)),
                    Text(
                      Formatters.formatCurrency(_cart!.shipping),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  Formatters.formatCurrency(_cart!.total),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Proceed to Checkout (${_cart!.itemCount} items)',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.checkout);
              },
              icon: Icons.shopping_bag_outlined,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cart'),
            content: const Text(
              'Are you sure you want to remove all items from your cart?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    _isUpdating = true;
                  });

                  try {
                    await _cartService.clearCart();
                    await _loadCart();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cart cleared')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to clear cart: ${e.toString()}',
                          ),
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isUpdating = false;
                      });
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }
}
