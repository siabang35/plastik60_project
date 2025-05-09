import 'package:flutter/material.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/models/product.dart';
import 'package:plastik60_app/services/product_service.dart';

class RelatedProducts extends StatefulWidget {
  final String categoryId;
  final String currentProductId;

  const RelatedProducts({
    super.key,
    required this.categoryId,
    required this.currentProductId,
  });

  @override
  State<RelatedProducts> createState() => _RelatedProductsState();
}

class _RelatedProductsState extends State<RelatedProducts> {
  final ProductService _productService = ProductService();

  List<Product> _relatedProducts = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadRelatedProducts();
  }

  Future<void> _loadRelatedProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final products = await _productService.getRelatedProducts(
        categoryId: widget.categoryId,
        productId: widget.currentProductId,
      );

      setState(() {
        _relatedProducts = products;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError || _relatedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Products',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _relatedProducts.length,
            itemBuilder: (context, index) {
              final product = _relatedProducts[index];
              return _buildRelatedProductItem(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedProductItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.productDetail,
          arguments: product.id,
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.images.isNotEmpty
                    ? product.images[0]
                    : 'https://via.placeholder.com/140',
                height: 140,
                width: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 140,
                    width: 140,
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
            const SizedBox(height: 8),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
