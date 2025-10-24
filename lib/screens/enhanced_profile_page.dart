import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../database/database_helper.dart';
import '../services/language_service.dart';
import 'edit_profile_page.dart';

class EnhancedProfilePage extends StatefulWidget {
  const EnhancedProfilePage({super.key});

  @override
  State<EnhancedProfilePage> createState() => _EnhancedProfilePageState();
}

class _EnhancedProfilePageState extends State<EnhancedProfilePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  UserProfile? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    final profiles = await _dbHelper.getAllUserProfiles();
    if (profiles.isNotEmpty) {
      setState(() {
        _userProfile = profiles.first;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageService.translate('profile')),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(profile: _userProfile),
                ),
              );
              if (result == true) {
                _loadUserProfile();
              }
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? _buildEmptyProfile(languageService)
              : _buildProfileContent(languageService),
    );
  }

  Widget _buildEmptyProfile(LanguageService languageService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            size: 80,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 20),
          Text(
            languageService.translate('no_profile'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            languageService.translate('create_profile_message'),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
              if (result == true) {
                _loadUserProfile();
              }
            },
            icon: const Icon(Icons.add),
            label: Text(languageService.translate('create_profile')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(LanguageService languageService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Card(
            elevation: 4,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue[600],
                    child: Text(
                      _userProfile!.name.isNotEmpty 
                          ? _userProfile!.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userProfile!.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_userProfile!.age} years old',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userProfile!.gender,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Personal Information
          _buildSectionCard(
            languageService.translate('personal_info'),
            [
              _buildInfoRow(languageService.translate('name'), _userProfile!.name),
              _buildInfoRow(languageService.translate('age'), '${_userProfile!.age}'),
              _buildInfoRow(languageService.translate('gender'), _userProfile!.gender),
              _buildInfoRow(languageService.translate('blood_group'), _userProfile!.bloodGroup),
              _buildInfoRow(languageService.translate('phone'), _userProfile!.phoneNumber),
              _buildInfoRow(languageService.translate('email'), _userProfile!.email),
              _buildInfoRow(languageService.translate('address'), _userProfile!.address),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Medical Information
          _buildSectionCard(
            languageService.translate('medical_info'),
            [
              _buildInfoRow(
                languageService.translate('medical_conditions'),
                _userProfile!.medicalConditions.isEmpty 
                    ? languageService.translate('none')
                    : _userProfile!.medicalConditions.join(', '),
              ),
              _buildInfoRow(
                languageService.translate('allergies'),
                _userProfile!.allergies.isEmpty 
                    ? languageService.translate('none')
                    : _userProfile!.allergies.join(', '),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Emergency Contact
          _buildSectionCard(
            languageService.translate('emergency_contact'),
            [
              _buildInfoRow(languageService.translate('name'), _userProfile!.emergencyContactName),
              _buildInfoRow(languageService.translate('phone'), _userProfile!.emergencyContactPhone),
              _buildInfoRow(languageService.translate('relation'), _userProfile!.emergencyContactRelation),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Preferences
          _buildSectionCard(
            languageService.translate('preferences'),
            [
              _buildInfoRow(languageService.translate('preferred_language'), _userProfile!.preferredLanguage),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
