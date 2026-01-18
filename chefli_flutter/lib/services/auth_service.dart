import '../models/user.dart';
import 'instantdb_auth_service.dart';

// Wrapper class to maintain compatibility with AuthProvider
class UserCredential {
  final InstantDBUser user;
  UserCredential({required this.user});
}

class AuthService {
  final InstantDBAuthService _instantDBAuth = InstantDBAuthService();

  // Get current user
  InstantDBUser? get currentUser {
    // This is synchronous but InstantDB is async, so we'll handle it in provider
    return null;
  }

  // Auth state changes stream
  Stream<InstantDBUser?> get authStateChanges => _instantDBAuth.authStateChanges;

  // Check if user is logged in
  Future<bool> get isLoggedIn => _instantDBAuth.isLoggedIn;

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final user = await _instantDBAuth.signInWithGoogle();
      return UserCredential(user: user);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final user = await _instantDBAuth.signInWithEmail(email, password);
      return UserCredential(user: user);
    } catch (e) {
      final errorMsg = _handleAuthException(e);
      throw Exception(errorMsg);
    }
  }

  // Create account with email and password
  Future<UserCredential> createAccount(String email, String password) async {
    try {
      final user = await _instantDBAuth.createAccount(email, password);
      return UserCredential(user: user);
    } catch (e) {
      final errorMsg = _handleAuthException(e);
      throw Exception(errorMsg);
    }
  }

  // Send password reset email
  // Note: InstantDB doesn't have built-in password reset, so this is a placeholder
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // In a real implementation, you'd send a reset email via your backend
      // For now, we'll just throw an exception indicating this needs to be implemented
      throw Exception('Password reset is not yet implemented. Please contact support.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _instantDBAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      // Continue even if sign out fails
    }
  }

  // Handle auth exceptions
  String _handleAuthException(dynamic e) {
    final errorString = e.toString().toLowerCase();
    
    if (errorString.contains('no user found') || errorString.contains('user-not-found')) {
      return 'No user found with this email.';
    }
    if (errorString.contains('wrong password')) {
      return 'Wrong password provided.';
    }
    if (errorString.contains('already exists') || errorString.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }
    if (errorString.contains('invalid email')) {
      return 'Invalid email address.';
    }
    if (errorString.contains('weak password') || errorString.contains('password is too weak')) {
      return 'Password is too weak. Please use at least 6 characters.';
    }
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (errorString.contains('too many')) {
      return 'Too many attempts. Please try again later.';
    }
    
    // Extract the actual error message
    if (e is Exception) {
      String msg = e.toString();
      if (msg.startsWith('Exception: ')) {
        msg = msg.substring(11);
      }
      return msg;
    }
    
    return 'An error occurred. Please try again.';
  }
}
