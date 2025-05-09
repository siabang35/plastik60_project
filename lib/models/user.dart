import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.city,
    this.province,
    this.postalCode,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'],
      city: json['city'],
      province: json['province'],
      postalCode: json['postal_code'],
      profileImage: json['profile_image'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? name,
    String? phone,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? profileImage,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    address,
    city,
    province,
    postalCode,
    profileImage,
    createdAt,
    updatedAt,
  ];
}
