import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/trading_manager.dart';
import '../../../services/models/trading_models.dart';
import '../../../services/api/websocket_manager.dart';
import '../../../services/models/websocket_models.dart';
import 'dart:async';

/// State for the trading module
class TradingState {
  final List<Order> openOrders;
  final List<Order> orderHistory;
  final List<Trade> tradeHistory;
  final String? selectedSymbol;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final int totalOrders;
  final int currentOrderPage;
  final int totalTrades;
  final int currentTradePage;

  TradingState({
    this.openOrders = const [],
    this.orderHistory = const [],
    this.tradeHistory = const [],
    this.selectedSymbol,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.totalOrders = 0,
    this.currentOrderPage = 1,
    this.totalTrades = 0,
    this.currentTradePage = 1,
  });

  TradingState copyWith({
    List<Order>? openOrders,
    List<Order>? orderHistory,
    List<Trade>? tradeHistory,
    String? selectedSymbol,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    int? totalOrders,
    int? currentOrderPage,
    int? totalTrades,
    int? currentTradePage,
  }) {
    return TradingState(
      openOrders: openOrders ?? this.openOrders,
      orderHistory: orderHistory ?? this.orderHistory,
      tradeHistory: tradeHistory ?? this.tradeHistory,
      selectedSymbol: selectedSymbol ?? this.selectedSymbol,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      totalOrders: totalOrders ?? this.totalOrders,
      currentOrderPage: currentOrderPage ?? this.currentOrderPage,
      totalTrades: totalTrades ?? this.totalTrades,
      currentTradePage: currentTradePage ?? this.currentTradePage,
    );
  }
}

/// Notifier for trading state
class TradingNotifier extends StateNotifier<TradingState> {
  StreamSubscription<WebSocketMessage>? _websocketSubscription;

  TradingNotifier() : super(TradingState()) {
    // Subscribe to WebSocket updates
    _subscribeToOrderUpdates();
  }

  /// Set the selected symbol and load its orders
  Future<void> selectSymbol(String symbol) async {
    state = state.copyWith(selectedSymbol: symbol);
    await loadOpenOrders();
    await loadOrderHistory();
    await loadTradeHistory();
  }

  /// Load open orders for the selected symbol
  Future<void> loadOpenOrders() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final openOrders = await TradingManager.getOpenOrders(
        symbol: state.selectedSymbol,
      );

      state = state.copyWith(openOrders: openOrders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load open orders: $e',
      );
    }
  }

  /// Load order history
  Future<void> loadOrderHistory({int page = 1, bool append = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await TradingManager.getOrderHistory(
        symbol: state.selectedSymbol,
        page: page,
        pageSize: 20,
      );

      state = state.copyWith(
        orderHistory: append
            ? [...state.orderHistory, ...result.items]
            : result.items,
        totalOrders: result.total,
        currentOrderPage: page,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load order history: $e',
      );
    }
  }

  /// Load trade history
  Future<void> loadTradeHistory({int page = 1, bool append = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final result = await TradingManager.getTradeHistory(
        symbol: state.selectedSymbol,
        page: page,
        pageSize: 20,
      );

      state = state.copyWith(
        tradeHistory: append
            ? [...state.tradeHistory, ...result.items]
            : result.items,
        totalTrades: result.total,
        currentTradePage: page,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load trade history: $e',
      );
    }
  }

  /// Create a new order
  Future<Order?> createOrder({
    required String symbol,
    required String side,
    required String type,
    required double quantity,
    double? price,
    String? timeInForce,
    double? stopPrice,
  }) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      final order = await TradingManager.createOrder(
        symbol: symbol,
        side: side,
        type: type,
        quantity: quantity,
        price: price,
        timeInForce: timeInForce,
        stopPrice: stopPrice,
      );

      // Refresh open orders
      await loadOpenOrders();

      state = state.copyWith(isSubmitting: false);
      return order;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to create order: $e',
      );
      return null;
    }
  }

  /// Cancel an order
  Future<bool> cancelOrder(String orderId) async {
    try {
      state = state.copyWith(isSubmitting: true, error: null);

      await TradingManager.cancelOrder(orderId);

      // Refresh open orders
      await loadOpenOrders();

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to cancel order: $e',
      );
      return false;
    }
  }

  /// Subscribe to WebSocket order updates
  void _subscribeToOrderUpdates() {
    WebSocketManager.connect().then((connected) {
      if (connected) {
        // Subscribe to user data channel
        WebSocketManager.subscribe(
          channels: ['userData'],
          symbols: state.selectedSymbol != null ? [state.selectedSymbol!] : [],
        );

        // Listen to WebSocket messages
        _websocketSubscription = WebSocketManager.stream.listen((message) {
          if (message is OrderUpdateMessage) {
            _handleOrderUpdate(message);
          } else if (message is BalanceUpdateMessage) {
            // Handle balance updates if needed
          }
        });
      }
    });
  }

  /// Handle order update WebSocket messages
  void _handleOrderUpdate(OrderUpdateMessage message) {
    // Create an order from the message data
    final orderData = message.orderData;

    // Only process if we have valid order data
    if (orderData.isNotEmpty && orderData['symbol'] == state.selectedSymbol) {
      final updatedOrder = Order.fromJson(orderData);

      // Update open orders list based on status
      if (updatedOrder.status == 'FILLED' ||
          updatedOrder.status == 'CANCELED' ||
          updatedOrder.status == 'REJECTED' ||
          updatedOrder.status == 'EXPIRED') {
        // Remove from open orders if it's no longer active
        final newOpenOrders = state.openOrders
            .where((o) => o.id != updatedOrder.id)
            .toList();

        state = state.copyWith(openOrders: newOpenOrders);

        // Refresh order history to include this order
        loadOrderHistory();
      } else {
        // Update or add to open orders
        final existingIndex = state.openOrders.indexWhere(
          (o) => o.id == updatedOrder.id,
        );

        if (existingIndex >= 0) {
          // Update existing order
          final newOpenOrders = [...state.openOrders];
          newOpenOrders[existingIndex] = updatedOrder;
          state = state.copyWith(openOrders: newOpenOrders);
        } else {
          // Add new order
          state = state.copyWith(
            openOrders: [...state.openOrders, updatedOrder],
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _websocketSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for trading state
final tradingProvider = StateNotifierProvider<TradingNotifier, TradingState>((
  ref,
) {
  return TradingNotifier();
});
