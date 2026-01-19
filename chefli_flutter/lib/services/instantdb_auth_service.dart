import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../config/instantdb_config.dart';

class InstantDBAuthService {
  static const String _baseUrl = 'https://api.instantdb.com';
  static const String _appId = '588227b6-6022-44a9-88f3-b1c2e2cce304';
  static const String _authTokenKey = 'instantdb_auth_token';
  static const String _userKey = 'instantdb_user';
  static const String _saltKey = 'instantdb_salt';
  static const _uuid = Uuid();
  
  // Get the API base URL (backend proxy or direct InstantDB)
  String get _apiBaseUrl {
    if (InstantDBConfig.useBackendProxy) {
      return InstantDBConfig.backendUrl;
    }
    return _baseUrl;
  }

  // Get Admin HTTP API headers
  Map<String, String> get _adminHeaders {
    if (InstantDBConfig.useBackendProxy) {
      return {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${InstantDBConfig.adminToken}',
      'App-Id': _appId,
    };
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Helper method to execute InstantDB Admin HTTP API transact
  Future<Map<String, dynamic>> _adminTransact(List<List<dynamic>> steps) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/transact'),
      headers: _adminHeaders,
      body: jsonEncode({'steps': steps}),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Request timeout. Please check your internet connection.');
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorBody = utf8.decode(response.bodyBytes);
      print('❌ Admin Transact Error: ${response.statusCode} - $errorBody');
      throw Exception('InstantDB API error: ${response.statusCode} - $errorBody');
    }

    // Explicitly decode as UTF-8 to handle Hebrew and other non-ASCII characters
    final responseBody = utf8.decode(response.bodyBytes);
    return jsonDecode(responseBody);
  }

  // Helper method to query InstantDB Admin HTTP API
  Future<Map<String, dynamic>> _adminQuery(Map<String, dynamic> query) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/query'),
      headers: _adminHeaders,
      body: jsonEncode(query),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Request timeout. Please check your internet connection.');
      },
    );

    if (response.statusCode != 200) {
      final errorBody = utf8.decode(response.bodyBytes);
      print('❌ Admin Query Error: ${response.statusCode} - $errorBody');
      throw Exception('InstantDB Query error: ${response.statusCode} - $errorBody');
    }

    // Explicitly decode as UTF-8 to handle Hebrew and other non-ASCII characters
    final responseBody = utf8.decode(response.bodyBytes);
    return jsonDecode(responseBody);
  }

  // Get current user from local storage
  Future<InstantDBUser?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null) return null;
      return InstantDBUser.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> get isLoggedIn async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Get auth token from local storage
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Save auth token and user to local storage
  Future<void> _saveAuthData(String token, InstantDBUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userKey);
  }

  // Generate salt for password hashing
  String _generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return sha256.convert(utf8.encode(random)).toString();
  }

  // Hash password with salt
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Validate password strength
  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  // Create account with email and password
  Future<InstantDBUser> createAccount(
    String email,
    String password, {
    String? name,
  }) async {
    try {
      // Validate email
      if (!_isValidEmail(email)) {
        throw Exception('Invalid email address.');
      }

      // Validate password
      final passwordError = _validatePassword(password);
      if (passwordError != null) {
        throw Exception(passwordError);
      }

      // Check if user already exists
      try {
        final existingUser = await _findUserByEmail(email);
        if (existingUser != null) {
          throw Exception('An account already exists with this email.');
        }
      } catch (e) {
        // If error is about existing user, rethrow
        if (e.toString().contains('already exists')) {
          rethrow;
        }
        // Otherwise, continue (user doesn't exist)
      }

      // Generate salt and hash password
      final salt = _generateSalt();
      final passwordHash = _hashPassword(password, salt);

      // Create user data with salt stored in InstantDB
      // Use UUID for InstantDB entity ID (required by InstantDB)
      final userId = _uuid.v4();
      final userData = {
        'id': userId,
        'email': email.toLowerCase().trim(),
        'passwordHash': passwordHash,
        'passwordSalt': salt,
        'name': name?.trim(),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Insert user into InstantDB
      if (InstantDBConfig.useBackendProxy) {
        // Use backend proxy
        final response = await http.post(
          Uri.parse('$_apiBaseUrl${InstantDBConfig.createUserEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email.toLowerCase().trim(),
            'passwordHash': passwordHash,
            'passwordSalt': salt,
            'name': name?.trim(),
          }),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timeout. Please check your internet connection.');
          },
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          final errorBody = utf8.decode(response.bodyBytes);
          final data = jsonDecode(errorBody);
          if ((data['error']?.toString().contains('already exists') ?? false) || 
              errorBody.contains('already exists') || 
              errorBody.contains('duplicate')) {
            throw Exception('An account already exists with this email.');
          }
          throw Exception('Failed to create account: ${data['error'] ?? response.statusCode}');
        }

        // Explicitly decode as UTF-8 to handle Hebrew and other non-ASCII characters
        final responseBody = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(responseBody);
        if (responseData['success'] == true && responseData['user'] != null) {
          final createdUser = responseData['user'];
          userData['id'] = createdUser['id'] ?? userId;
        }
      } else {
        // Use InstantDB Admin HTTP API
        print('📤 Creating user via Admin HTTP API');
        await _adminTransact([
          ['update', '\$users', userId, userData]
        ]);
        print('✅ User created successfully via Admin API');
      }

      final user = InstantDBUser(
        id: userId,
        email: email.toLowerCase().trim(),
        name: name?.trim(),
        createdAt: DateTime.now(),
        photoUrl: null,
      );

      // Generate a simple auth token (in production, use InstantDB's auth system)
      final authToken = sha256.convert(utf8.encode('$email:$userId')).toString();
      await _saveAuthData(authToken, user);

      return user;
    } catch (e) {
      print('Error creating account: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to create account: ${e.toString()}');
    }
  }

  // Helper method to find user by email
  Future<Map<String, dynamic>?> _findUserByEmail(String email) async {
    try {
      if (InstantDBConfig.useBackendProxy) {
        // Use backend proxy
        final response = await http.post(
          Uri.parse('$_apiBaseUrl${InstantDBConfig.findUserEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email.toLowerCase().trim()}),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timeout. Please check your internet connection.');
          },
        );

        if (response.statusCode != 200) {
          final errorBody = utf8.decode(response.bodyBytes);
          print('⚠️  Failed to find user by email: ${response.statusCode} - $errorBody');
          return null;
        }

        // Explicitly decode as UTF-8 to handle Hebrew and other non-ASCII characters
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        if (data['success'] == true && data['user'] != null) {
          return Map<String, dynamic>.from(data['user']);
        }
        return null;
      } else {
        // Use InstantDB Admin HTTP API
        final queryResult = await _adminQuery({
          'users': {
            '\$': {
              'where': {'email': email.toLowerCase().trim()},
            },
          },
        });

        final users = queryResult['data']?['users'] as List<dynamic>?;
        if (users == null || users.isEmpty) {
          return null;
        }
        return Map<String, dynamic>.from(users.first);
      }
    } catch (e) {
      print('Error finding user by email: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<InstantDBUser> signInWithEmail(String email, String password) async {
    try {
      // Validate email
      if (!_isValidEmail(email)) {
        throw Exception('Invalid email address.');
      }

      // Find user by email
      final userData = await _findUserByEmail(email);
      
      if (userData == null) {
        throw Exception('No user found with this email.');
      }

      final userId = userData['id'] as String;
      final storedHash = userData['passwordHash'] as String?;
      
      // Check if user has password (might be Google-only user)
      if (storedHash == null || storedHash.isEmpty) {
        throw Exception('This account was created with Google. Please sign in with Google.');
      }

      // Get salt from InstantDB (stored with user data)
      final salt = userData['passwordSalt'] as String? ?? '';
      
      if (salt.isEmpty) {
        // Fallback: try to get from local storage (for backward compatibility)
        final prefs = await SharedPreferences.getInstance();
        final localSalt = prefs.getString('${_saltKey}_$userId') ?? '';
        if (localSalt.isEmpty) {
          throw Exception('Unable to verify password. Please reset your password.');
        }
        // Verify with local salt
        final passwordHash = _hashPassword(password, localSalt);
        if (passwordHash != storedHash) {
          throw Exception('Wrong password provided.');
        }
      } else {
        // Verify password with salt from InstantDB
        final passwordHash = _hashPassword(password, salt);
        if (passwordHash != storedHash) {
          throw Exception('Wrong password provided.');
        }
      }

      final user = InstantDBUser(
        id: userId,
        email: userData['email'] as String,
        name: userData['name'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          userData['createdAt'] as int,
        ),
        googleId: userData['googleId'] as String?,
        photoUrl: userData['photoUrl'] as String?,
      );

      // Generate auth token
      final authToken = sha256.convert(utf8.encode('${user.email}:$userId')).toString();
      await _saveAuthData(authToken, user);

      return user;
    } catch (e) {
      print('Error signing in: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Helper method to find user by Google ID
  Future<Map<String, dynamic>?> _findUserByGoogleId(String googleId) async {
    try {
      if (InstantDBConfig.useBackendProxy) {
        // Use backend proxy
        final response = await http.post(
          Uri.parse('$_apiBaseUrl${InstantDBConfig.findUserByGoogleIdEndpoint}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'googleId': googleId}),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Request timeout. Please check your internet connection.');
          },
        );

        if (response.statusCode != 200) {
          final errorBody = utf8.decode(response.bodyBytes);
          print('⚠️  Failed to find user by Google ID: ${response.statusCode} - $errorBody');
          return null;
        }

        // Explicitly decode as UTF-8 to handle Hebrew and other non-ASCII characters
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        if (data['success'] == true && data['user'] != null) {
          return Map<String, dynamic>.from(data['user']);
        }
        return null;
      } else {
        // Use InstantDB Admin HTTP API
        final queryResult = await _adminQuery({
          'users': {
            '\$': {
              'where': {'googleId': googleId},
            },
          },
        });

        final users = queryResult['data']?['users'] as List<dynamic>?;
        if (users == null || users.isEmpty) {
          return null;
        }
        return Map<String, dynamic>.from(users.first);
      }
    } catch (e) {
      print('Error finding user by Google ID: $e');
      return null;
    }
  }

  // Sign in with Google
  Future<InstantDBUser> signInWithGoogle() async {
    try {
      // Trigger Google Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in was cancelled.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get user info from Google
      final email = googleUser.email;
      final name = googleUser.displayName;
      final googleId = googleUser.id;
      final photoUrl = googleUser.photoUrl;

      if (email == null || email.isEmpty) {
        throw Exception('Failed to get email from Google account.');
      }

      if (googleId == null || googleId.isEmpty) {
        throw Exception('Failed to get Google ID from account.');
      }

      InstantDBUser user;
      
      if (InstantDBConfig.useBackendProxy) {
        // Use backend proxy
        print('📤 Creating/updating user with Google sign-in via backend proxy');
        print('   URL: $_apiBaseUrl/api/users/create-google');
        print('   Email: ${email.toLowerCase().trim()}');
        print('   Google ID: $googleId');

        final response = await http.post(
          Uri.parse('$_apiBaseUrl/api/users/create-google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email.toLowerCase().trim(),
            'googleId': googleId,
            'name': name?.trim(),
            'photoUrl': photoUrl,
          }),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('❌ Request timeout');
            throw Exception('Request timeout. Please check your internet connection.');
          },
        );

        // Explicitly decode as UTF-8 to handle Hebrew and other non-ASCII characters
        final responseBody = utf8.decode(response.bodyBytes);
        
        print('📥 Backend Proxy Response:');
        print('   Status Code: ${response.statusCode}');
        print('   Response Body: $responseBody');

        if (response.statusCode != 200 && response.statusCode != 201) {
          final errorData = jsonDecode(responseBody);
          final errorMsg = errorData['error'] ?? 'Failed to save user to InstantDB';
          print('❌ Failed to save user to InstantDB: $errorMsg');
          throw Exception(errorMsg);
        }

        final responseData = jsonDecode(responseBody);
        if (responseData['success'] != true || responseData['user'] == null) {
          throw Exception('Invalid response from backend: $responseBody');
        }

        final userData = responseData['user'];
        print('✅ User saved successfully to InstantDB');
        print('   User ID: ${userData['id']}');
        print('   Email: ${userData['email']}');

        user = InstantDBUser(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String?,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            userData['createdAt'] as int,
          ),
          googleId: userData['googleId'] as String? ?? googleId,
          photoUrl: userData['photoUrl'] as String?,
        );
      } else {
        // Use InstantDB Admin HTTP API
        print('📤 Creating/updating user with Google sign-in via Admin HTTP API');
        
        // Check if user exists by Google ID
        var userData = await _findUserByGoogleId(googleId);
        
        if (userData != null) {
          // User exists, use existing user
          print('✅ Found existing user by Google ID');
          user = InstantDBUser(
            id: userData['id'] as String,
            email: userData['email'] as String? ?? email.toLowerCase().trim(),
            name: userData['name'] as String? ?? name,
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              userData['createdAt'] as int,
            ),
            googleId: googleId,
            photoUrl: userData['photoUrl'] as String? ?? photoUrl,
          );
        } else {
          // Check if email already exists (user might have signed up with email/password)
          final existingUserData = await _findUserByEmail(email);
          
          if (existingUserData != null) {
            // Update existing user with Google ID
            print('📤 Updating existing user with Google ID');
            final userId = existingUserData['id'] as String;
            await _adminTransact([
              ['update', '\$users', userId, {
                'googleId': googleId,
                'name': name ?? existingUserData['name'],
                'photoUrl': photoUrl ?? existingUserData['photoUrl'],
              }]
            ]);
            print('✅ User updated successfully');
            
            user = InstantDBUser(
              id: userId,
              email: existingUserData['email'] as String,
              name: name ?? existingUserData['name'] as String?,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                existingUserData['createdAt'] as int,
              ),
              googleId: googleId,
              photoUrl: photoUrl ?? existingUserData['photoUrl'] as String?,
            );
          } else {
            // Create new user
            print('📤 Creating new user');
            // Use UUID for InstantDB entity ID (required by InstantDB)
            final userId = _uuid.v4();
            final newUserData = {
              'id': userId,
              'email': email.toLowerCase().trim(),
              'name': name?.trim(),
              'googleId': googleId,
              'photoUrl': photoUrl,
              'createdAt': DateTime.now().millisecondsSinceEpoch,
            };
            
            await _adminTransact([
              ['update', '\$users', userId, newUserData]
            ]);
            print('✅ User created successfully');
            
            user = InstantDBUser(
              id: userId,
              email: email.toLowerCase().trim(),
              name: name?.trim(),
              createdAt: DateTime.now(),
              googleId: googleId,
              photoUrl: photoUrl,
            );
          }
        }
      }

      // Generate auth token
      final authToken = sha256.convert(utf8.encode('${user.email}:${user.id}')).toString();
      await _saveAuthData(authToken, user);

      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _clearAuthData();
    } catch (e) {
      print('Error signing out: $e');
      // Continue even if sign out fails
      await _clearAuthData();
    }
  }

  // Auth state changes stream (simplified - check periodically)
  Stream<InstantDBUser?> get authStateChanges async* {
    yield await getCurrentUser();
    // In a real implementation, you'd set up a listener
    // For now, we'll just yield the current user
  }
}

