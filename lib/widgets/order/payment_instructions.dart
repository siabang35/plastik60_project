import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plastik60_app/models/order.dart';
import 'package:plastik60_app/utils/formatters.dart';

class PaymentInstructions extends StatelessWidget {
  final Order order;

  const PaymentInstructions({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Instructions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please transfer the total amount to the following bank account:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildBankDetails(context),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildAmountDetails(context),
            const SizedBox(height: 16),
            const Text(
              'Please include your Order Number in the transfer description.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order will be processed once we verify your payment.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetails(BuildContext context) {
    return Column(
      children: [
        _buildDetailRow(
          context,
          label: 'Bank',
          value: 'Bank Central Asia (BCA)',
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          label: 'Account Number',
          value: '1234567890',
          canCopy: true,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          label: 'Account Name',
          value: 'PT Plastik60 Indonesia',
        ),
      ],
    );
  }

  Widget _buildAmountDetails(BuildContext context) {
    return Column(
      children: [
        _buildDetailRow(
          context,
          label: 'Amount',
          value: Formatters.formatCurrency(order.total),
          valueStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green,
          ),
          canCopy: true,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          label: 'Order Number',
          value: order.orderNumber,
          canCopy: true,
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    TextStyle? valueStyle,
    bool canCopy = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: Text(value, style: valueStyle)),
        if (canCopy)
          IconButton(
            icon: const Icon(Icons.copy, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
      ],
    );
  }
}
