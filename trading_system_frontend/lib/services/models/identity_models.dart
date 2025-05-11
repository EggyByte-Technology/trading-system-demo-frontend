// Identity models based on backend CommonLib.Models.Identity

/// User model
class User {
  final String id;
  final String username;
  final String email;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isEmailVerified;
  final bool isTwoFactorEnabled;
  final List<Role> roles;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.isEmailVerified,
    required this.isTwoFactorEnabled,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? json['userId'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      isEmailVerified: json['isEmailVerified'] ?? false,
      isTwoFactorEnabled: json['isTwoFactorEnabled'] ?? false,
      roles: _parseRoles(json['roles']),
    );
  }

  // Helper method to parse roles, handling both string lists and object lists
  static List<Role> _parseRoles(dynamic rolesData) {
    if (rolesData == null) {
      return [];
    }

    try {
      if (rolesData is List) {
        return rolesData.map((role) {
          // Handle case where role is a string (role name)
          if (role is String) {
            return Role(id: '', name: role, permissions: []);
          }
          // Handle case where role is a map (role object)
          else if (role is Map<String, dynamic>) {
            return Role.fromJson(role);
          }
          // Fallback
          return Role(id: '', name: 'Unknown', permissions: []);
        }).toList();
      }
    } catch (e) {
      // Add logging for debugging
      print('Error parsing roles: $e');
    }

    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (phone != null) 'phone': phone,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'isTwoFactorEnabled': isTwoFactorEnabled,
      'roles': roles.map((x) => x.toJson()).toList(),
    };
  }
}

/// Role model
class Role {
  final String id;
  final String name;
  final List<String> permissions;

  Role({required this.id, required this.name, required this.permissions});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'permissions': permissions};
  }
}

/// Authentication request model
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

/// Registration request model
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? phone;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
    };
  }
}

/// Authentication response model
class AuthResponse {
  final String userId;
  final String username;
  final String token;
  final String refreshToken;
  final int expiration;

  AuthResponse({
    required this.userId,
    required this.username,
    required this.token,
    required this.refreshToken,
    required this.expiration,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiration: json['expiration'] ?? 0,
    );
  }
}

/// Refresh token request model
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}

/// Security token model
class SecurityToken {
  final String id;
  final String userId;
  final String token;
  final String refreshToken;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isRevoked;

  SecurityToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.refreshToken,
    required this.createdAt,
    required this.expiresAt,
    required this.isRevoked,
  });

  factory SecurityToken.fromJson(Map<String, dynamic> json) {
    return SecurityToken(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      token: json['token'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expiresAt'])
          : DateTime.now().add(const Duration(days: 1)),
      isRevoked: json['isRevoked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'token': token,
      'refreshToken': refreshToken,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
      'isRevoked': isRevoked,
    };
  }
}
