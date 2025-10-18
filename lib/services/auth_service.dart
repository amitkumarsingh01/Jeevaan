import 'package:flutter/material.dart';
import '../main_navigation.dart';
import '../screens/login_page.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static User? _currentUser;
  
  static bool get isLoggedIn => _isLoggedIn;
  static User? get currentUser => _currentUser;
  
  static Future<bool> login(String email, String password) async {
    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUserByEmailAndPassword(email, password);
      
      if (user != null) {
        _isLoggedIn = true;
        _currentUser = user;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> register(String name, String email, String password) async {
    try {
      final dbHelper = DatabaseHelper();
      
      // Check if email already exists
      final emailExists = await dbHelper.emailExists(email);
      if (emailExists) {
        return false; // Email already exists
      }
      
      // Create new user
      final user = User(
        name: name,
        email: email,
        password: password,
        createdAt: DateTime.now(),
      );
      
      await dbHelper.insertUser(user);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  static void logout() {
    _isLoggedIn = false;
    _currentUser = null;
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthService.isLoggedIn ? const MainNavigation() : const LoginPage();
  }
}
