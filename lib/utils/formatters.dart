import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Formatters {
  // Format currency
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format date
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  // Format date and time
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm');
    return formatter.format(date);
  }

  // Format payment method name
  static String formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'credit_card':
        return 'Credit Card';
      case 'paypal':
        return 'PayPal';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return method[0].toUpperCase() + method.substring(1); // Capitalize
    }
  }

  // Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Format based on length
    if (digitsOnly.length <= 4) {
      return digitsOnly;
    } else if (digitsOnly.length <= 7) {
      return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4)}';
    } else if (digitsOnly.length <= 10) {
      return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    } else {
      return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7, 10)}-${digitsOnly.substring(10)}';
    }
  }
}

// Input formatters
class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 15 digits
    if (digitsOnly.length > 15) {
      return oldValue;
    }

    return TextEditingValue(
      text: Formatters.formatPhoneNumber(digitsOnly),
      selection: TextSelection.collapsed(
        offset: Formatters.formatPhoneNumber(digitsOnly).length,
      ),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only allow digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final number = int.parse(digitsOnly);
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedValue = formatter.format(number);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
