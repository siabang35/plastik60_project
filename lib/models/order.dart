class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String? productImage;
  final double price;
  final int quantity;
  final String? unit;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.price,
    required this.quantity,
    this.unit,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      productName: json['product_name'],
      productImage: json['product_image'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
      unit: json['unit'],
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'subtotal': subtotal,
    };
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String status;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double shipping;
  final double? discount;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final String? couponCode;
  final String? notes;
  final DateTime orderDate;
  final DateTime? shippingDate;
  final DateTime? deliveryDate;

  // Shipping address
  final String shippingName;
  final String shippingPhone;
  final String shippingAddress;
  final String shippingCity;
  final String shippingProvince;
  final String shippingPostalCode;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    this.discount,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    this.couponCode,
    this.notes,
    required this.orderDate,
    this.shippingDate,
    this.deliveryDate,
    required this.shippingName,
    required this.shippingPhone,
    required this.shippingAddress,
    required this.shippingCity,
    required this.shippingProvince,
    required this.shippingPostalCode,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      orderNumber: json['order_number'],
      status: json['status'],
      items:
          (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(),
      subtotal: double.parse(json['subtotal'].toString()),
      tax: double.parse(json['tax'].toString()),
      shipping: double.parse(json['shipping'].toString()),
      discount:
          json['discount'] != null
              ? double.parse(json['discount'].toString())
              : null,
      total: double.parse(json['total'].toString()),
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      couponCode: json['coupon_code'],
      notes: json['notes'],
      orderDate: DateTime.parse(json['order_date']),
      shippingDate:
          json['shipping_date'] != null
              ? DateTime.parse(json['shipping_date'])
              : null,
      deliveryDate:
          json['delivery_date'] != null
              ? DateTime.parse(json['delivery_date'])
              : null,
      shippingName: json['shipping_name'],
      shippingPhone: json['shipping_phone'],
      shippingAddress: json['shipping_address'],
      shippingCity: json['shipping_city'],
      shippingProvince: json['shipping_province'],
      shippingPostalCode: json['shipping_postal_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shipping': shipping,
      'discount': discount,
      'total': total,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'coupon_code': couponCode,
      'notes': notes,
      'order_date': orderDate.toIso8601String(),
      'shipping_date': shippingDate?.toIso8601String(),
      'delivery_date': deliveryDate?.toIso8601String(),
      'shipping_name': shippingName,
      'shipping_phone': shippingPhone,
      'shipping_address': shippingAddress,
      'shipping_city': shippingCity,
      'shipping_province': shippingProvince,
      'shipping_postal_code': shippingPostalCode,
    };
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get formattedOrderDate {
    return '${orderDate.day}/${orderDate.month}/${orderDate.year}';
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FFC107'; // Amber
      case 'processing':
        return '#2196F3'; // Blue
      case 'shipped':
        return '#9C27B0'; // Purple
      case 'delivered':
        return '#4CAF50'; // Green
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#757575'; // Grey
    }
  }
}
