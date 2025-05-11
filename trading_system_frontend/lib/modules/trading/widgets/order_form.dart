import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trading_system_frontend/core/theme/app_theme.dart';
import 'package:trading_system_frontend/services/models/market_models.dart';
import 'package:trading_system_frontend/services/models/account_models.dart';

class OrderForm extends StatefulWidget {
  final Symbol symbol;
  final MarketData? marketData;
  final Balance? baseBalance;
  final Balance? quoteBalance;
  final Function(String type, String side, double price, double quantity)
  onPlaceOrder;

  const OrderForm({
    Key? key,
    required this.symbol,
    this.marketData,
    this.baseBalance,
    this.quoteBalance,
    required this.onPlaceOrder,
  }) : super(key: key);

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  String _selectedSide = 'BUY';
  String _selectedType = 'LIMIT';

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _updatePriceFromMarket();
  }

  @override
  void didUpdateWidget(OrderForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.marketData?.lastPrice != widget.marketData?.lastPrice) {
      _updatePriceFromMarket();
    }
  }

  void _updatePriceFromMarket() {
    if (widget.marketData != null) {
      _priceController.text = widget.marketData!.lastPrice.toStringAsFixed(
        widget.symbol.quotePrecision,
      );
      _calculateTotal();
    }
  }

  void _calculateTotal() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final total = price * quantity;

    if (total > 0) {
      _totalController.text = total.toStringAsFixed(
        widget.symbol.quotePrecision,
      );
    } else {
      _totalController.text = '';
    }
  }

  void _calculateQuantity() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final total = double.tryParse(_totalController.text) ?? 0;

    if (price > 0 && total > 0) {
      final quantity = total / price;
      _quantityController.text = quantity.toStringAsFixed(
        widget.symbol.baseAssetPrecision,
      );
    } else {
      _quantityController.text = '';
    }
  }

  void _handleSliderChange(double value) {
    setState(() {
      _sliderValue = value;

      if (widget.baseBalance != null && widget.quoteBalance != null) {
        if (_selectedSide == 'BUY') {
          final price = double.tryParse(_priceController.text) ?? 0;
          if (price > 0 && widget.quoteBalance!.free > 0) {
            final maxQuantity = widget.quoteBalance!.free / price;
            final sliderQuantity = maxQuantity * value;
            _quantityController.text = sliderQuantity.toStringAsFixed(
              widget.symbol.baseAssetPrecision,
            );
            _calculateTotal();
          }
        } else {
          // SELL
          if (widget.baseBalance!.free > 0) {
            final maxQuantity = widget.baseBalance!.free;
            final sliderQuantity = maxQuantity * value;
            _quantityController.text = sliderQuantity.toStringAsFixed(
              widget.symbol.baseAssetPrecision,
            );
            _calculateTotal();
          }
        }
      }
    });
  }

  void _placeOrder() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;

    if (price <= 0 || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid price or quantity')),
      );
      return;
    }

    if (quantity < widget.symbol.minOrderSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum order size is ${widget.symbol.minOrderSize} ${widget.symbol.baseAsset}',
          ),
        ),
      );
      return;
    }

    if (quantity > widget.symbol.maxOrderSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum order size is ${widget.symbol.maxOrderSize} ${widget.symbol.baseAsset}',
          ),
        ),
      );
      return;
    }

    // Check balance
    if (_selectedSide == 'BUY') {
      final total = price * quantity;
      final availableQuote = widget.quoteBalance?.free ?? 0;

      if (total > availableQuote) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient ${widget.symbol.quoteAsset} balance'),
          ),
        );
        return;
      }
    } else {
      // SELL
      final availableBase = widget.baseBalance?.free ?? 0;

      if (quantity > availableBase) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient ${widget.symbol.baseAsset} balance'),
          ),
        );
        return;
      }
    }

    widget.onPlaceOrder(_selectedType, _selectedSide, price, quantity);

    // Reset form
    setState(() {
      _sliderValue = 0.0;
      _quantityController.text = '';
      _totalController.text = '';
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buy/Sell toggle
          Row(
            children: [
              Expanded(
                child: _buildSideToggleButton('BUY', AppTheme.positiveColor),
              ),
              Expanded(
                child: _buildSideToggleButton('SELL', AppTheme.negativeColor),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Order type toggle
          Row(
            children: [
              _buildTypeToggleButton('LIMIT'),
              const SizedBox(width: 8),
              _buildTypeToggleButton('MARKET'),
            ],
          ),

          const SizedBox(height: 16),

          // Price input (only for LIMIT orders)
          if (_selectedType == 'LIMIT')
            _buildTextField(
              label: 'Price',
              controller: _priceController,
              suffix: widget.symbol.quoteAsset,
              onChanged: (_) => _calculateTotal(),
            ),

          const SizedBox(height: 8),

          // Quantity input
          _buildTextField(
            label: 'Amount',
            controller: _quantityController,
            suffix: widget.symbol.baseAsset,
            onChanged: (_) => _calculateTotal(),
          ),

          const SizedBox(height: 8),

          // Total (only for LIMIT orders)
          if (_selectedType == 'LIMIT')
            _buildTextField(
              label: 'Total',
              controller: _totalController,
              suffix: widget.symbol.quoteAsset,
              onChanged: (_) => _calculateQuantity(),
            ),

          const SizedBox(height: 8),

          // Balance display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available:',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              Text(
                _selectedSide == 'BUY'
                    ? '${widget.quoteBalance?.free.toStringAsFixed(widget.symbol.quotePrecision) ?? '0'} ${widget.symbol.quoteAsset}'
                    : '${widget.baseBalance?.free.toStringAsFixed(widget.symbol.baseAssetPrecision) ?? '0'} ${widget.symbol.baseAsset}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Order slider
          Slider(
            value: _sliderValue,
            onChanged: _handleSliderChange,
            activeColor: _selectedSide == 'BUY'
                ? AppTheme.positiveColor
                : AppTheme.negativeColor,
          ),

          // Percentage buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPercentButton('25%', 0.25),
              _buildPercentButton('50%', 0.5),
              _buildPercentButton('75%', 0.75),
              _buildPercentButton('100%', 1.0),
            ],
          ),

          const SizedBox(height: 16),

          // Place order button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedSide == 'BUY'
                    ? AppTheme.positiveColor
                    : AppTheme.negativeColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                _selectedSide == 'BUY'
                    ? 'Buy ${widget.symbol.baseAsset}'
                    : 'Sell ${widget.symbol.baseAsset}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideToggleButton(String side, Color color) {
    final isSelected = _selectedSide == side;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedSide = side;
          _sliderValue = 0.0;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : AppTheme.cardColor,
        foregroundColor: isSelected ? Colors.white : color,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(side, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTypeToggleButton(String type) {
    final isSelected = _selectedType == type;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedType = type;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppTheme.primaryColor
            : AppTheme.cardColor,
        foregroundColor: isSelected ? Colors.white : Colors.grey,
        elevation: isSelected ? 2 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(type),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
          onChanged: onChanged,
          decoration: InputDecoration(
            suffixText: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }

  Widget _buildPercentButton(String label, double value) {
    return TextButton(
      onPressed: () => _handleSliderChange(value),
      child: Text(label),
    );
  }
}
