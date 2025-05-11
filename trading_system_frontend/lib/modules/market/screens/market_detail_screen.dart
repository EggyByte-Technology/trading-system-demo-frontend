import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/market_provider.dart';
import '../widgets/price_chart.dart';
import '../widgets/order_book_widget.dart';
import '../widgets/market_info_card.dart';
import '../../trading/screens/trading_screen.dart';
import '../../../services/api/index.dart';
import '../../../services/models/market_models.dart';

class MarketDetailScreen extends ConsumerStatefulWidget {
  final String symbol;

  const MarketDetailScreen({Key? key, required this.symbol}) : super(key: key);

  @override
  ConsumerState<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends ConsumerState<MarketDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  MarketData? _marketData;
  Symbol? _symbolInfo;
  OrderBook? _orderBook;
  List<Kline> _klines = [];
  String _selectedInterval = '1h';
  final List<String> _intervals = [
    '1m',
    '5m',
    '15m',
    '30m',
    '1h',
    '4h',
    '1d',
    '1w',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMarketDetails();
  }

  Future<void> _loadMarketDetails() async {
    setState(() => _isLoading = true);
    try {
      // Load symbol details, market data, order book, and klines in parallel
      final results = await Future.wait([
        MarketManager.getTicker(widget.symbol),
        MarketManager.getSymbols().then(
          (symbols) => symbols.firstWhere(
            (s) => s.name == widget.symbol,
            orElse: () => symbols.first,
          ),
        ),
        MarketManager.getOrderBookDepth(widget.symbol),
        MarketManager.getKlines(
          symbol: widget.symbol,
          interval: _selectedInterval,
        ),
      ]);

      setState(() {
        _marketData = results[0] as MarketData;
        _symbolInfo = results[1] as Symbol;
        _orderBook = results[2] as OrderBook;
        _klines = results[3] as List<Kline>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading market details: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadMarketDetails();
  }

  void _changeInterval(String interval) {
    setState(() {
      _selectedInterval = interval;
    });
    _loadKlines();
  }

  Future<void> _loadKlines() async {
    try {
      final klines = await MarketManager.getKlines(
        symbol: widget.symbol,
        interval: _selectedInterval,
      );

      setState(() {
        _klines = klines;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading chart data: $e')));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _marketData == null || _symbolInfo == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(widget.symbol),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dashboard'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final priceFormat = NumberFormat.currency(
      symbol: '',
      decimalDigits: _symbolInfo!.quotePrecision,
    );

    final priceColor = _marketData!.priceChangePercent >= 0
        ? AppTheme.positiveColor
        : AppTheme.negativeColor;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(widget.symbol),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: Column(
        children: [
          // Price and change info
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.cardColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceFormat.format(_marketData!.lastPrice),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: priceColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${_marketData!.priceChangePercent >= 0 ? '+' : ''}${_marketData!.priceChangePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: priceColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${priceFormat.format(_marketData!.priceChange)})',
                          style: TextStyle(color: priceColor),
                        ),
                      ],
                    ),
                  ],
                ),

                // Trade button
                ElevatedButton(
                  onPressed: () {
                    context.go('/trading');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Trade'),
                ),
              ],
            ),
          ),

          // Tab bar for chart, order book, and info
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Chart'),
              Tab(text: 'Order Book'),
              Tab(text: 'Information'),
            ],
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppTheme.primaryColor,
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Chart tab
                Column(
                  children: [
                    // Interval selector
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _intervals.map((interval) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                label: Text(interval),
                                selected: _selectedInterval == interval,
                                onSelected: (selected) {
                                  if (selected) {
                                    _changeInterval(interval);
                                  }
                                },
                                selectedColor: AppTheme.primaryColor
                                    .withOpacity(0.3),
                                backgroundColor: AppTheme.cardColor,
                                labelStyle: TextStyle(
                                  color: _selectedInterval == interval
                                      ? AppTheme.primaryColor
                                      : Colors.white70,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Price chart
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _klines.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : PriceChart(klines: _klines, symbol: _symbolInfo!),
                      ),
                    ),
                  ],
                ),

                // Order book tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _orderBook == null
                      ? const Center(child: CircularProgressIndicator())
                      : OrderBookWidget(
                          orderBook: _orderBook!,
                          symbol: _symbolInfo!,
                        ),
                ),

                // Information tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: MarketInfoCard(
                    symbol: _symbolInfo!,
                    marketData: _marketData!,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
