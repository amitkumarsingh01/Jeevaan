import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main_navigation.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  _checkAuthAndNavigate() async {
    // Wait for splash screen duration
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      // Check if user is already logged in
      if (AuthService.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              'Jeevaan',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your Health Companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 50),
            CircularProgressIndicator(
              color: Colors.blue[600],
            ),
          ],
        ),
      ),
    );
  }
}
