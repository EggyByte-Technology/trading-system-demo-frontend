import '../models/account_models.dart';
import 'api_client.dart';

/// Manager for account-related API calls
class AccountManager {
  /// Get account balance
  static Future<List<Balance>> getBalance() async {
    final response = await ApiClient.get('account', '/account/balance');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get balance');
    }

    final List<dynamic> balances = response.data['balances'] ?? [];
    return balances.map((balance) => Balance.fromJson(balance)).toList();
  }

  /// Get transaction history
  ///
  /// [page] Page number (default: 1)
  /// [pageSize] Page size (default: 20)
  /// [startTime] Start time in Unix timestamp (optional)
  /// [endTime] End time in Unix timestamp (optional)
  /// [type] Transaction type filter (optional)
  static Future<({int total, int page, int pageSize, List<Transaction> items})>
  getTransactions({
    int page = 1,
    int pageSize = 20,
    int? startTime,
    int? endTime,
    String? type,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

    if (startTime != null) queryParams['startTime'] = startTime;
    if (endTime != null) queryParams['endTime'] = endTime;
    if (type != null) queryParams['type'] = type;

    final response = await ApiClient.get(
      'account',
      '/account/transactions',
      queryParameters: queryParams,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get transactions');
    }

    final data = response.data;
    final List<dynamic> items = data['items'] ?? [];

    return (
      total: data['total'] as int? ?? 0,
      page: data['page'] as int? ?? page,
      pageSize: data['pageSize'] as int? ?? pageSize,
      items: items.map((item) => Transaction.fromJson(item)).toList(),
    );
  }

  /// Create deposit
  ///
  /// [asset] Asset type
  /// [amount] Deposit amount
  /// [reference] Optional reference information
  static Future<Transaction> createDeposit({
    required String asset,
    required double amount,
    String? reference,
  }) async {
    final data = <String, dynamic>{'asset': asset, 'amount': amount};

    if (reference != null) data['reference'] = reference;

    final response = await ApiClient.post(
      'account',
      '/account/deposit',
      data: data,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to create deposit');
    }

    return Transaction.fromJson(response.data);
  }

  /// Create withdrawal request
  ///
  /// [asset] Asset type
  /// [amount] Withdrawal amount
  /// [address] Withdrawal address
  /// [memo] Optional memo information
  static Future<WithdrawalRequest> createWithdrawal({
    required String asset,
    required double amount,
    required String address,
    String? memo,
  }) async {
    final data = <String, dynamic>{
      'asset': asset,
      'amount': amount,
      'address': address,
    };

    if (memo != null) data['memo'] = memo;

    final response = await ApiClient.post(
      'account',
      '/account/withdraw',
      data: data,
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to create withdrawal');
    }

    return WithdrawalRequest.fromJson({
      'id': response.data['withdrawalId'],
      'status': response.data['status'],
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'asset': asset,
      'amount': amount,
      'address': address,
      'userId': '',
      if (memo != null) 'memo': memo,
    });
  }

  /// Get withdrawal status
  ///
  /// [id] Withdrawal request ID
  static Future<WithdrawalRequest> getWithdrawalStatus(String id) async {
    final response = await ApiClient.get('account', '/account/withdrawals/$id');

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.errorMessage ?? 'Failed to get withdrawal status',
      );
    }

    return WithdrawalRequest.fromJson(response.data);
  }

  /// Get available assets
  static Future<List<Map<String, dynamic>>> getAvailableAssets() async {
    final response = await ApiClient.get('account', '/account/assets');

    if (!response.isSuccess || response.data == null) {
      throw Exception(
        response.errorMessage ?? 'Failed to get available assets',
      );
    }

    final List<dynamic> assets = response.data['assets'] ?? [];
    return assets.cast<Map<String, dynamic>>();
  }
}
