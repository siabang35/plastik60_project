import 'package:flutter/material.dart';
import 'package:plastik60_app/models/order.dart';
import 'package:plastik60_app/utils/formatters.dart';
import 'package:plastik60_app/widgets/order/order_status_badge.dart';

class OrderListItem extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderListItem({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  OrderStatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Placed on ${Formatters.formatDate(order.orderDate)}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'}',
                  ),
                  const Spacer(),
                  Text(
                    'Total: ${Formatters.formatCurrency(order.total)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (order.items.isNotEmpty)
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: order.items.length > 3 ? 3 : order.items.length,
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child:
                              item.productImage != null &&
                                      item.productImage!.isNotEmpty
                                  ? Image.network(
                                    item.productImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildPlaceholderImage();
                                    },
                                  )
                                  : _buildPlaceholderImage(),
                        ),
                      );
                    },
                  ),
                ),
              if (order.items.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '+ ${order.items.length - 3} more',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 8),
              if (order.status.toLowerCase() == 'pending' ||
                  order.status.toLowerCase() == 'processing')
                OutlinedButton(
                  onPressed: () {
                    // Show cancel order confirmation dialog
                    _showCancelOrderDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  child: const Text('Cancel Order'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
      ),
    );
  }

  void _showCancelOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Order'),
            content: const Text(
              'Are you sure you want to cancel this order? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No, Keep Order'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  // Here you would call the order cancellation service
                  // orderService.cancelOrder(order.id);
                },
                child: const Text('Yes, Cancel Order'),
              ),
            ],
          ),
    );
  }
}
