import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../services/api/account_manager.dart';
import '../../../services/models/account_models.dart';
import '../providers/account_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedAsset = '';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _addressController.dispose();
    _memoController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assetsAsync = ref.watch(availableAssetsProvider);
    final balancesAsync = ref.watch(balancesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'DEPOSIT'),
            Tab(text: 'WITHDRAW'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Deposit Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deposit Funds', style: theme.textTheme.titleLarge),
                const SizedBox(height: 24),

                // Asset Selection
                Text('Select Asset', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                assetsAsync.when(
                  data: (assets) {
                    if (_selectedAsset.isEmpty && assets.isNotEmpty) {
                      _selectedAsset = assets[0]['symbol'];
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedAsset,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: assets.map((asset) {
                        return DropdownMenuItem<String>(
                          value: asset['symbol'],
                          child: Text('${asset['symbol']} - ${asset['name']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAsset = value!;
                        });
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),

                const SizedBox(height: 16),

                // Amount Field
                Text('Amount', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter amount',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),

                const SizedBox(height: 16),

                // Reference Field
                Text(
                  'Reference (Optional)',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter reference',
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleDeposit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : const Text('DEPOSIT'),
                  ),
                ),

                const SizedBox(height: 16),

                // Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deposit Information',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This is a simulated deposit. In a real application, this would show deposit addresses and instructions.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Withdraw Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Withdraw Funds', style: theme.textTheme.titleLarge),
                const SizedBox(height: 24),

                // Available Balance
                balancesAsync.when(
                  data: (balances) {
                    final selectedBalance = balances.firstWhere(
                      (balance) => balance.asset == _selectedAsset,
                      orElse: () => Balance(
                        asset: _selectedAsset,
                        free: 0,
                        locked: 0,
                        updatedAt: DateTime.now(),
                      ),
                    );

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Balance',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${selectedBalance.free.toStringAsFixed(8)} ${selectedBalance.asset}',
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),

                const SizedBox(height: 24),

                // Asset Selection
                Text('Select Asset', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                assetsAsync.when(
                  data: (assets) {
                    if (_selectedAsset.isEmpty && assets.isNotEmpty) {
                      _selectedAsset = assets[0]['symbol'];
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedAsset,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      items: assets.map((asset) {
                        return DropdownMenuItem<String>(
                          value: asset['symbol'],
                          child: Text('${asset['symbol']} - ${asset['name']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAsset = value!;
                        });
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),

                const SizedBox(height: 16),

                // Amount Field
                Text('Amount', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter amount',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                ),

                const SizedBox(height: 16),

                // Address Field
                Text('Withdrawal Address', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter withdrawal address',
                  ),
                ),

                const SizedBox(height: 16),

                // Memo Field
                Text('Memo (Optional)', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _memoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter memo if required',
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleWithdraw,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : const Text('WITHDRAW'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeposit() async {
    if (_selectedAsset.isEmpty) {
      _showError('Please select an asset');
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AccountManager.createDeposit(
        asset: _selectedAsset,
        amount: amount,
        reference: _referenceController.text.trim(),
      );

      if (!mounted) return;

      // Reset fields
      _amountController.clear();
      _referenceController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deposit created successfully: ${result.id}'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh balances
      ref.refresh(balancesProvider);
    } catch (e) {
      _showError('Error creating deposit: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleWithdraw() async {
    if (_selectedAsset.isEmpty) {
      _showError('Please select an asset');
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showError('Please enter a withdrawal address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AccountManager.createWithdrawal(
        asset: _selectedAsset,
        amount: amount,
        address: address,
        memo: _memoController.text.trim().isNotEmpty
            ? _memoController.text.trim()
            : null,
      );

      if (!mounted) return;

      // Reset fields
      _amountController.clear();
      _addressController.clear();
      _memoController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Withdrawal request created: ${result.id}'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh balances
      ref.refresh(balancesProvider);
    } catch (e) {
      _showError('Error creating withdrawal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
