// Simple auth state management
// In a real app, use a proper state management solution like Provider, Riverpod, or Bloc
class AuthService {
  static bool _isLoggedIn = false;

  static bool get isLoggedIn => _isLoggedIn;

  static void login() {
    _isLoggedIn = true;
  }

  static void logout() {
    _isLoggedIn = false;
  }
}
