import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/account_manager.dart';
import '../../../services/models/account_models.dart';

/// Provider for fetching account balances
final balancesProvider = FutureProvider<List<Balance>>((ref) async {
  return AccountManager.getBalance();
});

/// Provider for fetching transaction history with pagination
final transactionsProvider =
    FutureProvider.family<
      ({int total, int page, int pageSize, List<Transaction> items}),
      ({int page, int pageSize, int? startTime, int? endTime, String? type})
    >((ref, params) async {
      return AccountManager.getTransactions(
        page: params.page,
        pageSize: params.pageSize,
        startTime: params.startTime,
        endTime: params.endTime,
        type: params.type,
      );
    });

/// Provider for available assets
final availableAssetsProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  return AccountManager.getAvailableAssets();
});
