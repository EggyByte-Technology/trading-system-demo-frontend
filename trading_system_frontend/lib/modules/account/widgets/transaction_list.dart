import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/models/account_models.dart';
import '../providers/account_provider.dart';

class TransactionList extends ConsumerStatefulWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  ConsumerState<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends ConsumerState<TransactionList> {
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  @override
  Widget build(BuildContext context) {
    final transactionsAsyncValue = ref.watch(
      transactionsProvider((
        page: _currentPage,
        pageSize: _pageSize,
        startTime: null,
        endTime: null,
        type: null,
      )),
    );

    return transactionsAsyncValue.when(
      data: (data) {
        final transactions = data.items;
        _hasMorePages = data.total > _currentPage * _pageSize;

        if (transactions.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No transactions found'),
            ),
          );
        }

        return Column(
          children: [
            ...transactions.map(
              (transaction) => TransactionItem(transaction: transaction),
            ),
            if (_hasMorePages)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _isLoadingMore
                      ? null
                      : () async {
                          setState(() {
                            _isLoadingMore = true;
                            _currentPage++;
                          });

                          // Force refresh of the provider with new page
                          ref.invalidate(
                            transactionsProvider((
                              page: _currentPage,
                              pageSize: _pageSize,
                              startTime: null,
                              endTime: null,
                              type: null,
                            )),
                          );

                          setState(() {
                            _isLoadingMore = false;
                          });
                        },
                  child: _isLoadingMore
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : const Text('Load More'),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading transactions: $error')),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionItem({Key? key, required this.transaction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = transaction.amount > 0;
    final date = DateTime.fromMillisecondsSinceEpoch(transaction.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(transaction.type.toUpperCase()),
            Text(
              '${isPositive ? '+' : ''}${transaction.amount.toStringAsFixed(8)} ${transaction.asset}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status: ${transaction.status.toUpperCase()}'),
                Text(_formatDate(date), style: theme.textTheme.bodySmall),
              ],
            ),
            if (transaction.reference != null &&
                transaction.reference!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text('Ref: ${transaction.reference}'),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
