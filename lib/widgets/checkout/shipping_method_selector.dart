import 'package:flutter/material.dart';

class ShippingMethodSelector extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onChanged;

  const ShippingMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildShippingMethodTile(
          value: 'regular',
          title: 'Regular Shipping',
          subtitle: 'Delivery in 3-5 days',
          price: 'Rp 15.000',
        ),
        _buildShippingMethodTile(
          value: 'express',
          title: 'Express Shipping',
          subtitle: 'Delivery in 1-2 days',
          price: 'Rp 30.000',
        ),
        _buildShippingMethodTile(
          value: 'same_day',
          title: 'Same Day Delivery',
          subtitle: 'Delivery today (order before 12 PM)',
          price: 'Rp 50.000',
        ),
      ],
    );
  }

  Widget _buildShippingMethodTile({
    required String value,
    required String title,
    required String subtitle,
    required String price,
  }) {
    final isSelected = selectedMethod == value;

    return Card(
      elevation: isSelected ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Text(title),
            const Spacer(),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: Text(subtitle),
        value: value,
        groupValue: selectedMethod,
        onChanged: (value) => onChanged(value!),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
