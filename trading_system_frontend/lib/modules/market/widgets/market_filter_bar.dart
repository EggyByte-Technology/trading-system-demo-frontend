import 'package:flutter/material.dart';
import 'package:trading_system_frontend/core/theme/app_theme.dart';

class MarketFilterBar extends StatelessWidget {
  final Function(String) onFilterChanged;
  final Function(String) onSortChanged;
  final String currentFilter;
  final String currentSort;
  final bool isAscending;

  const MarketFilterBar({
    Key? key,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.currentFilter,
    required this.currentSort,
    required this.isAscending,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: AppTheme.cardColor,
      child: Column(
        children: [
          // Filter by asset type
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('ALL', context),
                _buildFilterChip('BTC', context),
                _buildFilterChip('ETH', context),
                _buildFilterChip('USDT', context),
                _buildFilterChip('USDC', context),
                _buildFilterChip('BNB', context),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Sort options
          Row(
            children: [
              _buildSortButton('symbol', 'Symbol', context),
              _buildSortButton('price', 'Price', context),
              _buildSortButton('change', 'Change', context),
              _buildSortButton('volume', 'Volume', context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, BuildContext context) {
    final isSelected = currentFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(filter),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            onFilterChanged(filter);
          }
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.3),
        backgroundColor: AppTheme.surfaceColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSortButton(String sortKey, String label, BuildContext context) {
    final isSelected = currentSort == sortKey;

    return Expanded(
      child: TextButton(
        onPressed: () => onSortChanged(sortKey),
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16.0,
              ),
          ],
        ),
      ),
    );
  }
}
