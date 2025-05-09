class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }

    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneRegExp = RegExp(r'^\d{10,15}$');
    if (!phoneRegExp.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    if (value.trim().length < 5) {
      return 'Please enter a valid address';
    }

    return null;
  }

  static String? validateProvince(String? value) {
    if (value == null || value.isEmpty) return 'Provinsi wajib diisi';
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'City is required';
    }

    return null;
  }

  static String? validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Postal code is required';
    }

    final postalCodeRegExp = RegExp(r'^\d{5}$');
    if (!postalCodeRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid postal code';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }

    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return 'Please enter a valid number';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }

    return null;
  }
}
