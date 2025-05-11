import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/identity_manager.dart';
import '../../../services/models/identity_models.dart';
import '../../../services/api/api_client.dart';
import '../../../services/logger.dart';

// Auth state class to store current user and auth status
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth notifier class to handle authentication actions
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    // Try to load user data on initialization
    _loadUser();
  }

  // Load user information if token exists
  Future<void> _loadUser() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await IdentityManager.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e, stackTrace) {
      // Log the error with stack trace
      Logger.e('Failed to load user data', error: e, stackTrace: stackTrace);
      // If we can't load user, it might be that the token has expired or doesn't exist
      state = state.copyWith(user: null, isLoading: false);
    }
  }

  // Login user
  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final request = LoginRequest(email: email, password: password);
      await IdentityManager.login(request);

      Logger.i('User logged in successfully, fetching user data');
      // Once logged in, get the user information
      final user = await IdentityManager.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e, stackTrace) {
      // Log the error with stack trace
      Logger.e('Login failed', error: e, stackTrace: stackTrace);
      // Simply use the exception message directly
      String errorMessage = e.toString();
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  // Register user
  Future<void> register(
    String username,
    String email,
    String password,
    String? phone,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final request = RegisterRequest(
        username: username,
        email: email,
        password: password,
        phone: phone,
      );

      await IdentityManager.register(request);

      Logger.i('User registered successfully, fetching user data');
      // Once registered, get the user information
      final user = await IdentityManager.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e, stackTrace) {
      // Log the error with stack trace
      Logger.e('Registration failed', error: e, stackTrace: stackTrace);
      // Simply use the exception message directly
      String errorMessage = e.toString();
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await IdentityManager.logout();
      state = AuthState(); // Reset to initial state
    } catch (e, stackTrace) {
      Logger.e('Logout failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? username,
    String? phone,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final user = await IdentityManager.updateUser(
        username: username,
        phone: phone,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      Logger.i('User profile updated successfully');
      state = state.copyWith(user: user, isLoading: false);
    } catch (e, stackTrace) {
      Logger.e('Profile update failed', error: e, stackTrace: stackTrace);
      // Simply use the exception message directly
      String errorMessage = e.toString();
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }
}

// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
