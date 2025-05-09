class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String category;
  final String? categoryId;
  final List<String> images;
  final String? thumbnailImage;
  final bool inStock;
  final int stockQuantity;
  final String? unit;
  final double? weight;
  final Map<String, dynamic>? specifications;
  final bool isFeatured;
  final bool isNew;
  final bool isBestSeller;
  final double? rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.category,
    this.categoryId,
    required this.images,
    this.thumbnailImage,
    required this.inStock,
    required this.stockQuantity,
    this.unit,
    this.weight,
    this.specifications,
    this.isFeatured = false,
    this.isNew = false,
    this.isBestSeller = false,
    this.rating,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: _toDouble(json['price']),
      discountPrice:
          json['discount_price'] != null
              ? _toDouble(json['discount_price'])
              : null,
      category: json['category'] ?? '',
      categoryId: json['category_id']?.toString(),
      images:
          (json['images'] is List && json['images'].isNotEmpty)
              ? List<String>.from(json['images'])
              : [json['thumbnail_image'] ?? ''],
      thumbnailImage: json['thumbnail_image'],
      inStock: json['in_stock'] ?? true,
      stockQuantity: json['stock_quantity'] ?? 0,
      unit: json['unit'],
      weight: json['weight'] != null ? _toDouble(json['weight']) : null,
      specifications: json['specifications'] as Map<String, dynamic>?,
      isFeatured: json['is_featured'] ?? false,
      isNew: json['is_new'] ?? false,
      isBestSeller: json['is_best_seller'] ?? false,
      rating: json['rating'] != null ? _toDouble(json['rating']) : null,
      reviewCount: json['review_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'category': category,
      'category_id': categoryId,
      'images': images,
      'thumbnail_image': thumbnailImage,
      'in_stock': inStock,
      'stock_quantity': stockQuantity,
      'unit': unit,
      'weight': weight,
      'specifications': specifications,
      'is_featured': isFeatured,
      'is_new': isNew,
      'is_best_seller': isBestSeller,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  double get discountPercentage {
    if (hasDiscount) {
      return ((price - discountPrice!) / price * 100).roundToDouble();
    }
    return 0;
  }

  double get finalPrice => hasDiscount ? discountPrice! : price;

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
