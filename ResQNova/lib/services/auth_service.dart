import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _loginKey = 'is_logged_in';
  static const String _roleKey = 'user_role';

  // Login and save the user's role.
  static Future<void> login(String role) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(_loginKey, true);
    await prefs.setString(_roleKey, role);
  }

  // Check whether the user is logged in.
  static Future<bool> isLoggedIn() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(_loginKey) ?? false;
  }

  // Get the current user's role.
  static Future<String?> getRole() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_roleKey);
  }

  // Check if current user is a local user.
  static Future<bool> isLocalUser() async {
    return await getRole() == 'local_user';
  }

  // Check if current user is a rescue team member.
  static Future<bool> isRescueTeam() async {
    return await getRole() == 'rescue_team';
  }

  // Logout and remove the saved role.
  static Future<void> logout() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_loginKey);
    await prefs.remove(_roleKey);
  }
}