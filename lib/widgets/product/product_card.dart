import 'package:flutter/material.dart';
import 'package:plastik60_app/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child:
                      product.thumbnailImage != null
                          ? Image.network(
                            product.thumbnailImage!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  height: 120,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                          : Container(
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        '-${product.discountPercentage.toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (product.isNew)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.hasDiscount) ...[
                    Row(
                      children: [
                        Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rp ${product.discountPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      'Rp ${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (product.rating != null)
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${product.rating}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.reviewCount})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
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
}
