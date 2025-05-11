import 'package:flutter/material.dart';
import 'package:trading_system_frontend/core/theme/app_theme.dart';
import 'package:trading_system_frontend/services/models/market_models.dart';

class OrderBookWidget extends StatelessWidget {
  final OrderBook? orderBook;
  final MarketData? marketData;
  final Function(double price)? onSelectPrice;

  const OrderBookWidget({
    Key? key,
    this.orderBook,
    this.marketData,
    this.onSelectPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orderBook == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: AppTheme.surfaceColor,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'Price',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Amount',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Total',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),

        // Order book content
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Asks (sell orders) - displayed in reverse order (highest at top)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      color: AppTheme.surfaceColor,
                      child: const Text(
                        'Sell Orders',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        itemCount: orderBook!.asks.length,
                        itemBuilder: (context, index) {
                          final askPrice = orderBook!.asks[index][0] as double;
                          final askAmount = orderBook!.asks[index][1] as double;
                          final total = askPrice * askAmount;

                          // Calculate depth for visualization
                          double maxDepth = 0;
                          for (var ask in orderBook!.asks) {
                            final amount = ask[1] as double;
                            if (amount > maxDepth) maxDepth = amount;
                          }

                          final depthPercentage = (askAmount / maxDepth) * 100;

                          return InkWell(
                            onTap: () => onSelectPrice?.call(askPrice),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.negativeColor.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                  stops: [
                                    depthPercentage / 100,
                                    depthPercentage / 100,
                                  ],
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      askPrice.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: AppTheme.negativeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      askAmount.toStringAsFixed(4),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      total.toStringAsFixed(2),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Current price divider
              if (marketData != null)
                Container(
                  width: 1,
                  color: Colors.grey[700],
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: marketData!.priceChangePercent >= 0
                              ? AppTheme.positiveColor
                              : AppTheme.negativeColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          marketData!.lastPrice.toStringAsFixed(2),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Bids (buy orders)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      color: AppTheme.surfaceColor,
                      child: const Text(
                        'Buy Orders',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orderBook!.bids.length,
                        itemBuilder: (context, index) {
                          final bidPrice = orderBook!.bids[index][0] as double;
                          final bidAmount = orderBook!.bids[index][1] as double;
                          final total = bidPrice * bidAmount;

                          // Calculate depth for visualization
                          double maxDepth = 0;
                          for (var bid in orderBook!.bids) {
                            final amount = bid[1] as double;
                            if (amount > maxDepth) maxDepth = amount;
                          }

                          final depthPercentage = (bidAmount / maxDepth) * 100;

                          return InkWell(
                            onTap: () => onSelectPrice?.call(bidPrice),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.positiveColor.withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                  stops: [
                                    depthPercentage / 100,
                                    depthPercentage / 100,
                                  ],
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      bidPrice.toStringAsFixed(2),
                                      style: TextStyle(
                                        color: AppTheme.positiveColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      bidAmount.toStringAsFixed(4),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      total.toStringAsFixed(2),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
