import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../main_navigation.dart';
import '../screens/login_page.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class AuthService {
  static bool _isLoggedIn = false;
  static User? _currentUser;
  static SharedPreferences? _prefs;
  
  static bool get isLoggedIn => _isLoggedIn;
  static User? get currentUser => _currentUser;
  
  // Store password in raw format as requested
  static String _storePassword(String password) {
    return password; // Store password in raw format
  }
  
  // Initialize SharedPreferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedLogin();
  }
  
  // Load saved login state
  static Future<void> _loadSavedLogin() async {
    if (_prefs == null) return;
    
    final savedEmail = _prefs!.getString('saved_email');
    final savedPassword = _prefs!.getString('saved_password');
    final rememberMe = _prefs!.getBool('remember_me') ?? false;
    
    if (rememberMe && savedEmail != null && savedPassword != null) {
      // Auto-login with saved credentials
      await login(savedEmail, savedPassword);
    }
  }
  
  // Save login state
  static Future<void> _saveLoginState(String email, String password, bool rememberMe) async {
    if (_prefs == null) return;
    
    if (rememberMe) {
      await _prefs!.setString('saved_email', email);
      await _prefs!.setString('saved_password', password);
      await _prefs!.setBool('remember_me', true);
    } else {
      await _prefs!.remove('saved_email');
      await _prefs!.remove('saved_password');
      await _prefs!.setBool('remember_me', false);
    }
  }
  
  static Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final dbHelper = DatabaseHelper();
      // Use raw password for comparison
      final user = await dbHelper.getUserByEmailAndPassword(email, password);
      
      if (user != null) {
        _isLoggedIn = true;
        _currentUser = user;
        
        // Save login state if remember me is checked
        await _saveLoginState(email, password, rememberMe);
        
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
      
      // Store password in raw format as requested
      final rawPassword = _storePassword(password);
      
      // Create new user
      final user = User(
        name: name,
        email: email,
        password: rawPassword,
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
    
    // Clear saved credentials
    _prefs?.remove('saved_email');
    _prefs?.remove('saved_password');
    _prefs?.setBool('remember_me', false);
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthService.isLoggedIn ? const MainNavigation() : const LoginPage();
  }
}
