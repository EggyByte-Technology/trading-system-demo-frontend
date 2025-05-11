import '../models/identity_models.dart';
import 'api_client.dart';

/// Manager for identity-related API calls
class IdentityManager {
  /// Register a new user
  ///
  /// [request] Registration data
  static Future<AuthResponse> register(RegisterRequest request) async {
    final response = await ApiClient.post(
      'identity',
      '/auth/register',
      data: request.toJson(),
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to register');
    }

    final authResponse = AuthResponse.fromJson(response.data);

    // Store tokens for future requests
    await ApiClient.storeAuthTokens(
      authResponse.token,
      authResponse.refreshToken,
    );

    return authResponse;
  }

  /// Login a user
  ///
  /// [request] Login credentials
  static Future<AuthResponse> login(LoginRequest request) async {
    final response = await ApiClient.post(
      'identity',
      '/auth/login',
      data: request.toJson(),
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to login');
    }

    final authResponse = AuthResponse.fromJson(response.data);

    // Store tokens for future requests
    await ApiClient.storeAuthTokens(
      authResponse.token,
      authResponse.refreshToken,
    );

    return authResponse;
  }

  /// Refresh authentication token
  ///
  /// [request] Refresh token request
  static Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    final response = await ApiClient.post(
      'identity',
      '/auth/refresh-token',
      data: request.toJson(),
    );

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to refresh token');
    }

    final authResponse = AuthResponse.fromJson(response.data);

    // Store tokens for future requests
    await ApiClient.storeAuthTokens(
      authResponse.token,
      authResponse.refreshToken,
    );

    return authResponse;
  }

  /// Get current user information
  static Future<User> getCurrentUser() async {
    final response = await ApiClient.get('identity', '/auth/user');

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to get user');
    }

    return User.fromJson(response.data);
  }

  /// Update user information
  ///
  /// [username] New username (optional)
  /// [phone] New phone number (optional)
  /// [currentPassword] Current password (required for password change)
  /// [newPassword] New password (optional)
  static Future<User> updateUser({
    String? username,
    String? phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    final data = <String, dynamic>{};

    if (username != null) data['username'] = username;
    if (phone != null) data['phone'] = phone;
    if (currentPassword != null) data['currentPassword'] = currentPassword;
    if (newPassword != null) data['newPassword'] = newPassword;

    final response = await ApiClient.put('identity', '/auth/user', data: data);

    if (!response.isSuccess || response.data == null) {
      throw Exception(response.errorMessage ?? 'Failed to update user');
    }

    return User.fromJson(response.data);
  }

  /// Logout user by clearing stored tokens
  static Future<void> logout() async {
    await ApiClient.clearAuthTokens();
  }
}
