import 'package:flutter/material.dart';
import 'package:plastik60_app/config/constants.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/models/product.dart';
import 'package:plastik60_app/services/product_service.dart';
import 'package:plastik60_app/widgets/common/custom_text_field.dart';
import 'package:plastik60_app/widgets/product/product_grid_item.dart';

class ProductListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final bool isSearch;
  final String? searchQuery;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.isSearch = false,
    this.searchQuery,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  final _searchController = TextEditingController();

  List<Product> _products = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _page = 1;
  bool _hasMoreData = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.isSearch && widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    }
    _loadProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_hasMoreData && !_isLoading) {
          _loadMoreProducts();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _page = 1;
    });

    try {
      List<Product> products;
      if (widget.isSearch) {
        products = await _productService.searchProducts(_searchController.text);
      } else if (widget.categoryId != null) {
        products = await _productService.getProductsByCategory(
          widget.categoryId!,
        );
      } else {
        products = await _productService.getAllProducts();
      }

      setState(() {
        _products = products;
        _hasMoreData = products.length >= AppConstants.itemsPerPage;
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

  Future<void> _loadMoreProducts() async {
    if (!_hasMoreData || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _page + 1;
      List<Product> moreProducts;

      if (widget.isSearch) {
        moreProducts = await _productService.searchProducts(
          _searchController.text,
          page: nextPage,
        );
      } else if (widget.categoryId != null) {
        moreProducts = await _productService.getProductsByCategory(
          widget.categoryId!,
          page: nextPage,
        );
      } else {
        moreProducts = await _productService.getAllProducts(page: nextPage);
      }

      if (moreProducts.isNotEmpty) {
        setState(() {
          _products.addAll(moreProducts);
          _page = nextPage;
          _hasMoreData = moreProducts.length >= AppConstants.itemsPerPage;
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load more products: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      Navigator.pushNamed(
        context,
        AppRoutes.productList,
        arguments: {'isSearch': true, 'searchQuery': query},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenTitle =
        widget.categoryName ??
        (widget.isSearch ? 'Search Results' : 'All Products');

    return Scaffold(
      appBar: AppBar(title: Text(screenTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController,
              labelText: 'Search products',
              prefixIcon: Icons.search,
              onSubmitted: _onSearch,
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          if (widget.isSearch) {
                            Navigator.pop(context);
                          }
                        },
                      )
                      : null,
            ),
          ),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    if (_isLoading && _products.isEmpty) {
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
              onPressed: _loadProducts,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text('No products found', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _products.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final product = _products[index];
          return ProductGridItem(
            product: product,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.productDetail,
                arguments: product.id,
              );
            },
          );
        },
      ),
    );
  }
}
