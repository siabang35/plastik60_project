import 'package:flutter/foundation.dart' as flutter;
import 'package:plastik60_app/config/constants.dart';
import 'package:plastik60_app/models/product.dart';
import 'package:plastik60_app/models/category.dart';
import 'package:plastik60_app/services/api_service.dart';

class ProductService extends flutter.ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State
  List<Product> _featuredProducts = [];
  List<Product> _newArrivals = [];
  List<Product> _bestSellers = [];
  List<Category> _categories = [];

  // Loading states
  bool _isLoadingFeatured = false;
  bool _isLoadingNew = false;
  bool _isLoadingBestSellers = false;
  bool _isLoadingCategories = false;

  // Getters for products
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get bestSellers => _bestSellers;
  List<Category> get categories => _categories;

  // Getters for loading states
  bool get isLoadingFeatured => _isLoadingFeatured;
  bool get isLoadingNew => _isLoadingNew;
  bool get isLoadingBestSellers => _isLoadingBestSellers;
  bool get isLoadingCategories => _isLoadingCategories;

  // Fetch and set state
  Future<void> fetchFeaturedProducts() async {
    _isLoadingFeatured = true;
    notifyListeners();

    try {
      _featuredProducts = await getFeaturedProducts();
    } catch (e) {
      flutter.debugPrint('Error in fetchFeaturedProducts: $e');
    } finally {
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewProducts() async {
    _isLoadingNew = true;
    notifyListeners();

    try {
      _newArrivals = await getNewArrivals();
    } catch (e) {
      flutter.debugPrint('Error in fetchNewProducts: $e');
    } finally {
      _isLoadingNew = false;
      notifyListeners();
    }
  }

  Future<void> fetchBestSellerProducts() async {
    _isLoadingBestSellers = true;
    notifyListeners();

    try {
      _bestSellers = await getBestSellers();
    } catch (e) {
      flutter.debugPrint('Error in fetchBestSellerProducts: $e');
    } finally {
      _isLoadingBestSellers = false;
      notifyListeners();
    }
  }

  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    notifyListeners();

    try {
      _categories = await getCategories();
    } catch (e) {
      flutter.debugPrint('Error in fetchCategories: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Featured Products
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final response = await _apiService.get(
        AppConstants.featuredProductsEndpoint,
      );
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    } catch (e) {
      flutter.debugPrint('Error fetching featured products: $e');
    }
    return [];
  }

  // New Arrivals
  Future<List<Product>> getNewArrivals() async {
    try {
      final response = await _apiService.get(AppConstants.newProductsEndpoint);
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    } catch (e) {
      flutter.debugPrint('Error fetching new arrivals: $e');
    }
    return [];
  }

  // Best Sellers
  Future<List<Product>> getBestSellers() async {
    try {
      final response = await _apiService.get(
        AppConstants.bestSellerProductsEndpoint,
      );
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    } catch (e) {
      flutter.debugPrint('Error fetching best sellers: $e');
    }
    return [];
  }

  // Get Categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _apiService.get(AppConstants.categoriesEndpoint);
      if (response != null && response['data'] != null) {
        final List<dynamic> data = response['data'] as List;
        return data
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      flutter.debugPrint('Error fetching categories: $e');
    }
    return [];
  }

  // Get All Products (with pagination)
  Future<List<Product>> getAllProducts({int page = 1}) async {
    try {
      final response = await _apiService.get(
        AppConstants.productsEndpoint,
        queryParams: {
          'page': page.toString(),
          'per_page': AppConstants.itemsPerPage.toString(),
        },
      );
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    } catch (e) {
      flutter.debugPrint('Error fetching all products: $e');
    }
    return [];
  }

  // By Category (with pagination)
  Future<List<Product>> getProductsByCategory(
    String categoryId, {
    int page = 1,
  }) async {
    try {
      final response = await _apiService.get(
        AppConstants.productsEndpoint,
        queryParams: {
          'category_id': categoryId,
          'page': page.toString(),
          'per_page': AppConstants.itemsPerPage.toString(),
        },
      );
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    } catch (e) {
      flutter.debugPrint('Error fetching category products: $e');
    }
    return [];
  }

  // Search (with pagination)
  Future<List<Product>> searchProducts(String query, {int page = 1}) async {
    try {
      final response = await _apiService.get(
        AppConstants.searchProductsEndpoint,
        queryParams: {
          'q': query,
          'page': page.toString(),
          'per_page': AppConstants.itemsPerPage.toString(),
        },
      );
      if (response != null && response['data'] != null) {
        return (response['data'] as List)
            .map((e) => Product.fromJson(e))
            .toList();
      }
    } catch (e) {
      flutter.debugPrint('Error searching products: $e');
    }
    return [];
  }

  // Related products
  Future<List<Product>> getRelatedProducts({
    required String categoryId,
    required String productId,
  }) async {
    try {
      final products = await getProductsByCategory(categoryId);
      return products.where((product) => product.id != productId).toList();
    } catch (e) {
      flutter.debugPrint('Error fetching related products: $e');
      return [];
    }
  }

  // Detail
  Future<Product?> getProductById(String productId) async {
    try {
      final response = await _apiService.get(
        '${AppConstants.productsEndpoint}/$productId',
      );
      if (response != null && response['data'] != null) {
        return Product.fromJson(response['data']);
      }
    } catch (e) {
      flutter.debugPrint('Error fetching product detail: $e');
    }
    return null;
  }
}
