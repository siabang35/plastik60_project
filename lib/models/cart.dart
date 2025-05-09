class CartItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final double? discountPrice;
  final int quantity;
  final String? unit;
  final Map<String, dynamic>? attributes;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    this.discountPrice,
    required this.quantity,
    this.unit,
    this.attributes,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      productName: json['product_name'],
      productImage: json['product_image'],
      price: double.parse(json['price'].toString()),
      discountPrice:
          json['discount_price'] != null
              ? double.parse(json['discount_price'].toString())
              : null,
      quantity: json['quantity'],
      unit: json['unit'],
      attributes: json['attributes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'discount_price': discountPrice,
      'quantity': quantity,
      'unit': unit,
      'attributes': attributes,
    };
  }

  double get itemPrice => discountPrice ?? price;
  double get totalPrice => itemPrice * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? discountPrice,
    int? quantity,
    String? unit,
    Map<String, dynamic>? attributes,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      attributes: attributes ?? this.attributes,
    );
  }
}

class Cart {
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final String? couponCode;
  final double? discount;

  Cart({
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    this.couponCode,
    this.discount,
  });

  factory Cart.empty() {
    return Cart(items: [], subtotal: 0, tax: 0, shipping: 0, total: 0);
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items:
          (json['items'] as List)
              .map((item) => CartItem.fromJson(item))
              .toList(),
      subtotal: double.parse(json['subtotal'].toString()),
      tax: double.parse(json['tax'].toString()),
      shipping: double.parse(json['shipping'].toString()),
      total: double.parse(json['total'].toString()),
      couponCode: json['coupon_code'],
      discount:
          json['discount'] != null
              ? double.parse(json['discount'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'total': total,
      'coupon_code': couponCode,
      'discount': discount,
    };
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Cart copyWith({
    List<CartItem>? items,
    double? subtotal,
    double? tax,
    double? shipping,
    double? total,
    String? couponCode,
    double? discount,
  }) {
    return Cart(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      couponCode: couponCode ?? this.couponCode,
      discount: discount ?? this.discount,
    );
  }

  // Calculate cart totals
  Cart recalculate() {
    final newSubtotal = items.fold(
      0.0,
      (sum, item) => sum + (item.discountPrice ?? item.price) * item.quantity,
    );
    final newTax = newSubtotal * 0.1; // Assuming 10% tax
    final newShipping = items.isEmpty ? 0.0 : 10000.0; // Flat shipping rate
    final newDiscount =
        couponCode != null
            ? newSubtotal * 0.05
            : 0.0; // 5% discount if coupon applied
    final newTotal = newSubtotal + newTax + newShipping - (discount ?? 0);

    return copyWith(
      subtotal: newSubtotal,
      tax: newTax,
      shipping: newShipping,
      total: newTotal,
      discount: newDiscount,
    );
  }
}
