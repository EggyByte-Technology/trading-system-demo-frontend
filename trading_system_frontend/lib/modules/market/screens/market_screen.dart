import 'package:flutter/material.dart';
import 'package:trading_system_frontend/core/theme/app_theme.dart';
import 'package:trading_system_frontend/modules/market/screens/market_detail_screen.dart';
import 'package:trading_system_frontend/modules/market/widgets/market_filter_bar.dart';
import 'package:trading_system_frontend/modules/market/widgets/market_list_item.dart';
import 'package:trading_system_frontend/services/api/index.dart';
import 'package:trading_system_frontend/services/models/market_models.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({Key? key}) : super(key: key);

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  bool _isLoading = true;
  List<MarketData> _marketSummaries = [];
  String _filterType = 'ALL';
  String _sortBy = 'volume';
  bool _sortAscending = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMarketData();
  }

  Future<void> _loadMarketData() async {
    setState(() => _isLoading = true);
    try {
      final summaries = await MarketManager.getMarketSummary();

      setState(() {
        _marketSummaries = summaries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading market data: $e')),
        );
      }
    }
  }

  void _onFilterChanged(String filterType) {
    setState(() {
      _filterType = filterType;
    });
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
        _sortAscending = false;
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<MarketData> get _filteredAndSortedMarkets {
    // First filter by type
    var filtered = _marketSummaries.where((market) {
      if (_filterType == 'ALL') return true;

      final parts = market.symbol.split('-');
      if (parts.length != 2) return false;

      final baseAsset = parts[0];
      return baseAsset == _filterType;
    }).toList();

    // Then filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (market) => market.symbol.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    // Sort the filtered list
    filtered.sort((a, b) {
      dynamic aValue, bValue;

      switch (_sortBy) {
        case 'symbol':
          aValue = a.symbol;
          bValue = b.symbol;
          break;
        case 'price':
          aValue = a.lastPrice;
          bValue = b.lastPrice;
          break;
        case 'change':
          aValue = a.priceChangePercent;
          bValue = b.priceChangePercent;
          break;
        case 'volume':
        default:
          aValue = a.volume24h;
          bValue = b.volume24h;
          break;
      }

      var comparison = 0;
      if (aValue is String && bValue is String) {
        comparison = aValue.compareTo(bValue);
      } else if (aValue is num && bValue is num) {
        comparison = aValue.compareTo(bValue);
      }

      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Market',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadMarketData,
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: MarketSearchDelegate(
                        marketSummaries: _marketSummaries,
                        onSelect: (MarketData market) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MarketDetailScreen(symbol: market.symbol),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          MarketFilterBar(
            onFilterChanged: _onFilterChanged,
            onSortChanged: _onSortChanged,
            currentFilter: _filterType,
            currentSort: _sortBy,
            isAscending: _sortAscending,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAndSortedMarkets.isEmpty
                ? const Center(child: Text('No markets found'))
                : RefreshIndicator(
                    onRefresh: _loadMarketData,
                    child: ListView.builder(
                      itemCount: _filteredAndSortedMarkets.length,
                      itemBuilder: (context, index) {
                        final market = _filteredAndSortedMarkets[index];
                        return MarketListItem(
                          market: market,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MarketDetailScreen(symbol: market.symbol),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class MarketSearchDelegate extends SearchDelegate<MarketData> {
  final List<MarketData> marketSummaries;
  final Function(MarketData) onSelect;

  MarketSearchDelegate({required this.marketSummaries, required this.onSelect});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, marketSummaries.first);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = marketSummaries
        .where(
          (market) => market.symbol.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final market = results[index];
        return ListTile(
          title: Text(market.symbol),
          subtitle: Text('\$${market.lastPrice.toStringAsFixed(2)}'),
          trailing: Text(
            '${market.priceChangePercent >= 0 ? '+' : ''}${market.priceChangePercent.toStringAsFixed(2)}%',
            style: TextStyle(
              color: market.priceChangePercent >= 0
                  ? AppTheme.positiveColor
                  : AppTheme.negativeColor,
            ),
          ),
          onTap: () {
            onSelect(market);
            close(context, market);
          },
        );
      },
    );
  }
}
