import 'package:flutter/foundation.dart';
import '../core/services/auth_service.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _userName;
  String? _userEmail;
  String? _profileImage;
  bool _notificationsEnabled = true;
  bool _savePaymentMethods = true;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Define language and currency management variables
  String _currentLanguage = 'English';
  List<String> _availableLanguages = ['English', 'French', 'Spanish'];
  String _currentCurrency = 'USD';
  List<String> _availableCurrencies = ['USD', 'EUR', 'GBP', 'INR'];

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get profileImage => _profileImage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get savePaymentMethods => _savePaymentMethods;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String get currentLanguage => _currentLanguage;
  List<String> get availableLanguages => _availableLanguages;
  String get currentCurrency => _currentCurrency;
  List<String> get availableCurrencies => _availableCurrencies;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _isAuthenticated = await _authService.isAuthenticated();
      if (_isAuthenticated) {
        try {
          await _loadUserProfile();
        } catch (e) {
          debugPrint('Profile load error: $e');
          _isAuthenticated = false;
          await _authService.logout();
        }
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await _authService.getUserProfile();
      if (userData['name'] == null || userData['email'] == null) {
        throw Exception('Invalid user profile data');
      }
      _userName = userData['name'];
      _userEmail = userData['email'];
      _profileImage = userData['profile_image'];
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
      throw Exception('Failed to load user profile');
    }
  }

  void updateProfile({String? name, String? email, String? profileImage}) {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (profileImage != null) _profileImage = profileImage;
    notifyListeners();
  }

  Future<bool> updateProfileImage(String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfileImage(imagePath);
      if (response['profile_image'] != null) {
        _profileImage = response['profile_image'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
      throw Exception('Failed to update profile image');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void toggleSavePaymentMethods(bool value) {
    _savePaymentMethods = value;
    notifyListeners();
  }

  void changeLanguage(String newLanguage) {
    _currentLanguage = newLanguage;
    notifyListeners();
  }

  void changeCurrency(String newCurrency) {
    _currentCurrency = newCurrency;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    _isAuthenticated = false;
    notifyListeners();

    try {
      final userData = await _authService.register(name, email, password);

      // Check various possible locations for user data
      final user = userData['user'] ?? userData;

      if (user != null && user is Map) {
        _userName = user['name']?.toString();
        _userEmail = user['email']?.toString();

        if (_userName != null && _userEmail != null) {
          _isAuthenticated = true;
          _error = null;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      debugPrint('Invalid user data in response: $userData');
      throw Exception('Invalid response format: missing user data');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _authService.signInWithGoogle();

      // Handle different response data structures
      final user = userData['user'] ?? userData['data'] ?? userData;

      if (user is! Map) {
        throw Exception('Invalid response format: missing user data');
      }

      _userName = user['name']?.toString();
      _userEmail = user['email']?.toString();

      if (_userName == null || _userEmail == null) {
        throw Exception('Invalid response format: missing name or email');
      }

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _authService.login(email, password);

      // Handle different response data structures
      final user = userData['user'] ?? userData['data'] ?? userData;

      if (user is! Map) {
        throw Exception('Invalid response format: missing user data');
      }

      _userName = user['name']?.toString();
      _userEmail = user['email']?.toString();

      if (_userName == null || _userEmail == null) {
        throw Exception('Invalid response format: missing name or email');
      }

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.forgotPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.logout();
      _userName = null;
      _userEmail = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add deleteAccount method
  Future<void> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.deleteAccount();
      _userName = null;
      _userEmail = null;
      _profileImage = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add language and currency management as list view items
  List<Map<String, dynamic>> get settingsOptions => [
    {
      'title': 'Dark Mode',
      'icon': Icons.dark_mode_outlined,
      'value': notificationsEnabled,
      'onChanged': toggleNotifications,
    },
    {
      'title': 'Language',
      'icon': Icons.language,
      'value': _currentLanguage,
      'onChanged': changeLanguage,
    },
    {
      'title': 'Currency',
      'icon': Icons.attach_money,
      'value': _currentCurrency,
      'onChanged': changeCurrency,
    },
  ];
}
