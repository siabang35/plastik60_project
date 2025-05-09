import 'package:flutter/material.dart';
import 'package:plastik60_app/config/constants.dart';
import 'package:plastik60_app/models/order.dart';
import 'package:plastik60_app/services/api_service.dart';

class OrderService extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  final List<Order> _orders = [];
  List<Order> get orders => _orders;

  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<List<Order>> fetchOrders() async {
    try {
      final response = await _apiService.get(AppConstants.ordersEndpoint);

      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'];
        return data
            .map((item) => Order.fromJson(item))
            .toList(); // Mengembalikan List<Order>
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<Order> getOrderDetails(String orderId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.orderDetailEndpoint}$orderId',
      );

      if (response != null && response['data'] != null) {
        return Order.fromJson(response['data']);
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      throw Exception('Error getting order details: $e');
    }
  }

  Future<Order> placeOrder({
    required String paymentMethod,
    required String shippingName,
    required String shippingPhone,
    required String shippingAddress,
    required String shippingCity,
    required String shippingProvince,
    required String shippingPostalCode,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.checkoutEndpoint,
        data: {
          'payment_method': paymentMethod,
          'shipping_name': shippingName,
          'shipping_phone': shippingPhone,
          'shipping_address': shippingAddress,
          'shipping_city': shippingCity,
          'shipping_province': shippingProvince,
          'shipping_postal_code': shippingPostalCode,
          'notes': notes,
        },
      );

      if (response != null && response['data'] != null) {
        final newOrder = Order.fromJson(response['data']);
        _orders.insert(0, newOrder); // Tambahkan order baru di awal
        notifyListeners();
        return newOrder;
      } else {
        throw Exception('Failed to place order');
      }
    } catch (e) {
      throw Exception('Error placing order: $e');
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      final response = await _apiService.put(
        '${AppConstants.orderDetailEndpoint}$orderId/cancel',
      );

      if (response != null && response['success'] == true) {
        // Update local list
        _orders.removeWhere((order) => order.id == orderId);
        notifyListeners();
        return true;
      } else {
        throw Exception('Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Error cancelling order: $e');
    }
  }
}
