# Plastik60.id Mobile Application Documentation

## Table of Contents

1. [Introduction](#1-introduction)
2. [Project Architecture](#2-project-architecture)
3. [Project Structure](#3-project-structure)
4. [Core Components](#4-core-components)
5. [Screens and Features](#5-screens-and-features)
6. [Services and API Integration](#6-services-and-api-integration)
7. [State Management](#7-state-management)
8. [Models](#8-models)
9. [Utilities](#9-utilities)
10. [Widgets](#10-widgets)
11. [Installation and Setup](#11-installation-and-setup)
12. [Development Guidelines](#12-development-guidelines)
13. [Testing](#13-testing)
14. [Deployment](#14-deployment)
15. [Future Enhancements](#15-future-enhancements)

## 1. Introduction

The Plastik60.id Mobile Application is a comprehensive e-commerce platform designed for both iOS and Android devices. It serves as the mobile counterpart to the Plastik60.id website, allowing users to browse and purchase plastic packaging products, manage their orders, and track deliveries.

### 1.1 Purpose

This application aims to provide a seamless shopping experience for Plastik60.id customers on mobile devices, with features including:

- User authentication and profile management
- Product browsing and searching
- Shopping cart and checkout functionality
- Order history and tracking
- Push notifications for order updates

### 1.2 Target Audience

- Existing Plastik60.id customers
- Businesses and individuals looking for plastic packaging solutions
- Retail and wholesale buyers

### 1.3 Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Laravel (PHP) with MySQL database
- **State Management**: Provider
- **API Communication**: HTTP package
- **Local Storage**: Shared Preferences

## 2. Project Architecture

The application follows a clean architecture approach with a clear separation of concerns:

### 2.1 Architectural Layers

1. **Presentation Layer**: UI components (screens, widgets)
2. **Business Logic Layer**: Services and state management
3. **Data Layer**: Models and API services
4. **Core Layer**: Utilities and helpers

### 2.2 Design Patterns

- **Provider Pattern**: For state management
- **Repository Pattern**: For data access
- **Service Locator Pattern**: For dependency injection
- **Factory Pattern**: For creating model instances

### 2.3 Architectural Flow

\`\`\`
User Interaction → Widgets → Services → API/Local Storage → Models → Services → Widgets
\`\`\`

## 3. Project Structure

The project follows a feature-based organization with clear separation of concerns:


lib/
├── main.dart                  # App entry point
├── app.dart                   # App configuration
├── config/                    # App configuration
│   ├── routes.dart            # App routes
│   ├── theme.dart             # App theme
│   └── constants.dart         # App constants
├── models/                    # Data models
│   ├── user.dart
│   ├── product.dart
│   ├── category.dart
│   ├── cart.dart
│   ├── order.dart
│   └── notification.dart
├── services/                  # API and other services
│   ├── api_service.dart       # Base API service
│   ├── auth_service.dart      # Authentication service
│   ├── product_service.dart   # Product related APIs
│   ├── order_service.dart     # Order related APIs
│   ├── cart_service.dart      # Cart related APIs
│   └── storage_service.dart   # Local storage service
├── utils/                     # Utility functions
│   ├── validators.dart        # Form validators
│   ├── formatters.dart        # Text formatters
│   └── helpers.dart           # Helper functions
├── widgets/                   # Reusable widgets
│   ├── common/                # Common widgets
│   ├── product/               # Product related widgets
│   ├── cart/                  # Cart related widgets
│   └── order/                 # Order related widgets
└── screens/                   # App screens
    ├── splash/                # Splash screen
    ├── onboarding/            # Onboarding screens
    ├── auth/                  # Authentication screens
    ├── home/                  # Home/Dashboard
    ├── product/               # Product screens
    ├── cart/                  # Cart screens
    ├── checkout/              # Checkout screens
    ├── order/                 # Order screens
    ├── profile/               # Profile screens
    └── settings/              # Settings screens
\`\`\`

## 4. Core Components

### 4.1 Main Application (main.dart)

The entry point of the application that initializes services and runs the app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize services
  final storageService = await StorageService().init();
  final authService = AuthService(storageService);
  final productService = ProductService();
  final cartService = CartService(storageService);
  final orderService = OrderService();
  
  // Check if user is already logged in
  await authService.checkAuth();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authService),
        ChangeNotifierProvider(create: (_) => productService),
        ChangeNotifierProvider(create: (_) => cartService),
        ChangeNotifierProvider(create: (_) => orderService),
      ],
      child: const PlastikApp(),
    ),
  );
}
