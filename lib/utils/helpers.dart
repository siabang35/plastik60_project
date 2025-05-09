import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Helpers {
  // Date and time helpers
  static String formatDateTime(
    DateTime dateTime, {
    String format = 'dd MMM yyyy, HH:mm',
  }) {
    return DateFormat(format).format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // URL helpers
  static Future<void> launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  static Future<void> sendEmail(
    String email, {
    String subject = '',
    String body = '',
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject, 'body': body},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  static Future<void> openMap(double latitude, double longitude) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }

  // Sharing helpers
  static Future<void> shareText(String text, {String subject = ''}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }

  static Future<void> shareFiles(
    List<String> paths, {
    String text = '',
    String subject = '',
  }) async {
    final List<XFile> xFiles = paths.map((path) => XFile(path)).toList();
    await SharePlus.instance.share(
      ShareParams(files: xFiles, text: text, subject: subject),
    );
  }

  static Future<void> shareProduct(
    String productId,
    String productName,
    String productImage,
  ) async {
    try {
      // Download the image
      final response = await http.get(Uri.parse(productImage));
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/product_image.jpg');
      await file.writeAsBytes(response.bodyBytes);

      // Share the product with image
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Check out this product: $productName\n\nhttps://plastik60.id/product/$productId',
          subject: 'Plastik60 - $productName',
        ),
      );
    } catch (e) {
      // Fallback to sharing just the text
      await SharePlus.instance.share(
        ShareParams(
          text:
              'Check out this product: $productName\n\nhttps://plastik60.id/product/$productId',
          subject: 'Plastik60 - $productName',
        ),
      );
    }
  }

  // UI helpers
  static void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  // String helpers
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String pluralize(String word, int count) {
    return count == 1 ? word : '${word}s';
  }

  // Device helpers
  static bool isIOS() => Platform.isIOS;
  static bool isAndroid() => Platform.isAndroid;
}
