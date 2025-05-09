class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String? image;
  final String? actionType;
  final String? actionId;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.image,
    this.actionType,
    this.actionId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title'],
      message: json['message'],
      type: json['type'],
      isRead: json['is_read'] ?? false,
      image: json['image'],
      actionType: json['action_type'],
      actionId: json['action_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'image': image,
      'action_type': actionType,
      'action_id': actionId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    String? image,
    String? actionType,
    String? actionId,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      image: image ?? this.image,
      actionType: actionType ?? this.actionType,
      actionId: actionId ?? this.actionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String get iconData {
    switch (type.toLowerCase()) {
      case 'order':
        return 'shopping_bag';
      case 'payment':
        return 'payment';
      case 'shipping':
        return 'local_shipping';
      case 'promotion':
        return 'local_offer';
      case 'system':
        return 'info';
      default:
        return 'notifications';
    }
  }
}
