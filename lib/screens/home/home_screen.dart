import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/services/cart_service.dart';
import 'package:plastik60_app/services/product_service.dart';
import 'package:plastik60_app/widgets/common/app_drawer.dart';
import 'package:plastik60_app/widgets/common/search_bar.dart';
import 'package:plastik60_app/widgets/home/banner_slider.dart';
import 'package:plastik60_app/widgets/home/category_grid.dart';
import 'package:plastik60_app/widgets/home/product_horizontal_list.dart';
import 'package:plastik60_app/widgets/home/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final productService = Provider.of<ProductService>(
        context,
        listen: false,
      );
      final cartService = Provider.of<CartService>(context, listen: false);
      await Future.wait([
        productService.fetchCategories(),
        productService.fetchFeaturedProducts(),
        productService.fetchNewProducts(),
        productService.fetchBestSellerProducts(),
        cartService.fetchCart(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final cartService = Provider.of<CartService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: ProductSearchDelegate());
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.cart);
                },
              ),
              if (cartService.cart.itemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartService.cart.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SearchBarWidget(
              onTap: () {
                showSearch(context: context, delegate: ProductSearchDelegate());
              },
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner slider
                      const BannerSlider(),

                      const SizedBox(height: 24),

                      // Categories
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SectionHeader(
                          title: 'Categories',
                          onSeeAllPressed: () {
                            // Navigate to all categories
                            Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.productList);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      CategoryGrid(categories: productService.categories),

                      const SizedBox(height: 24),

                      // Featured products
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SectionHeader(
                          title: 'Featured Products',
                          onSeeAllPressed: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.productList,
                              arguments: {
                                'isSearch': false,
                                'title': 'Featured Products',
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProductHorizontalList(
                        products: productService.featuredProducts,
                        onProductTap: (product) {
                          Navigator.of(context).pushNamed(
                            AppRoutes.productDetail,
                            arguments: product.id,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // New arrivals
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SectionHeader(
                          title: 'New Arrivals',
                          onSeeAllPressed: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.productList,
                              arguments: {
                                'isSearch': false,
                                'title': 'New Arrivals',
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProductHorizontalList(
                        products: productService.newArrivals,
                        onProductTap: (product) {
                          Navigator.of(context).pushNamed(
                            AppRoutes.productDetail,
                            arguments: product.id,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Best sellers
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SectionHeader(
                          title: 'Best Sellers',
                          onSeeAllPressed: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.productList,
                              arguments: {
                                'isSearch': false,
                                'title': 'Best Sellers',
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProductHorizontalList(
                        products: productService.bestSellers,
                        onProductTap: (product) {
                          Navigator.of(context).pushNamed(
                            AppRoutes.productDetail,
                            arguments: product.id,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              Navigator.of(context).pushNamed(AppRoutes.productList);
              break;
            case 2:
              Navigator.of(context).pushNamed(AppRoutes.cart);
              break;
            case 3:
              Navigator.of(context).pushNamed(AppRoutes.orderHistory);
              break;
            case 4:
              Navigator.of(context).pushNamed(AppRoutes.profile);
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
