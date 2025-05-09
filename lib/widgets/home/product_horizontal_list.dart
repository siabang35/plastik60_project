import 'package:flutter/material.dart';
import 'package:plastik60_app/models/product.dart';
import 'package:plastik60_app/widgets/product/product_card.dart';

class ProductHorizontalList extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;

  const ProductHorizontalList({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No products available')),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 160,
              child: ProductCard(
                product: products[index],
                onTap: () => onProductTap(products[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
