import 'package:flutter/material.dart';
import 'package:plastik60_app/config/routes.dart';
import 'package:plastik60_app/models/order.dart';
import 'package:plastik60_app/services/order_service.dart';
import 'package:plastik60_app/widgets/common/custom_error_widget.dart';
import 'package:plastik60_app/widgets/common/empty_state_widget.dart';
import 'package:plastik60_app/widgets/order/order_list_item.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final OrderService _orderService;
  late TabController _tabController;

  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _orderService = OrderService();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _filterOrders();
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final orders = await _orderService.fetchOrders();
      setState(() {
        _allOrders = orders;
        _filterOrders();
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterOrders() {
    String? status;
    switch (_tabController.index) {
      case 0: // All
        _filteredOrders = _allOrders;
        return;
      case 1: // Pending
        status = 'pending';
        break;
      case 2: // Processing
        status = 'processing';
        break;
      case 3: // Shipped
        status = 'shipped';
        break;
      case 4: // Completed/Cancelled
        _filteredOrders =
            _allOrders
                .where(
                  (order) =>
                      order.status.toLowerCase() == 'delivered' ||
                      order.status.toLowerCase() == 'cancelled',
                )
                .toList();
        return;
    }

    _filteredOrders =
        _allOrders
            .where((order) => order.status.toLowerCase() == status)
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'All Orders'),
                Tab(text: 'Pending'),
                Tab(text: 'Processing'),
                Tab(text: 'Shipped'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(),
          _buildOrderList(),
          _buildOrderList(),
          _buildOrderList(),
          _buildOrderList(),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return CustomErrorWidget(
        errorMessage: _errorMessage,
        onRetry: _loadOrders,
      );
    }

    if (_filteredOrders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No orders found',
        message: 'You haven\'t placed any orders yet',
        buttonText: 'Shop Now',
        onButtonPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index];
          return OrderListItem(
            order: order,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.orderDetail,
                arguments: order.id,
              );
            },
          );
        },
      ),
    );
  }
}

// Remove the widget definitions from here since they are now in separate files
