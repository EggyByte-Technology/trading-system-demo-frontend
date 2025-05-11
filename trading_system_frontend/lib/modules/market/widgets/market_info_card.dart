import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/models/market_models.dart';

class MarketInfoCard extends StatelessWidget {
  final Symbol symbol;
  final MarketData marketData;

  const MarketInfoCard({
    super.key,
    required this.symbol,
    required this.marketData,
  });

  @override
  Widget build(BuildContext context) {
    // Format numbers
    final priceFormat = NumberFormat.currency(
      symbol: '',
      decimalDigits: symbol.quotePrecision,
    );

    final volumeFormat = NumberFormat.compact();

    return Card(
      color: AppTheme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Symbol information section
            const Text(
              'Symbol Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow('Pair', '${symbol.baseAsset}/${symbol.quoteAsset}'),
            _buildInfoRow('Name', symbol.name),
            _buildInfoRow('Status', symbol.isActive ? 'Active' : 'Inactive'),
            _buildInfoRow(
              'Base Asset Precision',
              symbol.baseAssetPrecision.toString(),
            ),
            _buildInfoRow(
              'Quote Asset Precision',
              symbol.quotePrecision.toString(),
            ),
            _buildInfoRow('Minimum Order Size', symbol.minOrderSize.toString()),
            _buildInfoRow('Maximum Order Size', symbol.maxOrderSize.toString()),
            _buildInfoRow('Minimum Price', priceFormat.format(symbol.minPrice)),
            _buildInfoRow('Maximum Price', priceFormat.format(symbol.maxPrice)),
            _buildInfoRow(
              'Maker Fee',
              '${(symbol.makerFee * 100).toStringAsFixed(2)}%',
            ),
            _buildInfoRow(
              'Taker Fee',
              '${(symbol.takerFee * 100).toStringAsFixed(2)}%',
            ),

            const Divider(color: Colors.white24, height: 32),

            // Market statistics section
            const Text(
              'Market Statistics (24h)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              'Last Price',
              priceFormat.format(marketData.lastPrice),
            ),
            _buildInfoRow(
              'Price Change',
              priceFormat.format(marketData.priceChange),
              valueColor: marketData.priceChange >= 0
                  ? AppTheme.positiveColor
                  : AppTheme.negativeColor,
            ),
            _buildInfoRow(
              'Price Change %',
              '${marketData.priceChangePercent >= 0 ? '+' : ''}${marketData.priceChangePercent.toStringAsFixed(2)}%',
              valueColor: marketData.priceChangePercent >= 0
                  ? AppTheme.positiveColor
                  : AppTheme.negativeColor,
            ),
            _buildInfoRow('24h High', priceFormat.format(marketData.high24h)),
            _buildInfoRow('24h Low', priceFormat.format(marketData.low24h)),
            _buildInfoRow(
              '24h Volume',
              '${volumeFormat.format(marketData.volume24h)} ${symbol.baseAsset}',
            ),
            _buildInfoRow(
              '24h Quote Volume',
              '${volumeFormat.format(marketData.quoteVolume24h)} ${symbol.quoteAsset}',
            ),
            _buildInfoRow(
              'Last Updated',
              DateFormat('yyyy-MM-dd HH:mm:ss').format(marketData.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
