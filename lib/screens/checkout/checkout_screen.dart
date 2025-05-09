import 'package:flutter/material.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/models/cart.dart';
import 'package:plastik60_app/services/cart_service.dart';
import 'package:plastik60_app/services/order_service.dart';
import 'package:plastik60_app/services/storage_service.dart';
import 'package:plastik60_app/utils/formatters.dart';
import 'package:plastik60_app/widgets/checkout/address_form.dart';
import 'package:plastik60_app/widgets/checkout/order_summary.dart';
import 'package:plastik60_app/widgets/checkout/payment_method_selector.dart';
import 'package:plastik60_app/widgets/checkout/shipping_method_selector.dart';
import 'package:plastik60_app/widgets/common/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final StorageService _storageService;
  late final CartService _cartService;
  late final OrderService _orderService;

  final _formKey = GlobalKey<FormState>();

  Cart? _cart;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isPlacingOrder = false;

  // Checkout form data
  String _selectedPaymentMethod = 'bank_transfer';
  String _selectedShippingMethod = 'regular';
  String _selectedCourier = 'jne'; // Default value, you can change this

  // Address form data
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController =
      TextEditingController(); // Added province controller
  final _postalCodeController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _storageService = StorageService();
    _cartService = CartService(_storageService);
    _orderService = OrderService();

    _loadCart();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose(); // Dispose province controller
    _postalCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Since fetchCart returns a boolean, we need to get the cart from the service
      final success = await _cartService.fetchCart();

      if (!success) {
        throw Exception(_cartService.error ?? 'Failed to load cart');
      }

      final cartData = _cartService.cart;

      if (cartData.items.isEmpty) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.cart);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
        }
        return;
      }

      setState(() {
        _cart = cartData;
      });
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

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      // Use the placeOrder method from OrderService with the correct parameters
      final order = await _orderService.placeOrder(
        paymentMethod: _selectedPaymentMethod,
        shippingName: _nameController.text,
        shippingPhone: _phoneController.text,
        shippingAddress: _addressController.text,
        shippingCity: _cityController.text,
        shippingProvince: _provinceController.text,
        shippingPostalCode: _postalCodeController.text,
        notes: _notesController.text,
      );

      // Clear the cart after successful order
      await _cartService.clearCart();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.orderDetail,
          (route) => false,
          arguments: order.id,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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

    if (_cart == null) {
      return const Center(child: Text('Unable to load cart data'));
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OrderSummary(cart: _cart!, selectedCourier: _selectedCourier),
          const SizedBox(height: 24),
          const Text(
            'Shipping Address',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Updated AddressForm to include province
          AddressForm(
            nameController: _nameController,
            phoneController: _phoneController,
            addressController: _addressController,
            cityController: _cityController,
            provinceController: _provinceController, // Pass province controller
            postalCodeController: _postalCodeController,
            notesController: _notesController,
          ),
          const SizedBox(height: 24),
          const Text(
            'Shipping Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ShippingMethodSelector(
            selectedMethod: _selectedShippingMethod,
            onChanged: (value) {
              setState(() {
                _selectedShippingMethod = value;
              });
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          PaymentMethodSelector(
            selectedMethod: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_cart == null) {
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
              text: 'Place Order',
              isLoading: _isPlacingOrder,
              onPressed: _placeOrder,
              icon: Icons.check_circle_outline,
            ),
          ],
        ),
      ),
    );
  }
}
