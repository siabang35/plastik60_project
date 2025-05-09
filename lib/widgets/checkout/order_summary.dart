import 'package:flutter/material.dart';
import 'package:plastik60_app/models/cart.dart';
import 'package:plastik60_app/utils/formatters.dart';

class OrderSummary extends StatelessWidget {
  final Cart cart;
  final String selectedCourier; // Tambahan: untuk estimasi pengiriman

  const OrderSummary({
    super.key,
    required this.cart,
    required this.selectedCourier,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                       child: Image.network(
                      (item.productImage?.isNotEmpty ?? false)
                      ? item.productImage!
                      : 'https://via.placeholder.com/40',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 24,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} x ${Formatters.formatCurrency(item.price)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(item.price * item.quantity),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 32),
            _buildSummaryRow(
              'Subtotal',
              Formatters.formatCurrency(cart.subtotal),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Ongkir (${selectedCourier.toUpperCase()})',
              'Diitung selanjutnya',
            ),
            const SizedBox(height: 8),
            Text(
              'Estimasi Tiba: ${_estimateDeliveryTime(selectedCourier)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if ((cart.discount ?? 0) > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Diskon',
                '- ${Formatters.formatCurrency(cart.discount ?? 0)}',
                valueColor: Colors.red,
              ),
            ],
            const Divider(height: 32),
            _buildSummaryRow(
              'Total',
              Formatters.formatCurrency(cart.total),
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

  String _estimateDeliveryTime(String courier) {
    final now = DateTime.now();
    switch (courier.toLowerCase()) {
      case 'jne':
        return _formatEstimate(now.add(const Duration(days: 2)));
      case 'gosend':
        return 'Hari yang sama (instan)';
      case 'wahana':
        return _formatEstimate(now.add(const Duration(days: 3)));
      case 'j&t':
        return _formatEstimate(now.add(const Duration(days: 1)));
      default:
        return 'Tidak diketahui';
    }
  }

  String _formatEstimate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
