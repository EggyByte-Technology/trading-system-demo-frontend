import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api/account_manager.dart';
import '../../../services/models/account_models.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_list.dart';
import '../providers/account_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(balancesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(balancesProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(balancesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance section
              balanceAsync.when(
                data: (balances) {
                  if (balances.isEmpty) {
                    return const Center(child: Text('No assets found'));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Balances', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      ...balances.map(
                        (balance) => BalanceCard(balance: balance),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Error loading balances: $error')),
              ),

              const SizedBox(height: 24),

              // Recent transactions
              Text('Recent Transactions', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              const TransactionList(),

              const SizedBox(height: 16),

              // Wallet button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/account/wallet'),
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Deposit & Withdraw'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
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
}
