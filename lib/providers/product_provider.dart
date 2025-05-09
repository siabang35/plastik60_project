import 'package:flutter/material.dart';
import 'package:plastik60_app/models/product.dart';
import 'package:plastik60_app/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  List<Product> _featuredProducts = [];
  List<Product> _newArrivals = [];
  List<Product> _bestSellers = [];
  List<Product> _searchResults = [];

  Product? _selectedProduct;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  String? _error;

  int _currentPage = 1;
  String? _currentCategory;
  String? _currentSearchQuery;

  // Getters
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get bestSellers => _bestSellers;
  List<Product> get searchResults => _searchResults;

  Product? get selectedProduct => _selectedProduct;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get error => _error;

  Future<void> loadFeaturedProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService.getFeaturedProducts();
      _featuredProducts = products;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNewArrivals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService.getNewArrivals();
      _newArrivals = products;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBestSellers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService.getBestSellers();
      _bestSellers = products;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProductsByCategory(
    String categoryId, {
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    if (refresh || _currentCategory != categoryId) {
      _currentCategory = categoryId;
      _currentPage = 1;
      _searchResults = [];
      _hasMoreData = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService.getProductsByCategory(
        categoryId,
        page: _currentPage,
      );

      if (refresh || _currentPage == 1) {
        _searchResults = products;
      } else {
        _searchResults.addAll(products);
      }

      _hasMoreData = products.isNotEmpty;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      List<Product> products = [];

      if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
        products = await _productService.searchProducts(
          _currentSearchQuery!,
          page: _currentPage,
        );
      } else if (_currentCategory != null) {
        products = await _productService.getProductsByCategory(
          _currentCategory!,
          page: _currentPage,
        );
      }

      if (products.isNotEmpty) {
        _searchResults.addAll(products);
        _currentPage++;
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query, {bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh || _currentSearchQuery != query) {
      _currentSearchQuery = query;
      _currentCategory = null;
      _currentPage = 1;
      _searchResults = [];
      _hasMoreData = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService.searchProducts(
        query,
        page: _currentPage,
      );

      if (refresh || _currentPage == 1) {
        _searchResults = products;
      } else {
        _searchResults.addAll(products);
      }

      _hasMoreData = products.isNotEmpty;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getProductById(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final product = await _productService.getProductById(productId);
      _selectedProduct = product;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
