import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatefulWidget {
  final String? selectedMethod;
  final Function(String) onChanged;
  final Function(String)? onSnapTokenRequested;
  final bool isLoading;

  const PaymentMethodSelector({
    super.key,
    this.selectedMethod,
    required this.onChanged,
    this.onSnapTokenRequested,
    this.isLoading = false,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  String _selectedCategory = 'non_cash';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment category selector
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildCategoryButton(
                  title: 'Non-Cash Payment',
                  category: 'non_cash',
                ),
              ),
              Expanded(
                child: _buildCategoryButton(
                  title: 'Cash Payment',
                  category: 'cash',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Payment methods based on selected category
        if (widget.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_selectedCategory == 'non_cash')
          _buildNonCashPaymentMethods()
        else
          _buildCashPaymentMethods(),
      ],
    );
  }

  Widget _buildCategoryButton({
    required String title,
    required String category,
  }) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        // Reset selected payment method when changing category
        if (widget.selectedMethod != null &&
            ((category == 'cash' &&
                    !widget.selectedMethod!.startsWith('cash_')) ||
                (category == 'non_cash' &&
                    widget.selectedMethod!.startsWith('cash_')))) {
          widget.onChanged('');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNonCashPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Bank Transfer
        _buildPaymentMethodTile(
          value: 'bank_transfer',
          title: 'Bank Transfer',
          subtitle: 'Pay via bank transfer (BCA, BNI, BRI, Mandiri)',
          icon: Icons.account_balance,
          imagePath: 'assets/images/payment/bank_transfer.png',
        ),

        // Credit Card
        _buildPaymentMethodTile(
          value: 'credit_card',
          title: 'Credit Card',
          subtitle: 'Pay with Visa, Mastercard, JCB',
          icon: Icons.credit_card,
          imagePath: 'assets/images/payment/credit_card.png',
        ),

        // E-Wallet
        _buildPaymentMethodTile(
          value: 'gopay',
          title: 'GoPay',
          subtitle: 'Pay with GoPay',
          icon: Icons.account_balance_wallet,
          imagePath: 'assets/images/payment/gopay.png',
        ),

        _buildPaymentMethodTile(
          value: 'shopeepay',
          title: 'ShopeePay',
          subtitle: 'Pay with ShopeePay',
          icon: Icons.account_balance_wallet,
          imagePath: 'assets/images/payment/shopeepay.png',
        ),

        _buildPaymentMethodTile(
          value: 'qris',
          title: 'QRIS',
          subtitle: 'Pay with any QRIS-supported e-wallet',
          icon: Icons.qr_code,
          imagePath: 'assets/images/payment/qris.png',
        ),

        // Convenience Store
        _buildPaymentMethodTile(
          value: 'alfamart',
          title: 'Alfamart',
          subtitle: 'Pay at any Alfamart store',
          icon: Icons.store,
          imagePath: 'assets/images/payment/alfamart.png',
        ),

        _buildPaymentMethodTile(
          value: 'indomaret',
          title: 'Indomaret',
          subtitle: 'Pay at any Indomaret store',
          icon: Icons.store,
          imagePath: 'assets/images/payment/indomaret.png',
        ),

        if (widget.selectedMethod != null &&
            widget.selectedMethod!.isNotEmpty &&
            !widget.selectedMethod!.startsWith('cash_'))
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (widget.onSnapTokenRequested != null) {
                  widget.onSnapTokenRequested!(widget.selectedMethod!);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Continue to Payment',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCashPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cash Payment Options',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Cash on Delivery
        _buildPaymentMethodTile(
          value: 'cash_cod',
          title: 'Cash on Delivery',
          subtitle: 'Pay when you receive the goods',
          icon: Icons.money,
          imagePath: 'assets/images/payment/cod.png',
        ),

        // Cash on Pickup
        _buildPaymentMethodTile(
          value: 'cash_pickup',
          title: 'Cash on Pickup',
          subtitle: 'Pay when you pick up at our store',
          icon: Icons.store,
          imagePath: 'assets/images/payment/store.png',
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    String? imagePath,
  }) {
    final isSelected = widget.selectedMethod == value;
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => widget.onChanged(value),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Radio button
              Radio<String>(
                value: value,
                groupValue: widget.selectedMethod,
                onChanged: (value) => widget.onChanged(value!),
                activeColor: theme.primaryColor,
              ),
              const SizedBox(width: 8),

              // Payment method icon/image
              if (imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset(
                    imagePath,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) =>
                            Icon(icon, size: 32, color: Colors.grey[700]),
                  ),
                )
              else
                Icon(icon, size: 32, color: Colors.grey[700]),
              const SizedBox(width: 16),

              // Payment method details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
