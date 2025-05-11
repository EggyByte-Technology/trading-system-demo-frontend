import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trading_system_frontend/core/theme/app_theme.dart';
import 'package:trading_system_frontend/modules/trading/widgets/order_form.dart';
import 'package:trading_system_frontend/modules/trading/widgets/order_book_widget.dart';
import 'package:trading_system_frontend/modules/trading/widgets/order_history_widget.dart';
import 'package:trading_system_frontend/services/api/index.dart';
import 'package:trading_system_frontend/services/models/market_models.dart';
import 'package:trading_system_frontend/services/models/trading_models.dart';
import 'package:trading_system_frontend/services/models/account_models.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen({Key? key}) : super(key: key);

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Symbol> _symbols = [];
  Symbol? _selectedSymbol;
  MarketData? _marketData;
  OrderBook? _orderBook;
  List<Order> _openOrders = [];
  List<Order> _orderHistory = [];
  List<Balance> _balances = [];

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _showSymbolSelector = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Get all symbols
      final symbols = await MarketManager.getSymbols();

      // Get account balances
      final balances = await AccountManager.getBalance();

      setState(() {
        _symbols = symbols;
        _balances = balances;

        // Initialize with BTC-USDT or first available symbol
        _selectedSymbol = symbols.firstWhere(
          (s) => s.name == 'BTC-USDT',
          orElse: () => symbols.first,
        );
        _isLoading = false;
      });

      // Load data for selected symbol
      if (_selectedSymbol != null) {
        _loadSymbolData(_selectedSymbol!.name);
        _loadOrders();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _loadSymbolData(String symbolName) async {
    try {
      final results = await Future.wait([
        MarketManager.getTicker(symbolName),
        MarketManager.getOrderBookDepth(symbolName, limit: 10),
      ]);

      setState(() {
        _marketData = results[0] as MarketData;
        _orderBook = results[1] as OrderBook;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading symbol data: $e')),
        );
      }
    }
  }

  Future<void> _loadOrders() async {
    try {
      final results = await Future.wait([
        TradingManager.getOpenOrders(),
        TradingManager.getOrderHistory(),
      ]);

      setState(() {
        _openOrders = results[0] as List<Order>;
        _orderHistory = results[1] as List<Order>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading orders: $e')));
      }
    }
  }

  Future<void> _refreshData() async {
    if (_selectedSymbol != null) {
      await Future.wait([
        _loadSymbolData(_selectedSymbol!.name),
        _loadOrders(),
      ]);
    }
  }

  void _onSymbolSelected(Symbol symbol) {
    setState(() {
      _selectedSymbol = symbol;
      _marketData = null;
      _orderBook = null;
    });
    _loadSymbolData(symbol.name);
    _showSymbolSelector.value = false;
  }

  Future<void> _placeOrder(
    String type,
    String side,
    double price,
    double quantity,
  ) async {
    if (_selectedSymbol == null) return;

    try {
      await TradingManager.createOrder(
        symbol: _selectedSymbol!.name,
        side: side,
        type: type,
        price: price,
        quantity: quantity,
      );

      // Refresh orders and balances
      await Future.wait([_loadOrders(), _loadBalances()]);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order placed successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    try {
      await TradingManager.cancelOrder(orderId);

      // Refresh orders and balances
      await Future.wait([_loadOrders(), _loadBalances()]);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order cancelled successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
    }
  }

  Future<void> _loadBalances() async {
    try {
      final balances = await AccountManager.getBalance();
      setState(() {
        _balances = balances;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading balances: $e')));
      }
    }
  }

  Balance? _getBalance(String asset) {
    return _balances.firstWhere(
      (b) => b.asset.toLowerCase() == asset.toLowerCase(),
      orElse: () =>
          Balance(asset: asset, free: 0, locked: 0, updatedAt: DateTime.now()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: _buildSymbolSelector(),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Column(
        children: [
          if (_selectedSymbol != null && _marketData != null)
            _buildPriceHeader(),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Order form
                Expanded(
                  flex: 3,
                  child: _selectedSymbol == null
                      ? const Center(child: Text('Select a trading pair'))
                      : OrderForm(
                          symbol: _selectedSymbol!,
                          marketData: _marketData,
                          baseBalance: _getBalance(_selectedSymbol!.baseAsset),
                          quoteBalance: _getBalance(
                            _selectedSymbol!.quoteAsset,
                          ),
                          onPlaceOrder: _placeOrder,
                        ),
                ),

                // Right side - Order book & Order history tabs
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Order Book'),
                          Tab(text: 'Orders'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Order book tab
                            OrderBookWidget(
                              orderBook: _orderBook,
                              marketData: _marketData,
                              onSelectPrice: (price) {
                                // Callback to set price in order form
                              },
                            ),

                            // Orders tab
                            OrderHistoryWidget(
                              openOrders: _openOrders,
                              orderHistory: _orderHistory,
                              onCancelOrder: _cancelOrder,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSelector() {
    return GestureDetector(
      onTap: () {
        _showSymbolSelector.value = !_showSymbolSelector.value;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedSymbol?.name ?? 'Select Symbol',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceHeader() {
    final priceColor = _marketData!.priceChangePercent >= 0
        ? AppTheme.positiveColor
        : AppTheme.negativeColor;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardColor,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatPrice(_marketData!.lastPrice),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: priceColor,
                ),
              ),
              Text(
                '≈ \$${_formatPrice(_marketData!.lastPrice)} USD',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${_marketData!.priceChangePercent >= 0 ? '+' : ''}${_marketData!.priceChangePercent.toStringAsFixed(2)}%',
              style: TextStyle(color: priceColor, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '24h High: ${_formatPrice(_marketData!.high24h)}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '24h Low: ${_formatPrice(_marketData!.low24h)}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '24h Volume: ${_formatNumber(_marketData!.volume24h)} ${_selectedSymbol!.baseAsset}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (_selectedSymbol == null) return price.toString();

    final precision = _selectedSymbol!.quotePrecision;
    return price.toStringAsFixed(precision);
  }

  String _formatNumber(double number) {
    if (number > 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    }
    if (number > 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    }
    if (number > 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toStringAsFixed(2);
  }
}
