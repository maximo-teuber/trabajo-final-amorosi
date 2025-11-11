import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const _usersKey = 'users';
  static const _loggedUserKey = 'loggedUser';

  /// Crear usuario nuevo
  static Future<bool> registerUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);
    final users = usersData != null ? jsonDecode(usersData) as Map<String, dynamic> : {};

    if (users.containsKey(username)) return false; // Usuario ya existe

    users[username] = password;
    await prefs.setString(_usersKey, jsonEncode(users));
    return true;
  }

  /// Iniciar sesión
  static Future<bool> loginUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final usersData = prefs.getString(_usersKey);
    final users = usersData != null ? jsonDecode(usersData) as Map<String, dynamic> : {};

    if (users[username] == password) {
      await prefs.setString(_loggedUserKey, username);
      return true;
    }
    return false;
  }

  /// Obtener usuario logueado
  static Future<String?> getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loggedUserKey);
  }

  /// Cerrar sesión
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedUserKey);
  }
}
