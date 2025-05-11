import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/models/market_models.dart';

class PriceChart extends StatelessWidget {
  final List<Kline> klines;
  final Symbol symbol;

  const PriceChart({super.key, required this.klines, required this.symbol});

  @override
  Widget build(BuildContext context) {
    if (klines.isEmpty) {
      return const Center(child: Text('No chart data available'));
    }

    // Sort klines by time
    final sortedKlines = [...klines]
      ..sort((a, b) => a.openTime.compareTo(b.openTime));

    // Find min and max values for scaling
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final kline in sortedKlines) {
      if (kline.low < minY) minY = kline.low;
      if (kline.high > maxY) maxY = kline.high;
    }

    // Add padding to min and max
    final yPadding = (maxY - minY) * 0.1;
    minY -= yPadding;
    maxY += yPadding;

    // Format price with correct decimal places
    final priceFormat = NumberFormat.currency(
      symbol: '',
      decimalDigits: symbol.quotePrecision,
    );

    // Format date
    final dateFormat = DateFormat('MM/dd HH:mm');

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: (maxY - minY) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppTheme.cardColor, strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: AppTheme.cardColor, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < sortedKlines.length) {
                  // Show dates at regular intervals
                  if (value.toInt() % (sortedKlines.length ~/ 5) == 0) {
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      sortedKlines[value.toInt()].openTime,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dateFormat.format(date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    priceFormat.format(value),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppTheme.cardColor),
        ),
        minX: 0,
        maxX: sortedKlines.length.toDouble() - 1,
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppTheme.cardColor.withOpacity(0.8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index >= 0 && index < sortedKlines.length) {
                  final kline = sortedKlines[index];
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    kline.openTime,
                  );
                  return LineTooltipItem(
                    '${dateFormat.format(date)}\n'
                    'O: ${priceFormat.format(kline.open)}\n'
                    'H: ${priceFormat.format(kline.high)}\n'
                    'L: ${priceFormat.format(kline.low)}\n'
                    'C: ${priceFormat.format(kline.close)}\n'
                    'Vol: ${NumberFormat.compact().format(kline.volume)}',
                    const TextStyle(color: Colors.white),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(sortedKlines.length, (index) {
              return FlSpot(index.toDouble(), sortedKlines[index].close);
            }),
            isCurved: true,
            curveSmoothness: 0.1,
            color: AppTheme.primaryColor,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
