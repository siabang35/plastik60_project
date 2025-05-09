import 'package:flutter/material.dart';
import 'package:plastik60_app/models/cart.dart';
import 'package:plastik60_app/utils/formatters.dart';
import 'package:plastik60_app/widgets/product/product_quantity_selector.dart';

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Get the actual price (discount price if available, otherwise regular price)
    final actualPrice = cartItem.discountPrice ?? cartItem.price;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartItem.productImage != null &&
                        cartItem.productImage!.isNotEmpty
                    ? cartItem.productImage!
                    : 'https://via.placeholder.com/80',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
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
                  // Product Name
                  Text(
                    cartItem.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Product Attributes (if any)
                  if (cartItem.attributes != null &&
                      cartItem.attributes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _formatAttributes(cartItem.attributes!),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),

                  // Price Information
                  Row(
                    children: [
                      Text(
                        Formatters.formatCurrency(actualPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Show original price if there's a discount
                      if (cartItem.discountPrice != null)
                        Text(
                          Formatters.formatCurrency(cartItem.price),
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),

                  // Unit information if available
                  if (cartItem.unit != null && cartItem.unit!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'Per ${cartItem.unit}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Quantity Selector and Remove Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ProductQuantitySelector(
                        initialValue: cartItem.quantity,
                        minValue: 1,
                        maxValue:
                            999, // Since we don't have stock information in CartItem
                        onChanged: onQuantityChanged,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: onRemove,
                        tooltip: 'Remove',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Total Price
                  Text(
                    'Total: ${Formatters.formatCurrency(actualPrice * cartItem.quantity)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format attributes
  String _formatAttributes(Map<String, dynamic> attributes) {
    return attributes.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join(', ');
  }
}
