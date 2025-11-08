import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../services/auth_service.dart';

class DatabaseTestPage extends StatefulWidget {
  const DatabaseTestPage({super.key});

  @override
  State<DatabaseTestPage> createState() => _DatabaseTestPageState();
}

class _DatabaseTestPageState extends State<DatabaseTestPage> {
  Map<String, dynamic>? _dbInfo;
  bool _isLoading = false;
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper();
      final info = await dbHelper.getDatabaseInfo();
      setState(() {
        _dbInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _dbInfo = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final dbHelper = DatabaseHelper();
      final isConnected = await dbHelper.testConnection();
      
      setState(() {
        _testResult = isConnected ? 'Database connection successful!' : 'Database connection failed!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Database test error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testUserLogin() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      // Test with a sample user
      final success = await AuthService.login('test@example.com', 'password123');
      
      setState(() {
        _testResult = success ? 'Login test successful!' : 'Login test failed - user not found or invalid credentials';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Login test error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAutoLogin() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      // Test auto-login functionality
      final shouldStay = await AuthService.shouldStayLoggedIn();
      final restored = await AuthService.forceRestoreLoginState();
      
      setState(() {
        _testResult = 'Auto-login test:\n- Should stay logged in: $shouldStay\n- Force restore result: $restored\n- Current login state: ${AuthService.isLoggedIn}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Auto-login test error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestUser() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final success = await AuthService.register('Test User', 'test@example.com', 'password123');
      
      setState(() {
        _testResult = success ? 'Test user created successfully!' : 'Failed to create test user';
        _isLoading = false;
      });
      
      // Reload database info
      await _loadDatabaseInfo();
    } catch (e) {
      setState(() {
        _testResult = 'Create user error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Test'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Database Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else if (_dbInfo != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Connected: ${_dbInfo!['connected']}'),
                          Text('Users: ${_dbInfo!['users'] ?? 'N/A'}'),
                          Text('Medicines: ${_dbInfo!['medicines'] ?? 'N/A'}'),
                          Text('Doctors: ${_dbInfo!['doctors'] ?? 'N/A'}'),
                          if (_dbInfo!['error'] != null)
                            Text('Error: ${_dbInfo!['error']}', style: const TextStyle(color: Colors.red)),
                        ],
                      )
                    else
                      const Text('No data available'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Results',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (_testResult.isNotEmpty)
                      Text(_testResult),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testDatabaseConnection,
              child: const Text('Test Database Connection'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _createTestUser,
              child: const Text('Create Test User'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testUserLogin,
              child: const Text('Test User Login'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAutoLogin,
              child: const Text('Test Auto-Login'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _loadDatabaseInfo,
              child: const Text('Refresh Database Info'),
            ),
            const SizedBox(height: 20),
            if (AuthService.isLoggedIn)
              Card(
                color: Colors.green[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current User',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('Name: ${AuthService.currentUser?.name ?? 'N/A'}'),
                      Text('Email: ${AuthService.currentUser?.email ?? 'N/A'}'),
                      Text('Logged In: ${AuthService.isLoggedIn}'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}