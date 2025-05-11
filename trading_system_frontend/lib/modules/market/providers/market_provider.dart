import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/market_manager.dart';
import '../../../services/models/market_models.dart';
import '../../../services/api/websocket_manager.dart';
import '../../../services/models/websocket_models.dart';

// Custom event types for processing WebSocket updates
class TickerUpdateEvent {
  final String symbol;
  final double lastPrice;
  final double priceChange;
  final double priceChangePercent;
  final double? high24h;
  final double? low24h;
  final double? volume24h;
  final double? quoteVolume24h;

  TickerUpdateEvent({
    required this.symbol,
    required this.lastPrice,
    required this.priceChange,
    required this.priceChangePercent,
    this.high24h,
    this.low24h,
    this.volume24h,
    this.quoteVolume24h,
  });
}

class OrderBookUpdateEvent {
  final String symbol;
  final List<List<dynamic>>? bids;
  final List<List<dynamic>>? asks;
  final int? lastUpdateId;

  OrderBookUpdateEvent({
    required this.symbol,
    this.bids,
    this.asks,
    this.lastUpdateId,
  });
}

class KlineUpdateEvent {
  final String symbol;
  final String? interval;
  final int openTime;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final double? volume;
  final double? quoteVolume;
  final int? trades;
  final int? closeTime;

  KlineUpdateEvent({
    required this.symbol,
    this.interval,
    required this.openTime,
    this.open,
    this.high,
    this.low,
    this.close,
    this.volume,
    this.quoteVolume,
    this.trades,
    this.closeTime,
  });
}

class MarketState {
  final List<Symbol> symbols;
  final List<MarketData> marketSummary;
  final String? selectedSymbol;
  final OrderBook? orderBook;
  final List<Kline> klines;
  final bool isLoading;
  final String? error;

  MarketState({
    this.symbols = const [],
    this.marketSummary = const [],
    this.selectedSymbol,
    this.orderBook,
    this.klines = const [],
    this.isLoading = false,
    this.error,
  });

  MarketState copyWith({
    List<Symbol>? symbols,
    List<MarketData>? marketSummary,
    String? selectedSymbol,
    OrderBook? orderBook,
    List<Kline>? klines,
    bool? isLoading,
    String? error,
  }) {
    return MarketState(
      symbols: symbols ?? this.symbols,
      marketSummary: marketSummary ?? this.marketSummary,
      selectedSymbol: selectedSymbol ?? this.selectedSymbol,
      orderBook: orderBook ?? this.orderBook,
      klines: klines ?? this.klines,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Find market data for a specific symbol
  MarketData? getMarketDataForSymbol(String symbol) {
    return marketSummary.isNotEmpty
        ? marketSummary.firstWhere(
            (market) => market.symbol == symbol,
            orElse: () => MarketData(
              id: '',
              symbol: symbol,
              lastPrice: 0,
              priceChange: 0,
              priceChangePercent: 0,
              high24h: 0,
              low24h: 0,
              volume24h: 0,
              quoteVolume24h: 0,
              updatedAt: DateTime.now(),
            ),
          )
        : null;
  }
}

class MarketNotifier extends StateNotifier<MarketState> {
  // Stream subscription for WebSocket messages
  StreamSubscription<WebSocketMessage>? _websocketSubscription;

  MarketNotifier() : super(MarketState()) {
    // Initialize with data
    loadMarketData();

    // Subscribe to WebSocket updates
    _subscribeToMarketUpdates();
  }

  Future<void> loadMarketData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load symbols and market summary in parallel
      final symbolsFuture = MarketManager.getSymbols();
      final marketSummaryFuture = MarketManager.getMarketSummary();

      final symbols = await symbolsFuture;
      final marketSummary = await marketSummaryFuture;

      // If we don't have a selected symbol yet, select the first one
      final selectedSymbol =
          state.selectedSymbol ??
          (symbols.isNotEmpty ? symbols.first.name : null);

      state = state.copyWith(
        symbols: symbols,
        marketSummary: marketSummary,
        selectedSymbol: selectedSymbol,
        isLoading: false,
      );

      // If we have a selected symbol, load its details
      if (selectedSymbol != null) {
        await loadSymbolDetails(selectedSymbol);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadSymbolDetails(String symbol) async {
    try {
      state = state.copyWith(selectedSymbol: symbol);

      // Load order book and klines in parallel
      final orderBookFuture = MarketManager.getOrderBookDepth(symbol);
      final klinesFuture = MarketManager.getKlines(symbol: symbol);

      final orderBook = await orderBookFuture;
      final klines = await klinesFuture;

      state = state.copyWith(orderBook: orderBook, klines: klines);

      // Update WebSocket subscriptions for the new symbol
      _updateWebSocketSubscriptions(symbol);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void _subscribeToMarketUpdates() {
    // Connect to WebSocket server
    WebSocketManager.connect().then((connected) {
      if (connected) {
        // Listen to WebSocket messages
        _websocketSubscription = WebSocketManager.stream.listen((message) {
          if (message is TickerMessage) {
            _handleTickerUpdate(message);
          } else if (message is OrderBookMessage) {
            _handleOrderBookUpdate(message);
          } else if (message is KlineMessage) {
            _handleKlineUpdate(message);
          }
        });
      }
    });
  }

  void _handleTickerUpdate(TickerMessage message) {
    // Create ticker update event
    final event = TickerUpdateEvent(
      symbol: message.symbol ?? '',
      lastPrice: message.lastPrice,
      priceChange: message.priceChange,
      priceChangePercent: message.priceChangePercent,
      high24h: message.highPrice,
      low24h: message.lowPrice,
      volume24h: message.volume,
    );

    // Find and update the corresponding market data
    final updatedMarketSummary = [...state.marketSummary];
    final index = updatedMarketSummary.indexWhere(
      (market) => market.symbol == event.symbol,
    );

    if (index >= 0) {
      // Update existing market data
      final currentMarket = updatedMarketSummary[index];
      updatedMarketSummary[index] = MarketData(
        id: currentMarket.id,
        symbol: currentMarket.symbol,
        lastPrice: event.lastPrice,
        priceChange: event.priceChange,
        priceChangePercent: event.priceChangePercent,
        high24h: event.high24h ?? currentMarket.high24h,
        low24h: event.low24h ?? currentMarket.low24h,
        volume24h: event.volume24h ?? currentMarket.volume24h,
        quoteVolume24h: event.quoteVolume24h ?? currentMarket.quoteVolume24h,
        updatedAt: DateTime.now(),
      );

      state = state.copyWith(marketSummary: updatedMarketSummary);
    }
  }

  void _handleOrderBookUpdate(OrderBookMessage message) {
    final symbol = message.symbol ?? '';

    // Only update if it's for the currently selected symbol
    if (symbol == state.selectedSymbol) {
      final currentOrderBook = state.orderBook;
      if (currentOrderBook != null) {
        // Create order book update event
        final event = OrderBookUpdateEvent(
          symbol: symbol,
          bids: message.bids,
          asks: message.asks,
        );

        // Update with new bids and asks
        state = state.copyWith(
          orderBook: OrderBook(
            symbol: currentOrderBook.symbol,
            bids: event.bids ?? currentOrderBook.bids,
            asks: event.asks ?? currentOrderBook.asks,
            lastUpdateId: event.lastUpdateId ?? currentOrderBook.lastUpdateId,
          ),
        );
      }
    }
  }

  void _handleKlineUpdate(KlineMessage message) {
    final symbol = message.symbol ?? '';

    // Only update if it's for the currently selected symbol
    if (symbol == state.selectedSymbol) {
      // Create kline update event
      final event = KlineUpdateEvent(
        symbol: symbol,
        interval: message.interval,
        openTime: message.openTime,
        open: message.open,
        high: message.high,
        low: message.low,
        close: message.close,
        volume: message.volume,
        trades: message.tradeCount,
        closeTime: message.closeTime,
      );

      final updatedKlines = [...state.klines];
      final index = updatedKlines.indexWhere(
        (kline) =>
            kline.openTime == event.openTime &&
            kline.interval == event.interval,
      );

      if (index >= 0) {
        // Update existing kline
        updatedKlines[index] = Kline(
          id: updatedKlines[index].id,
          symbol: event.symbol,
          interval: event.interval ?? updatedKlines[index].interval,
          openTime: event.openTime,
          open: event.open ?? updatedKlines[index].open,
          high: event.high ?? updatedKlines[index].high,
          low: event.low ?? updatedKlines[index].low,
          close: event.close ?? updatedKlines[index].close,
          volume: event.volume ?? updatedKlines[index].volume,
          quoteVolume: event.quoteVolume ?? updatedKlines[index].quoteVolume,
          trades: event.trades ?? updatedKlines[index].trades,
          closeTime: event.closeTime ?? updatedKlines[index].closeTime,
        );
      } else {
        // Add new kline if not found and we have all required data
        if (event.open != null &&
            event.high != null &&
            event.low != null &&
            event.close != null) {
          updatedKlines.add(
            Kline(
              id: '',
              symbol: event.symbol,
              interval: event.interval ?? '1h',
              openTime: event.openTime,
              open: event.open!,
              high: event.high!,
              low: event.low!,
              close: event.close!,
              volume: event.volume ?? 0,
              quoteVolume: event.quoteVolume ?? 0,
              trades: event.trades ?? 0,
              closeTime:
                  event.closeTime ??
                  (event.openTime + 3600000), // 1 hour later if not provided
            ),
          );
        }
      }

      state = state.copyWith(klines: updatedKlines);
    }
  }

  void _updateWebSocketSubscriptions(String symbol) {
    // Unsubscribe from previous channels
    if (state.selectedSymbol != null && state.selectedSymbol != symbol) {
      WebSocketManager.unsubscribe(
        channels: ['ticker', 'kline', 'depth'],
        symbols: [state.selectedSymbol!],
      );
    }

    // Subscribe to new channels
    WebSocketManager.subscribe(
      channels: ['ticker', 'kline', 'depth'],
      symbols: [symbol],
    );
  }

  @override
  void dispose() {
    // Unsubscribe from WebSocket channels
    if (state.selectedSymbol != null) {
      WebSocketManager.unsubscribe(
        channels: ['ticker', 'kline', 'depth'],
        symbols: [state.selectedSymbol!],
      );
    }

    // Cancel WebSocket subscription
    _websocketSubscription?.cancel();
    super.dispose();
  }
}

final marketProvider = StateNotifierProvider<MarketNotifier, MarketState>((
  ref,
) {
  return MarketNotifier();
});
