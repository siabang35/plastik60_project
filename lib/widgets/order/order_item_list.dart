import 'package:flutter/material.dart';
import 'package:plastik60_app/models/order.dart';
import 'package:plastik60_app/utils/formatters.dart';

class OrderItemList extends StatelessWidget {
  final List<OrderItem> items;

  const OrderItemList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    item.productImage != null && item.productImage!.isNotEmpty
                        ? Image.network(
                          item.productImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                        : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (item.unit != null)
                      Text(
                        'Unit: ${item.unit}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${item.quantity} × ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(item.price),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(item.subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (item.price != item.subtotal / item.quantity)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Disc. applied',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey, size: 24),
      ),
    );
  }
}
