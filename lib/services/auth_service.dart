import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  
  // Check if user should stay logged in
  static Future<bool> shouldStayLoggedIn() async {
    if (_prefs == null) return false;
    
    final isLoggedIn = _prefs!.getBool('is_logged_in') ?? false;
    final savedEmail = _prefs!.getString('saved_email');
    
    return isLoggedIn && savedEmail != null;
  }
  
  // Force restore login state
  static Future<bool> forceRestoreLoginState() async {
    if (_prefs == null) return false;
    
    final isLoggedIn = _prefs!.getBool('is_logged_in') ?? false;
    final savedEmail = _prefs!.getString('saved_email');
    final rememberMe = _prefs!.getBool('remember_me') ?? false;
    final savedPassword = _prefs!.getString('saved_password');
    
    if (isLoggedIn && savedEmail != null) {
      if (rememberMe && savedPassword != null) {
        // Try to login with saved credentials
        return await login(savedEmail, savedPassword, rememberMe: rememberMe);
      } else {
        // Just restore the session without password
        try {
          final dbHelper = DatabaseHelper();
          final user = await dbHelper.getUserByEmail(savedEmail);
          if (user != null) {
            _isLoggedIn = true;
            _currentUser = user;
            print('Restored login state for user: ${user.name}');
            return true;
          }
        } catch (e) {
          print('Error restoring login state: $e');
        }
      }
    }
    return false;
  }
  
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
    final isLoggedIn = _prefs!.getBool('is_logged_in') ?? false;
    
    print('Loading saved login state:');
    print('- isLoggedIn: $isLoggedIn');
    print('- rememberMe: $rememberMe');
    print('- savedEmail: $savedEmail');
    print('- hasPassword: ${savedPassword != null}');
    
    if (isLoggedIn && rememberMe && savedEmail != null && savedPassword != null) {
      print('Attempting auto-login with saved credentials');
      // Auto-login with saved credentials
      final success = await login(savedEmail, savedPassword, rememberMe: rememberMe);
      if (success) {
        print('Auto-login successful');
      } else {
        print('Auto-login failed, clearing saved credentials');
        // Clear invalid saved credentials
        await _clearSavedLogin();
      }
    } else if (isLoggedIn && !rememberMe) {
      // User was logged in but didn't check remember me
      // Keep them logged in for this session
      print('User was logged in without remember me - keeping session active');
      _isLoggedIn = true;
      // Try to get user from database
      if (savedEmail != null) {
        try {
          final dbHelper = DatabaseHelper();
          final user = await dbHelper.getUserByEmail(savedEmail);
          if (user != null) {
            _currentUser = user;
            print('Restored user session: ${user.name}');
          }
        } catch (e) {
          print('Error restoring user session: $e');
          await _clearSavedLogin();
        }
      }
    } else {
      print('No valid saved login state found');
    }
  }
  
  // Save login state
  static Future<void> _saveLoginState(String email, String password, bool rememberMe) async {
    if (_prefs == null) return;
    
    // Always save login state and email
    await _prefs!.setBool('is_logged_in', true);
    await _prefs!.setString('saved_email', email);
    
    if (rememberMe) {
      await _prefs!.setString('saved_password', password);
      await _prefs!.setBool('remember_me', true);
    } else {
      await _prefs!.remove('saved_password');
      await _prefs!.setBool('remember_me', false);
    }
    
    print('Login state saved - isLoggedIn: true, rememberMe: $rememberMe');
  }
  
  // Clear saved login state
  static Future<void> _clearSavedLogin() async {
    if (_prefs == null) return;
    
    await _prefs!.remove('saved_email');
    await _prefs!.remove('saved_password');
    await _prefs!.setBool('remember_me', false);
    await _prefs!.setBool('is_logged_in', false);
  }
  
  static Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    try {
      final dbHelper = DatabaseHelper();
      
      // Test database connection first
      final isConnected = await dbHelper.testConnection();
      if (!isConnected) {
        print('Database connection failed during login');
        return false;
      }
      
      // Use raw password for comparison
      final user = await dbHelper.getUserByEmailAndPassword(email, password);
      
      if (user != null) {
        _isLoggedIn = true;
        _currentUser = user;
        
        // Save login state
        await _saveLoginState(email, password, rememberMe);
        
        print('Login successful for user: ${user.name}');
        return true;
      } else {
        print('Login failed: Invalid credentials for email: $email');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  static Future<bool> register(String name, String email, String password) async {
    try {
      final dbHelper = DatabaseHelper();
      
      // Test database connection first
      final isConnected = await dbHelper.testConnection();
      if (!isConnected) {
        print('Database connection failed during registration');
        return false;
      }
      
      // Check if email already exists
      final emailExists = await dbHelper.emailExists(email);
      if (emailExists) {
        print('Email already exists: $email');
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
      
      final userId = await dbHelper.insertUser(user);
      print('User registered successfully with ID: $userId');
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }
  
  static Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    
    // Clear saved credentials
    await _clearSavedLogin();
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthService.isLoggedIn ? const MainNavigation() : const LoginPage();
  }
}
