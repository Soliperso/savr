import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import '../config/env.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _cachedToken;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Map<String, String> _getHeaders([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String?> getToken() async {
    // First try to get the cached token
    if (_cachedToken != null) return _cachedToken;

    // Then try to get the token from secure storage
    final storedToken = await _storage.read(key: 'auth_token');
    if (storedToken != null) {
      _cachedToken = storedToken;
      return storedToken;
    }

    // Finally, use the token from .env
    if (Env.authToken.isNotEmpty) {
      await _storage.write(key: 'auth_token', value: Env.authToken);
      _cachedToken = Env.authToken;
      return Env.authToken;
    }

    return null;
  }

  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // Try to get user profile to validate token
      final response = await http.get(
        Uri.parse('${Env.baseApiUrl}/user/profile'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 401) {
        // Token is invalid, clear it
        _cachedToken = null;
        await _storage.delete(key: 'auth_token');
        return false;
      }

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Auth check error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    debugPrint('Response status code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.body.isEmpty) {
      throw Exception('Server returned an empty response');
    }

    late Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('JSON decode error: $e');
      throw Exception('Invalid response from server. Please try again.');
    }

    // Handle different status codes
    switch (response.statusCode) {
      case 200:
      case 201:
        // Handle successful responses that don't require a token
        if (data['message'] != null) {
          final message = data['message'].toString().toLowerCase();
          if (message.contains('success') || message.contains('registered')) {
            return data;
          }
        }

        // Check for token in different possible locations including nested structures
        final token =
            data['token'] ??
            data['access_token'] ??
            (data['data'] is Map ? data['data']['token'] : null) ??
            (data['user'] is Map ? data['user']['access_token'] : null) ??
            (data['user'] is Map ? data['user']['token'] : null) ??
            (data['auth'] is Map ? data['auth']['token'] : null);

        debugPrint('Attempting to extract token from response structure:');
        debugPrint('Direct token: ${data['token']}');
        debugPrint('Access token: ${data['access_token']}');
        debugPrint(
          'Data nested token: ${data['data'] is Map ? data['data']['token'] : null}',
        );
        debugPrint(
          'User nested token: ${data['user'] is Map ? data['user']['token'] : null}',
        );
        debugPrint('Found token: $token');

        if (token != null) {
          _cachedToken = token;
          await _storage.write(key: 'auth_token', value: token);

          // Try to extract user data from various possible locations
          Map<String, dynamic> responseData = Map<String, dynamic>.from(data);
          if (data['user'] is Map) {
            responseData = Map<String, dynamic>.from(data['user']);
          } else if (data['data'] is Map) {
            responseData = Map<String, dynamic>.from(data['data']);
          }

          // Ensure token is included in the response data
          responseData['token'] = token;
          return responseData;
        }

        debugPrint('Full response structure: ${json.encode(data)}');
        throw Exception('Invalid response format: missing token');

      case 401:
        throw Exception(data['message'] ?? 'Authentication failed');

      case 422:
        // Handle validation errors
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
        throw Exception(data['message'] ?? 'Validation failed');

      default:
        throw Exception(data['message'] ?? 'Request failed');
    }
  } // End of _handleResponse

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = '${Env.baseApiUrl}/login';
      final headers = _getHeaders();
      final body = {'email': email, 'password': password};

      debugPrint('Login Request:');
      debugPrint('URL: $url');
      debugPrint('Headers: $headers');
      debugPrint('Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('Login Response Status: ${response.statusCode}');
      debugPrint('Login Response Body: ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('Invalid email or password. Please try again.');
      }

      return await _handleResponse(response);
    } catch (e) {
      debugPrint('Login error: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error occurred. Please try again.');
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse('${Env.baseApiUrl}/register');
      final requestBody = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      };

      debugPrint('Starting registration request...');
      debugPrint('Request URL: $url');
      debugPrint('Request Headers: ${_getHeaders()}');
      debugPrint('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(requestBody),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      debugPrint('Parsed Response Data: $data');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Check if this is a successful registration without token
        if (data['message']?.toString().toLowerCase().contains(
              'registered successfully',
            ) ==
            true) {
          // Automatically login after successful registration
          debugPrint('Registration successful, attempting automatic login...');
          return await login(email, password);
        }

        // If we have a token in the response, process it
        final token =
            data['token'] ??
            data['access_token'] ??
            (data['data'] is Map ? data['data']['token'] : null);

        if (token != null) {
          _cachedToken = token;
          await _storage.write(key: 'auth_token', value: token);

          // If user data is nested in a 'data' field, use that
          final userData = data['data'] is Map ? data['data'] : data;
          return userData;
        }

        debugPrint('Token not found in response: $data');
        throw Exception('Registration successful. Please login to continue.');
      } else if (response.statusCode == 422) {
        // Handle validation errors
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          if (errors.containsKey('email')) {
            // Specific handling for email-related errors
            final emailErrors = errors['email'] as List?;
            if (emailErrors?.isNotEmpty == true) {
              throw Exception(
                'This email address is already registered. Please try logging in instead.',
              );
            }
          }
          // Handle other validation errors
          final firstError = errors.values.firstWhere(
            (error) => error is List && error.isNotEmpty,
            orElse: () => [],
          );
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
        throw Exception(
          data['message'] ??
              'Registration validation failed. Please check your information.',
        );
      } else {
        throw Exception(
          data['message'] ?? 'Registration failed. Please try again.',
        );
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      debugPrint('Registration error: $e');
      throw Exception(
        'Network error occurred. Please check your internet connection and try again.',
      );
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${Env.baseApiUrl}/forgot-password'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else if (response.statusCode == 422) {
        // Validation errors
        final errors = data['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first);
          }
        }
        throw Exception(data['message'] ?? 'Validation failed');
      } else {
        throw Exception(data['message'] ?? 'Password reset request failed');
      }
    } catch (e) {
      throw Exception('Network error occurred. Please try again.');
    }
  }

  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('${Env.baseApiUrl}/logout'),
          headers: _getHeaders(token),
        );

        if (response.statusCode != 200 && response.statusCode != 204) {
          throw Exception('Logout failed');
        }
      }
    } finally {
      // Always clear both cached and stored tokens
      _cachedToken = null;
      await _storage.delete(key: 'auth_token');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    try {
      final url = '${Env.baseApiUrl}/user/profile';
      final headers = _getHeaders(token);
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw Exception('Invalid response format');
      } else if (response.statusCode == 401) {
        await _storage.delete(key: 'auth_token');
        _cachedToken = null;
        throw Exception('Authentication token expired');
      } else {
        throw Exception('Failed to fetch user profile');
      }
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<Map<String, dynamic>> updateProfileImage(String imagePath) async {
    try {
      debugPrint('Starting profile image update process');
      final token = await getToken();
      if (token == null) {
        debugPrint('Authentication token not found');
        throw Exception('Not authenticated');
      }

      // Verify file exists
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('Image file not found at path: $imagePath');
        throw Exception('Image file not found');
      }

      // Get file size for logging
      final fileSize = await file.length();
      debugPrint('Image file size: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      final fileExtension = path
          .extension(imagePath)
          .toLowerCase()
          .replaceAll('.', '');

      // Create multipart request with timeout
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${Env.baseApiUrl}/user/update-profile-image'),
      );

      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      debugPrint('Preparing to upload image with extension: $fileExtension');

      // Add file to request
      try {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            imagePath,
            contentType: MediaType('image', fileExtension),
          ),
        );
        debugPrint('File added to request successfully');
      } catch (fileError) {
        debugPrint('Error adding file to request: $fileError');
        throw Exception('Failed to process image: $fileError');
      }

      // Send request with timeout
      debugPrint('Sending image upload request');
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Image upload request timed out');
          throw Exception('Request timed out');
        },
      );

      debugPrint(
        'Received response with status: ${streamedResponse.statusCode}',
      );
      final response = await http.Response.fromStream(streamedResponse);

      // For debugging purposes
      debugPrint(
        'Response body: ${response.body.substring(0, min(100, response.body.length))}...',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Image upload successful');
        return data;
      } else {
        Map<String, dynamic> error = {};
        try {
          error = jsonDecode(response.body);
        } catch (e) {
          debugPrint('Failed to parse error response: $e');
        }
        debugPrint(
          'Image upload failed with status: ${response.statusCode}, message: ${error['message'] ?? 'Unknown error'}',
        );
        throw Exception(
          error['message'] ??
              'Failed to update profile image (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('Error updating profile image: $e');
      // Return a mock response instead of throwing to prevent app crashes
      return {'success': false, 'error': e.toString(), 'profile_image': null};
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final url = '${Env.baseApiUrl}/auth/google';
      final headers = _getHeaders();
      final body = {'token': googleAuth.idToken};

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      return await _handleResponse(response);
    } catch (e) {
      debugPrint('Google sign in error: $e');
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // Add deleteAccount method
  Future<void> deleteAccount() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.delete(
      Uri.parse('${Env.baseApiUrl}/user/delete'),
      headers: _getHeaders(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete account: ${response.body}');
    }
  }
}
