import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/app_config.dart';
import '../logger.dart';

/// API response with status code, data, and error message
class ApiResponse<T> {
  final int statusCode;
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  ApiResponse({
    required this.statusCode,
    this.data,
    this.errorMessage,
    required this.isSuccess,
  });

  factory ApiResponse.success(int statusCode, T data) {
    return ApiResponse(statusCode: statusCode, data: data, isSuccess: true);
  }

  factory ApiResponse.error(int statusCode, String message) {
    return ApiResponse(
      statusCode: statusCode,
      errorMessage: message,
      isSuccess: false,
    );
  }
}

/// Singleton API client for handling all HTTP requests to the backend services
class ApiClient {
  // Secure storage for tokens
  static late FlutterSecureStorage _secureStorage;

  // App configuration
  static final AppConfig _config = AppConfig();

  // Initialization status
  static bool _isInitialized = false;

  // HTTP client
  static final http.Client _client = http.Client();

  // Flag to prevent infinite token refresh loops
  static bool _isRefreshing = false;

  // Default timeout duration for HTTP requests
  static const Duration _defaultTimeout = Duration(seconds: 30);

  /// Initialize the API client
  static void initialize() {
    if (_isInitialized) return;
    _secureStorage = const FlutterSecureStorage();
    _isInitialized = true;
  }

  /// Gets the service URL for specific domains
  static String _getServiceUrl(String service, String endpoint) {
    return _config.getServiceUrl(service, endpoint);
  }

  /// Constructs a fully qualified URL with properly handled query parameters
  static Uri _buildRequestUrl(
    String baseUrl,
    Map<String, dynamic>? queryParameters,
  ) {
    // Only include query parameters if they exist and are not empty
    if (queryParameters == null || queryParameters.isEmpty) {
      return Uri.parse(baseUrl);
    }

    // Convert all query parameter values to strings
    final stringQueryParams = queryParameters.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return Uri.parse(baseUrl).replace(queryParameters: stringQueryParams);
  }

  /// Logs the request details
  static void _logRequest(String method, String url, {dynamic data}) {
    Logger.i('🚀 HTTP $method: $url');

    if (data != null) {
      Logger.i('Request body: ${_formatRequestData(data)}');
    }
  }

  /// Formats request data for logging
  static String _formatRequestData(dynamic data) {
    if (data == null) return 'null';

    try {
      if (data is Map || data is List) {
        // Mask sensitive fields
        if (data is Map) {
          final maskedData = Map<String, dynamic>.from(data as Map);
          _maskSensitiveData(maskedData);
          return maskedData.toString();
        }
        return data.toString();
      }
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }

  /// Masks sensitive data fields for logging
  static void _maskSensitiveData(Map<String, dynamic> data) {
    const sensitiveFields = [
      'password',
      'token',
      'refreshToken',
      'secret',
      'apiKey',
    ];

    for (final key in data.keys.toList()) {
      if (sensitiveFields.contains(key.toLowerCase())) {
        data[key] = '******';
      } else if (data[key] is Map) {
        _maskSensitiveData(data[key] as Map<String, dynamic>);
      }
    }
  }

  /// Create common headers including auth token if available
  static Future<Map<String, String>> _createHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth token if available
    final token = await _secureStorage.read(key: _config.tokenKey);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Process HTTP response (legacy version without token refresh)
  static ApiResponse<T> _processResponse<T>(http.Response response) {
    final statusCode = response.statusCode;

    // Log response
    Logger.d('📩 Response [${response.statusCode}]: ${response.body}');

    // Handle successful responses (2xx)
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(statusCode, null as T);
      }

      try {
        final jsonData = json.decode(response.body);
        return ApiResponse.success(statusCode, jsonData as T);
      } catch (e) {
        final errorMsg = 'Failed to decode response: ${e.toString()}';
        Logger.e(errorMsg);
        return ApiResponse.error(statusCode, errorMsg);
      }
    }

    // Handle error responses
    String errorMessage;
    try {
      final jsonData = json.decode(response.body);
      errorMessage = jsonData['message'] ?? 'Unknown error occurred';
    } catch (e) {
      errorMessage = response.body.isNotEmpty
          ? response.body
          : 'Error ${response.statusCode}';
    }

    Logger.e('Request failed with status $statusCode: $errorMessage');
    return ApiResponse.error(statusCode, errorMessage);
  }

  /// Process HTTP response with token refresh capability
  static Future<ApiResponse<T>> _processResponseWithAuth<T>(
    http.Response response,
    Future<ApiResponse<T>> Function() retryRequest,
  ) async {
    final statusCode = response.statusCode;

    // Log response
    Logger.d('📩 Response [${response.statusCode}]: ${response.body}');

    // Handle successful responses (2xx)
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(statusCode, null as T);
      }

      try {
        final jsonData = json.decode(response.body);
        return ApiResponse.success(statusCode, jsonData as T);
      } catch (e) {
        final errorMsg = 'Failed to decode response: ${e.toString()}';
        Logger.e(errorMsg);
        return ApiResponse.error(statusCode, errorMsg);
      }
    }

    // Handle 401 Unauthorized - Token might be expired
    if (statusCode == 401 && !_isRefreshing) {
      Logger.w('Token expired, attempting to refresh...');

      // Try to refresh the token
      final refreshed = await refreshToken();
      if (refreshed) {
        Logger.i('Token refreshed successfully, retrying original request');
        // Retry the original request with the new token
        return await retryRequest();
      } else {
        Logger.e('Token refresh failed, user needs to login again');
        // Clear tokens if refresh failed
        await clearAuthTokens();
      }
    }

    // Handle error responses
    String errorMessage;
    try {
      final jsonData = json.decode(response.body);
      errorMessage = jsonData['message'] ?? 'Unknown error occurred';
    } catch (e) {
      errorMessage = response.body.isNotEmpty
          ? response.body
          : 'Error ${response.statusCode}';
    }

    Logger.e('Request failed with status $statusCode: $errorMessage');
    return ApiResponse.error(statusCode, errorMessage);
  }

  /// Executes a GET request
  static Future<ApiResponse<T>> get<T>(
    String service,
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    if (!_isInitialized) initialize();

    final baseUrl = _getServiceUrl(service, endpoint);
    final fullUrl = _buildRequestUrl(baseUrl, queryParameters);

    // Log the actual request URL
    _logRequest('GET', fullUrl.toString());

    try {
      final headers = await _createHeaders();
      final response = await _client
          .get(fullUrl, headers: headers)
          .timeout(_defaultTimeout);

      // Use the auth version of process response for auto refresh
      return _processResponseWithAuth<T>(
        response,
        () => get(service, endpoint, queryParameters: queryParameters),
      );
    } on TimeoutException catch (_) {
      Logger.e('GET request timed out: $fullUrl');
      return ApiResponse.error(
        HttpStatus.requestTimeout,
        'Request timed out. Please try again later.',
      );
    } catch (e) {
      Logger.e('GET request failed: $e');
      return ApiResponse.error(
        HttpStatus.internalServerError,
        'Network error: ${e.toString()}',
      );
    }
  }

  /// Executes a POST request
  static Future<ApiResponse<T>> post<T>(
    String service,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (!_isInitialized) initialize();

    final baseUrl = _getServiceUrl(service, endpoint);
    final fullUrl = _buildRequestUrl(baseUrl, queryParameters);

    // Log the actual request URL with body if present
    _logRequest('POST', fullUrl.toString(), data: data);

    try {
      final headers = await _createHeaders();
      final response = await _client
          .post(
            fullUrl,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          )
          .timeout(_defaultTimeout);

      // Skip token refresh for auth endpoints to prevent loops
      if (service == 'identity' &&
          (endpoint == '/auth/login' ||
              endpoint == '/auth/register' ||
              endpoint == '/auth/refresh-token')) {
        return _processResponse<T>(response);
      }

      // Use the auth version of process response for auto refresh
      return _processResponseWithAuth<T>(
        response,
        () => post(
          service,
          endpoint,
          data: data,
          queryParameters: queryParameters,
        ),
      );
    } on TimeoutException catch (_) {
      Logger.e('POST request timed out: $fullUrl');
      return ApiResponse.error(
        HttpStatus.requestTimeout,
        'Request timed out. Please try again later.',
      );
    } catch (e) {
      Logger.e('POST request failed: $e');
      return ApiResponse.error(
        HttpStatus.internalServerError,
        'Network error: ${e.toString()}',
      );
    }
  }

  /// Executes a PUT request
  static Future<ApiResponse<T>> put<T>(
    String service,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (!_isInitialized) initialize();

    final baseUrl = _getServiceUrl(service, endpoint);
    final fullUrl = _buildRequestUrl(baseUrl, queryParameters);

    // Log the actual request URL with body if present
    _logRequest('PUT', fullUrl.toString(), data: data);

    try {
      final headers = await _createHeaders();
      final response = await _client
          .put(
            fullUrl,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          )
          .timeout(_defaultTimeout);

      // Use the auth version of process response for auto refresh
      return _processResponseWithAuth<T>(
        response,
        () => put(
          service,
          endpoint,
          data: data,
          queryParameters: queryParameters,
        ),
      );
    } on TimeoutException catch (_) {
      Logger.e('PUT request timed out: $fullUrl');
      return ApiResponse.error(
        HttpStatus.requestTimeout,
        'Request timed out. Please try again later.',
      );
    } catch (e) {
      Logger.e('PUT request failed: $e');
      return ApiResponse.error(
        HttpStatus.internalServerError,
        'Network error: ${e.toString()}',
      );
    }
  }

  /// Executes a DELETE request
  static Future<ApiResponse<T>> delete<T>(
    String service,
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (!_isInitialized) initialize();

    final baseUrl = _getServiceUrl(service, endpoint);
    final fullUrl = _buildRequestUrl(baseUrl, queryParameters);

    // Log the actual request URL with body if present
    _logRequest('DELETE', fullUrl.toString(), data: data);

    try {
      final headers = await _createHeaders();
      final response = await _client
          .delete(
            fullUrl,
            headers: headers,
            body: data != null ? json.encode(data) : null,
          )
          .timeout(_defaultTimeout);

      // Use the auth version of process response for auto refresh
      return _processResponseWithAuth<T>(
        response,
        () => delete(
          service,
          endpoint,
          data: data,
          queryParameters: queryParameters,
        ),
      );
    } on TimeoutException catch (_) {
      Logger.e('DELETE request timed out: $fullUrl');
      return ApiResponse.error(
        HttpStatus.requestTimeout,
        'Request timed out. Please try again later.',
      );
    } catch (e) {
      Logger.e('DELETE request failed: $e');
      return ApiResponse.error(
        HttpStatus.internalServerError,
        'Network error: ${e.toString()}',
      );
    }
  }

  /// Store authentication tokens in secure storage
  static Future<void> storeAuthTokens(String token, String refreshToken) async {
    await _secureStorage.write(key: _config.tokenKey, value: token);
    await _secureStorage.write(
      key: _config.refreshTokenKey,
      value: refreshToken,
    );
  }

  /// Clear authentication tokens from secure storage
  static Future<void> clearAuthTokens() async {
    await _secureStorage.delete(key: _config.tokenKey);
    await _secureStorage.delete(key: _config.refreshTokenKey);
  }

  /// Get the current auth token (for WebSocket connections)
  static Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _config.tokenKey);
  }

  /// Helper method to refresh the access token
  static Future<bool> refreshToken() async {
    if (_isRefreshing) return false;

    try {
      _isRefreshing = true;

      final refreshToken = await _secureStorage.read(
        key: _config.refreshTokenKey,
      );

      if (refreshToken == null) {
        _isRefreshing = false;
        return false;
      }

      final response = await post(
        'identity',
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.isSuccess && response.data != null) {
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refreshToken'];

        await storeAuthTokens(newToken, newRefreshToken);
        _isRefreshing = false;
        return true;
      }

      _isRefreshing = false;
      return false;
    } catch (e) {
      Logger.e('Token refresh failed: $e');
      _isRefreshing = false;
      return false;
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: _config.tokenKey);
    return token != null;
  }
}
