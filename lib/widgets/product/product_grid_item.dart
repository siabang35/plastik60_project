import 'package:flutter/material.dart';
import 'package:plastik60_app/models/product.dart';
import 'package:plastik60_app/services/cart_service.dart';
import 'package:plastik60_app/utils/formatters.dart';
import 'package:plastik60_app/services/storage_service.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product.images.isNotEmpty
                        ? product.images[0]
                        : 'https://via.placeholder.com/300x300?text=No+Image',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, _) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercentage.round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildAddToCartButton(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        Formatters.formatCurrency(product.finalPrice),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (product.discountPrice != null &&
                          product.discountPrice! < product.price)
                        Text(
                          Formatters.formatCurrency(product.price),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (product.rating != null && product.rating! > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      const Spacer(),
                      if (!product.inStock)
                        const Text(
                          'Stok habis',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (product.stockQuantity > 0 &&
                          product.stockQuantity <= 5)
                        Text(
                          'Sisa ${product.stockQuantity}',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _addToCart(context),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.add_shopping_cart, size: 16, color: Colors.black87),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) async {
    try {
      final storageService = StorageService(); // Tambahkan ini
      final cartService = CartService(
        storageService,
      ); // Berikan argumen ke constructor

      final success = await cartService.addToCart(
        product,
        1,
      ); // perhatikan: `product`, bukan `productId`

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} berhasil ditambahkan ke keranjang'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan produk'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan produk: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
