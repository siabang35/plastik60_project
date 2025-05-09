import 'package:flutter/material.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/models/product.dart';
import 'package:plastik60_app/services/cart_service.dart';
import 'package:plastik60_app/services/product_service.dart';
import 'package:plastik60_app/services/storage_service.dart';
import 'package:plastik60_app/widgets/common/custom_button.dart';
import 'package:plastik60_app/widgets/product/product_image_slider.dart';
import 'package:plastik60_app/widgets/product/product_quantity_selector.dart';
import 'package:plastik60_app/widgets/product/related_products.dart';
import 'package:plastik60_app/utils/formatters.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  late final CartService _cartService;
  final StorageService _storageService = StorageService();

  Product? _product;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _quantity = 1;
  bool _addingToCart = false;

  @override
  void initState() {
    super.initState();
    _cartService = CartService(_storageService);
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final product = await _productService.getProductById(widget.productId);
      setState(() {
        _product = product;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateQuantity(int newQuantity) {
    setState(() {
      _quantity = newQuantity;
    });
  }

  // This is the async implementation
  Future<void> _handleAddToCart() async {
    if (_product == null) return;

    setState(() {
      _addingToCart = true;
    });

    try {
      final success = await _cartService.addToCart(_product!, _quantity);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_product!.name} added to cart'),
              action: SnackBarAction(
                label: 'VIEW CART',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.cart);
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add to cart: ${_cartService.error}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _addingToCart = false;
        });
      }
    }
  }

  // This is the async implementation
  Future<void> _handleBuyNow() async {
    if (_product == null) return;

    setState(() {
      _addingToCart = true;
    });

    try {
      final success = await _cartService.addToCart(_product!, _quantity);

      if (mounted) {
        setState(() {
          _addingToCart = false;
        });

        if (success) {
          Navigator.pushNamed(context, AppRoutes.checkout);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to proceed to checkout: ${_cartService.error}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addingToCart = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to proceed to checkout: ${e.toString()}'),
          ),
        );
      }
    }
  }

  // Get the add to cart callback based on product state
  VoidCallback? get addToCartCallback {
    if (_product != null && _product!.inStock && _product!.stockQuantity > 0) {
      return () {
        _handleAddToCart();
      };
    }
    return null;
  }

  // Get the buy now callback based on product state
  VoidCallback? get buyNowCallback {
    if (_product != null && _product!.inStock && _product!.stockQuantity > 0) {
      return () {
        _handleBuyNow();
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? 'Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.cart);
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadProduct(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_product == null) {
      return const Center(child: Text('Product not found'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageSlider(images: _product!.images),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _product!.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      Formatters.formatCurrency(_product!.finalPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_product!.hasDiscount)
                      Text(
                        Formatters.formatCurrency(_product!.price),
                        style: const TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    if (_product!.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${_product!.discountPercentage.toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_product!.unit != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Unit: ${_product!.unit}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Quantity:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ProductQuantitySelector(
                      initialValue: _quantity,
                      minValue: 1,
                      maxValue: _product!.stockQuantity,
                      onChanged: _updateQuantity,
                    ),
                    const Spacer(),
                    Text(
                      '${_product!.stockQuantity} available',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _product!.description,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),
                if (_product!.specifications != null &&
                    _product!.specifications!.isNotEmpty) ...[
                  const Text(
                    'Specifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._buildSpecifications(),
                  const SizedBox(height: 24),
                ],
                if (_product!.categoryId != null)
                  RelatedProducts(
                    categoryId: _product!.categoryId!,
                    currentProductId: _product!.id,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpecifications() {
    if (_product!.specifications == null) {
      return [];
    }

    return _product!.specifications!.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                '${entry.key}:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(child: Text(entry.value.toString())),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildBottomBar() {
    if (_product == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Add to Cart',
                isLoading: _addingToCart,
                onPressed: addToCartCallback,
                icon: Icons.shopping_cart,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                text: 'Buy Now',
                onPressed: buyNowCallback,
                backgroundColor: Colors.orange,
                icon: Icons.flash_on,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
