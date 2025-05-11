import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/models/market_models.dart';
import 'package:intl/intl.dart';

class MarketListItem extends StatelessWidget {
  final MarketData market;
  final VoidCallback onTap;

  const MarketListItem({Key? key, required this.market, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPriceUp = market.priceChangePercent >= 0;
    final priceChangeColor = isPriceUp
        ? AppTheme.positiveColor
        : AppTheme.negativeColor;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Symbol and base asset
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vol: ${_formatNumber(market.volume24h)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Price
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(market.lastPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_formatUsdValue(market.lastPrice * market.volume24h)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Price change
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: priceChangeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${isPriceUp ? '+' : ''}${market.priceChangePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: priceChangeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price < 0.001) return price.toStringAsFixed(8);
    if (price < 1) return price.toStringAsFixed(6);
    if (price < 10) return price.toStringAsFixed(4);
    if (price < 1000) return price.toStringAsFixed(2);
    return _formatNumber(price);
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

  String _formatUsdValue(double value) {
    if (value > 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(2)}B';
    }
    if (value > 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }
    if (value > 1000) {
      return '${(value / 1000).toStringAsFixed(2)}K';
    }
    return value.toStringAsFixed(2);
  }
}
