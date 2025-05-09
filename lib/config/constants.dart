class AppConstants {
  // API URLs
  static const String baseUrl = 'https://api.plastik60.id';
  static const String apiUrl = '$baseUrl/api';

  // API Endpoints
  static const String loginEndpoint = '$apiUrl/auth/login';
  static const String registerEndpoint = '$apiUrl/auth/register';
  static const String forgotPasswordEndpoint = '$apiUrl/auth/forgot-password';
  static const String resetPasswordEndpoint = '$apiUrl/auth/reset-password';
  static const String logoutEndpoint = '$apiUrl/auth/logout';
  static const String userEndpoint = '$apiUrl/user';
  static const String updateProfileEndpoint = '$apiUrl/user/profile';
  static const String changePasswordEndpoint = '$apiUrl/user/change-password';

  static const String categoriesEndpoint = '$apiUrl/categories';
  static const String productsEndpoint = '$apiUrl/products';
  static const String featuredProductsEndpoint = '$apiUrl/products/featured';
  static const String newProductsEndpoint = '$apiUrl/products/new';
  static const String bestSellerProductsEndpoint =
      '$apiUrl/products/best-seller';
  static const String searchProductsEndpoint = '$apiUrl/products/search';

  static const String cartEndpoint = '$apiUrl/cart';
  static const String addToCartEndpoint = '$apiUrl/cart/add';
  static const String updateCartEndpoint = '$apiUrl/cart/update';
  static const String removeFromCartEndpoint = '$apiUrl/cart/remove';

  static const String checkoutEndpoint = '$apiUrl/checkout';
  static const String ordersEndpoint = '$apiUrl/orders';
  static const String orderDetailEndpoint = '$apiUrl/orders/';

  static const String wishlistEndpoint = '$apiUrl/wishlist';
  static const String addToWishlistEndpoint = '$apiUrl/wishlist/add';
  static const String removeFromWishlistEndpoint = '$apiUrl/wishlist/remove';

  static const String notificationsEndpoint = '$apiUrl/notifications';
  static const String markNotificationReadEndpoint =
      '$apiUrl/notifications/read';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_data';
  static const String onboardingKey = 'onboarding_completed';

  // App Settings
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int itemsPerPage = 10;

  // Image Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String logoWhitePath = 'assets/images/logo_white.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';
  static const String noDataImagePath = 'assets/images/no_data.png';
  static const String errorImagePath = 'assets/images/error.png';

  // Onboarding Images
  static const List<String> onboardingImages = [
    'assets/images/onboarding1.png',
    'assets/images/onboarding2.png',
    'assets/images/onboarding3.png',
  ];

  // Onboarding Titles
  static const List<String> onboardingTitles = [
    'Welcome to Plastik60',
    'Explore Our Products',
    'Fast Delivery',
  ];

  // Onboarding Descriptions
  static const List<String> onboardingDescriptions = [
    'Your one-stop shop for all plastic packaging needs',
    'Browse through our wide range of high-quality plastic products',
    'Get your orders delivered quickly to your doorstep',
  ];
}
