import 'package:flutter/material.dart';
import 'package:trading_system_frontend/core/theme/app_theme.dart';
import 'package:trading_system_frontend/services/models/trading_models.dart';

class OrderHistoryWidget extends StatefulWidget {
  final List<Order> openOrders;
  final List<Order> orderHistory;
  final Function(String orderId) onCancelOrder;

  const OrderHistoryWidget({
    Key? key,
    required this.openOrders,
    required this.orderHistory,
    required this.onCancelOrder,
  }) : super(key: key);

  @override
  State<OrderHistoryWidget> createState() => _OrderHistoryWidgetState();
}

class _OrderHistoryWidgetState extends State<OrderHistoryWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Open Orders'),
            Tab(text: 'Order History'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildOpenOrdersList(), _buildOrderHistoryList()],
          ),
        ),
      ],
    );
  }

  Widget _buildOpenOrdersList() {
    if (widget.openOrders.isEmpty) {
      return const Center(child: Text('No open orders'));
    }

    return ListView.builder(
      itemCount: widget.openOrders.length,
      itemBuilder: (context, index) {
        final order = widget.openOrders[index];
        return _buildOrderItem(order, isOpen: true);
      },
    );
  }

  Widget _buildOrderHistoryList() {
    if (widget.orderHistory.isEmpty) {
      return const Center(child: Text('No order history'));
    }

    return ListView.builder(
      itemCount: widget.orderHistory.length,
      itemBuilder: (context, index) {
        final order = widget.orderHistory[index];
        return _buildOrderItem(order, isOpen: false);
      },
    );
  }

  Widget _buildOrderItem(Order order, {required bool isOpen}) {
    final orderColor = order.side == 'BUY'
        ? AppTheme.positiveColor
        : AppTheme.negativeColor;

    final formattedTime =
        '${order.createdAt.day}/${order.createdAt.month} ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.symbol} ${order.side}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: orderColor,
                  ),
                ),
                Text(formattedTime, style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price: ${order.price.toStringAsFixed(2)}'),
                Text('Amount: ${order.originalQuantity.toStringAsFixed(4)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${order.status}',
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isOpen && order.status != 'FILLED')
                  TextButton(
                    onPressed: () => widget.onCancelOrder(order.id),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.negativeColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'FILLED':
        return AppTheme.positiveColor;
      case 'CANCELLED':
        return AppTheme.negativeColor;
      case 'PARTIALLY_FILLED':
        return Colors.orange;
      case 'REJECTED':
        return AppTheme.negativeColor;
      default:
        return Colors.blue;
    }
  }
}
