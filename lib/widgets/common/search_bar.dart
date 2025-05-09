import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/models/product.dart';
import 'package:plastik60_app/services/product_service.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback onTap;

  const SearchBarWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Search products...',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search products...';

  @override
  TextStyle? get searchFieldStyle =>
      const TextStyle(fontSize: 16, fontWeight: FontWeight.normal);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return _buildSearchHints(context);
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchHints(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildSearchHintItem(context, 'Plastic Bags'),
              _buildSearchHintItem(context, 'Plastic Containers'),
              _buildSearchHintItem(context, 'Plastic Cups'),
              _buildSearchHintItem(context, 'Plastic Bottles'),
              _buildSearchHintItem(context, 'Plastic Wraps'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHintItem(BuildContext context, String hint) {
    return ListTile(
      leading: Icon(Icons.trending_up, color: Colors.grey[600]),
      title: Text(hint),
      onTap: () {
        query = hint;
        showResults(context); // now context is defined
      },
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Please enter a search term'));
    }

    final productService = Provider.of<ProductService>(context, listen: false);
    return FutureBuilder<List<Product>>(
      future: productService.searchProducts(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No products found for "$query"',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        } else {
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductItem(context, product);
            },
          );
        }
      },
    );
  }

  Widget _buildProductItem(BuildContext context, Product product) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          close(context, '');
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.productDetail, arguments: product.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    product.thumbnailImage != null
                        ? Image.network(
                          product.thumbnailImage!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                        : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
              ),
              const SizedBox(width: 12),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.hasDiscount)
                      Row(
                        children: [
                          Text(
                            'Rp ${product.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${product.finalPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.primaryColor,
                      ),
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
