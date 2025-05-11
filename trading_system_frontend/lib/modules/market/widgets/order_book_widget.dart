import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/models/market_models.dart';

class OrderBookWidget extends StatelessWidget {
  final OrderBook orderBook;
  final Symbol symbol;
  final int depth;

  const OrderBookWidget({
    super.key,
    required this.orderBook,
    required this.symbol,
    this.depth = 10,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure we don't exceed the available order book depth
    final maxDepth = depth > 0 ? depth : 10;
    final limitedBids = orderBook.bids.take(maxDepth).toList();
    final limitedAsks = orderBook.asks.take(maxDepth).toList();

    // Format price with correct decimal places
    final priceFormat = NumberFormat.currency(
      symbol: '',
      decimalDigits: symbol.quotePrecision,
    );

    // Format quantity with base asset precision
    final quantityFormat = NumberFormat.currency(
      symbol: '',
      decimalDigits: symbol.baseAssetPrecision,
    );

    // Calculate total volume for calculating percentage bars
    double maxBidVolume = 0;
    double maxAskVolume = 0;

    for (final bid in limitedBids) {
      final volume = bid[0] * bid[1];
      if (volume > maxBidVolume) maxBidVolume = volume;
    }

    for (final ask in limitedAsks) {
      final volume = ask[0] * ask[1];
      if (volume > maxAskVolume) maxAskVolume = volume;
    }

    final maxVolume = maxBidVolume > maxAskVolume ? maxBidVolume : maxAskVolume;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Order Book: ${symbol.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              PopupMenuButton<int>(
                onSelected: (value) {
                  // Callback for depth selection
                },
                icon: const Icon(Icons.filter_list, color: Colors.white70),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 10, child: Text('Depth: 10')),
                  const PopupMenuItem(value: 20, child: Text('Depth: 20')),
                  const PopupMenuItem(value: 50, child: Text('Depth: 50')),
                ],
              ),
            ],
          ),
        ),

        // Column headers
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Price (${symbol.quoteAsset})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Amount (${symbol.baseAsset})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Price (${symbol.quoteAsset})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Amount (${symbol.baseAsset})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Order book body
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bids (left side)
              Expanded(
                child: ListView.builder(
                  itemCount: limitedBids.length,
                  itemBuilder: (context, index) {
                    final bid = limitedBids[index];
                    final price = bid[0].toDouble();
                    final amount = bid[1].toDouble();
                    final total = price * amount;

                    // Calculate percentage for volume bar
                    final volumePercentage = maxVolume > 0
                        ? (total / maxVolume)
                        : 0.0;

                    return Stack(
                      children: [
                        // Volume background
                        Positioned.fill(
                          child: Row(
                            children: [
                              Spacer(),
                              Container(
                                width:
                                    MediaQuery.of(context).size.width *
                                    0.45 *
                                    volumePercentage,
                                color: AppTheme.positiveColor.withOpacity(0.15),
                              ),
                            ],
                          ),
                        ),

                        // Bid data
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  priceFormat.format(price),
                                  style: TextStyle(
                                    color: AppTheme.positiveColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  quantityFormat.format(amount),
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  quantityFormat.format(total),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Asks (right side)
              Expanded(
                child: ListView.builder(
                  itemCount: limitedAsks.length,
                  itemBuilder: (context, index) {
                    final ask = limitedAsks[index];
                    final price = ask[0].toDouble();
                    final amount = ask[1].toDouble();
                    final total = price * amount;

                    // Calculate percentage for volume bar
                    final volumePercentage = maxVolume > 0
                        ? (total / maxVolume)
                        : 0.0;

                    return Stack(
                      children: [
                        // Volume background
                        Positioned.fill(
                          child: Row(
                            children: [
                              Container(
                                width:
                                    MediaQuery.of(context).size.width *
                                    0.45 *
                                    volumePercentage,
                                color: AppTheme.negativeColor.withOpacity(0.15),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),

                        // Ask data
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  priceFormat.format(price),
                                  style: TextStyle(
                                    color: AppTheme.negativeColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  quantityFormat.format(amount),
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  quantityFormat.format(total),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
