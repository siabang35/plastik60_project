import 'package:flutter/foundation.dart';
import 'package:plastik60_app/models/order.dart';
import 'package:plastik60_app/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<Order> _orders = [];
  Order? _currentOrder;

  bool _isLoading = false;
  bool _isPlacingOrder = false;
  String? _error;

  List<Order> get orders => _orders;
  Order? get currentOrder => _currentOrder;
  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;
  String? get error => _error;

  /// Fetch all orders
  Future<void> fetchOrders() async {
    _setLoading(true);
    _clearError();

    try {
      _orders = await _orderService.fetchOrders();
    } catch (e) {
      _error = 'Gagal memuat pesanan: $e';
    }

    _setLoading(false);
  }

  /// Fetch order details by ID
  Future<void> getOrderDetails(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      _currentOrder = await _orderService.getOrderDetails(orderId);
    } catch (e) {
      _error = 'Gagal memuat detail pesanan: $e';
    }

    _setLoading(false);
  }

  /// Place a new order
  Future<Order?> placeOrder({
    required String paymentMethod,
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
    required String shippingCity,
    required String shippingProvince,
    required String shippingPostalCode,
    String? notes,
  }) async {
    _isPlacingOrder = true;
    _clearError();
    notifyListeners();

    try {
      final newOrder = await _orderService.placeOrder(
        paymentMethod: paymentMethod,
        shippingName: shippingName,
        shippingPhone: shippingPhone,
        shippingAddress: shippingAddress,
        shippingCity: shippingCity,
        shippingProvince: shippingProvince,
        shippingPostalCode: shippingPostalCode,
        notes: notes,
      );

      _currentOrder = newOrder;
      await fetchOrders(); // Refresh daftar pesanan
      return newOrder;
    } catch (e) {
      _error = 'Gagal melakukan pemesanan: $e';
      return null;
    } finally {
      _isPlacingOrder = false;
      notifyListeners();
    }
  }

  /// Cancel an existing order
  Future<bool> cancelOrder(String orderId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _orderService.cancelOrder(orderId);

      if (success) {
        _orders.removeWhere((order) => order.id == orderId);
        if (_currentOrder?.id == orderId) _currentOrder = null;
        notifyListeners();
        return true;
      } else {
        _error = 'Gagal membatalkan pesanan';
        return false;
      }
    } catch (e) {
      _error = 'Gagal membatalkan pesanan: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }

  /// Set loading flag
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Reset current order
  void resetCurrentOrder() {
    _currentOrder = null;
    notifyListeners();
  }
}
