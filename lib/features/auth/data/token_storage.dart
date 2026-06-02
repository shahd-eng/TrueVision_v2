import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for storing and retrieving authentication tokens
/// and user information from local storage.
class TokenStorage {
  static const String _tokenKey = 'access_token';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _userUsernameKey = 'user_username';
  static const String _userAvatarPathKey = 'user_avatar_path';

  late SharedPreferences _prefs;

  /// Initialize the token storage with SharedPreferences instance
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save the access token and optional user information
  Future<void> saveToken({
    required String token,
    String? email,
    String? userName,
  }) async {
    await _prefs.setString(_tokenKey, token);
    if (email != null) {
      await _prefs.setString(_userEmailKey, email);
    }
    if (userName != null) {
      await _prefs.setString(_userNameKey, userName);
    }
  }

  /// Save user info without requiring an auth token (e.g. after signup).
  Future<void> saveUserProfile({
    String? email,
    String? fullName,
  }) async {
    if (email != null && email.trim().isNotEmpty) {
      await _prefs.setString(_userEmailKey, email.trim());
    }
    if (fullName != null && fullName.trim().isNotEmpty) {
      await _prefs.setString(_userNameKey, fullName.trim());
    }
  }

  Future<void> saveExtendedUserProfile({
    String? phone,
    String? username,
  }) async {
    if (phone != null) {
      final trimmed = phone.trim();
      if (trimmed.isEmpty) {
        await _prefs.remove(_userPhoneKey);
      } else {
        await _prefs.setString(_userPhoneKey, trimmed);
      }
    }
    if (username != null) {
      final trimmed = username.trim();
      if (trimmed.isEmpty) {
        await _prefs.remove(_userUsernameKey);
      } else {
        await _prefs.setString(_userUsernameKey, trimmed);
      }
    }
  }

  Future<void> saveUserAvatarPath(String? avatarPath) async {
    final value = avatarPath?.trim();
    if (value == null || value.isEmpty) {
      await _prefs.remove(_userAvatarPathKey);
    } else {
      await _prefs.setString(_userAvatarPathKey, value);
    }
  }

  /// Retrieve the stored access token
  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  /// Retrieve the stored user email
  String? getUserEmail() {
    return _prefs.getString(_userEmailKey);
  }

  /// Retrieve the stored user name
  String? getUserName() {
    return _prefs.getString(_userNameKey);
  }

  String? getUserPhone() {
    return _prefs.getString(_userPhoneKey);
  }

  String? getUserUsername() {
    return _prefs.getString(_userUsernameKey);
  }

  String? getUserAvatarPath() {
    return _prefs.getString(_userAvatarPathKey);
  }

  /// Check if a token is stored
  bool hasToken() {
    return _prefs.containsKey(_tokenKey);
  }

  /// Clear all stored authentication data (logout)
  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userEmailKey);
    await _prefs.remove(_userNameKey);
    await _prefs.remove(_userPhoneKey);
    await _prefs.remove(_userUsernameKey);
    await _prefs.remove(_userAvatarPathKey);
  }
}
