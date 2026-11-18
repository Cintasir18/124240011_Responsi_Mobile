import 'package:shared_preferences/shared_preferences.dart';
class SessionService {
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';
  static Future<void> saveSession(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }
  static Future<void> saveUsername(String username) async => saveSession(username, '');
  static Future<String?> getEmail() async => (await SharedPreferences.getInstance()).getString(_emailKey);
  static Future<String?> getUsername() => getEmail();
  static Future<bool> hasSession() async => (await getEmail())?.isNotEmpty == true;
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey); await prefs.remove(_passwordKey);
  }
}
