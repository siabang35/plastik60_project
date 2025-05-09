import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:plastik60_app/config/constants.dart';
import 'package:plastik60_app/models/cart.dart';
import 'package:plastik60_app/models/product.dart';
import 'package:plastik60_app/services/api_service.dart';
import 'package:plastik60_app/services/storage_service.dart';

class CartService extends ChangeNotifier {
  final StorageService _storageService;
  final ApiService _apiService;

  Cart _cart = Cart.empty();
  bool _isLoading = false;
  String? _error;

  CartService(this._storageService)
    : _apiService = ApiService(storageService: _storageService) {
    _loadCartFromStorage();
  }

  Cart get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load cart from local storage
  Future<void> _loadCartFromStorage() async {
    final cartJson = await _storageService.getString(AppConstants.cartKey);
    if (cartJson != null) {
      try {
        _cart = Cart.fromJson(json.decode(cartJson));
        notifyListeners();
      } catch (e) {
        // If there's an error parsing the cart, create a new empty cart
        _cart = Cart.empty();
        await _storageService.setString(
          AppConstants.cartKey,
          json.encode(_cart.toJson()),
        );
        notifyListeners();
      }
    }
  }

  // Save cart to local storage
  Future<void> _saveCartToStorage() async {
    await _storageService.setString(
      AppConstants.cartKey,
      json.encode(_cart.toJson()),
    );
  }

  // Fetch cart from API
  Future<bool> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get(AppConstants.cartEndpoint);

      if (response != null && response['data'] != null) {
        _cart = Cart.fromJson(response['data']);
        await _saveCartToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to load cart';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add product to cart
  Future<bool> addToCart(Product product, int quantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First try to add to server
      final response = await _apiService.post(
        AppConstants.addToCartEndpoint,
        data: {'product_id': product.id, 'quantity': quantity},
      );

      if (response != null && response['data'] != null) {
        _cart = Cart.fromJson(response['data']);
        await _saveCartToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // If server fails, add locally
        final existingItemIndex = _cart.items.indexWhere(
          (item) => item.productId == product.id,
        );

        if (existingItemIndex >= 0) {
          // Update existing item
          final existingItem = _cart.items[existingItemIndex];
          final updatedItem = existingItem.copyWith(
            quantity: existingItem.quantity + quantity,
          );

          final updatedItems = List<CartItem>.from(_cart.items);
          updatedItems[existingItemIndex] = updatedItem;

          _cart = _cart.copyWith(items: updatedItems).recalculate();
        } else {
          // Add new item
          final newItem = CartItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            productId: product.id,
            productName: product.name,
            productImage:
                product.thumbnailImage ??
                (product.images.isNotEmpty ? product.images.first : null),
            price: product.price,
            discountPrice: product.discountPrice,
            quantity: quantity,
            unit: product.unit,
          );

          _cart =
              _cart.copyWith(items: [..._cart.items, newItem]).recalculate();
        }

        await _saveCartToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update cart item quantity
  Future<bool> updateCartItemQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      return removeFromCart(itemId);
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First try to update on server
      final response = await _apiService.put(
        AppConstants.updateCartEndpoint,
        data: {'item_id': itemId, 'quantity': quantity},
      );

      if (response != null && response['data'] != null) {
        _cart = Cart.fromJson(response['data']);
        await _saveCartToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // If server fails, update locally
        final itemIndex = _cart.items.indexWhere((item) => item.id == itemId);

        if (itemIndex >= 0) {
          final updatedItem = _cart.items[itemIndex].copyWith(
            quantity: quantity,
          );
          final updatedItems = List<CartItem>.from(_cart.items);
          updatedItems[itemIndex] = updatedItem;

          _cart = _cart.copyWith(items: updatedItems).recalculate();
          await _saveCartToStorage();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Item not found in cart';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First try to remove from server
      final response = await _apiService.delete(
        AppConstants.removeFromCartEndpoint,
        data: {'item_id': itemId},
      );

      if (response != null && response['data'] != null) {
        _cart = Cart.fromJson(response['data']);
        await _saveCartToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // If server fails, remove locally
        final updatedItems =
            _cart.items.where((item) => item.id != itemId).toList();
        _cart = _cart.copyWith(items: updatedItems).recalculate();
        await _saveCartToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // If server fails, remove locally
      final updatedItems =
          _cart.items.where((item) => item.id != itemId).toList();
      _cart = _cart.copyWith(items: updatedItems).recalculate();
      await _saveCartToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // Clear cart
  Future<bool> clearCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to clear on server
      await _apiService.delete(AppConstants.cartEndpoint);

      // Clear locally regardless of server response
      _cart = Cart.empty();
      await _saveCartToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // If server fails, clear locally
      _cart = Cart.empty();
      await _saveCartToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  // Apply coupon code
  Future<bool> applyCoupon(String couponCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '${AppConstants.cartEndpoint}/apply-coupon',
        data: {'coupon_code': couponCode},
      );

      if (response != null && response['data'] != null) {
        _cart = Cart.fromJson(response['data']);
        await _saveCartToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid coupon code';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Remove coupon
  Future<bool> removeCoupon() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.delete(
        '${AppConstants.cartEndpoint}/remove-coupon',
      );

      if (response != null && response['data'] != null) {
        _cart = Cart.fromJson(response['data']);
        await _saveCartToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // If server fails, remove locally
        _cart = _cart.copyWith(couponCode: null, discount: 0).recalculate();
        await _saveCartToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // If server fails, remove locally
      _cart = _cart.copyWith(couponCode: null, discount: 0).recalculate();
      await _saveCartToStorage();
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }
}
