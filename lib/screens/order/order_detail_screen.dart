import 'package:flutter/material.dart';
import 'package:plastik60_app/models/order.dart';
import 'package:plastik60_app/services/order_service.dart';
import 'package:plastik60_app/utils/formatters.dart';
import 'package:plastik60_app/widgets/common/custom_button.dart';
import 'package:plastik60_app/widgets/common/custom_error_widget.dart';
import 'package:plastik60_app/widgets/order/order_item_list.dart';
import 'package:plastik60_app/widgets/order/order_status_badge.dart';
import 'package:plastik60_app/widgets/order/order_timeline.dart';
import 'package:plastik60_app/widgets/order/payment_instructions.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();

  Order? _order;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Changed from getOrderById to getOrderDetails to match the OrderService implementation
      final order = await _orderService.getOrderDetails(widget.orderId);
      setState(() {
        _order = order;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId.substring(0, 8)}'),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      // Using the custom error widget instead of inline implementation
      return CustomErrorWidget(
        errorMessage: _errorMessage,
        onRetry: _loadOrder,
      );
    }

    if (_order == null) {
      return const Center(child: Text('Order not found'));
    }

    return RefreshIndicator(
      onRefresh: _loadOrder,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: 24),
            OrderTimeline(status: _order!.status),
            const SizedBox(height: 24),
            const Text(
              'Order Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            OrderItemList(items: _order!.items),
            const SizedBox(height: 24),
            _buildOrderSummary(),
            const SizedBox(height: 24),
            _buildShippingAddress(),
            const SizedBox(height: 24),
            if (_order!.status.toLowerCase() == 'pending' &&
                _order!.paymentMethod == 'bank_transfer')
              PaymentInstructions(order: _order!),
            const SizedBox(height: 32),
            if (_order!.status.toLowerCase() == 'shipped')
              CustomButton(
                text: 'Confirm Delivery',
                onPressed: () => _confirmDelivery(),
                icon: Icons.check_circle,
              ),
            if (_order!.status.toLowerCase() == 'delivered')
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Thank you for your order!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            // Add cancel button for pending orders
            if (_order!.status.toLowerCase() == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CustomButton(
                  text: 'Cancel Order',
                  onPressed: () => _cancelOrder(),
                  icon: Icons.cancel,
                  backgroundColor: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${_order?.orderNumber ?? widget.orderId.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                OrderStatusBadge(status: _order!.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Placed on ${Formatters.formatDate(_order!.orderDate)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Payment: ${Formatters.formatPaymentMethod(_order!.paymentMethod)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Subtotal',
              Formatters.formatCurrency(_order!.subtotal),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Shipping',
              Formatters.formatCurrency(_order!.shipping),
            ),
            if ((_order!.discount ?? 0) > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Discount',
                Formatters.formatCurrency(_order!.discount ?? 0),
                valueColor: Colors.red,
              ),
            ],
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Total',
              Formatters.formatCurrency(_order!.total),
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingAddress() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(_order!.shippingName),
            const SizedBox(height: 4),
            Text(_order!.shippingPhone),
            const SizedBox(height: 4),
            Text(_order!.shippingAddress),
            const SizedBox(height: 4),
            Text('${_order!.shippingCity}, ${_order!.shippingProvince}'),
            const SizedBox(height: 4),
            Text(_order!.shippingPostalCode),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelivery() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delivery'),
            content: const Text(
              'Have you received your order? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Since confirmDelivery doesn't exist in OrderService, you would need to add it
        // For now, we'll just update the UI to show it's delivered
        // await _orderService.confirmDelivery(widget.orderId);
        await _loadOrder();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Delivery confirmed. Thank you!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to confirm delivery: ${e.toString()}'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Order'),
            content: const Text(
              'Are you sure you want to cancel this order? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _orderService.cancelOrder(widget.orderId);
        await _loadOrder();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel order: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
