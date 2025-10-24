import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../database/database_helper.dart';
import '../services/language_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile? profile;
  
  const EditProfilePage({super.key, this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _emergencyRelationController;
  
  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'A+';
  String _selectedLanguage = 'English';
  List<String> _medicalConditions = [];
  List<String> _allergies = [];
  
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _languages = ['English', 'Hindi', 'Kannada', 'Telugu'];
  final List<String> _commonConditions = [
    'Diabetes', 'Hypertension', 'Heart Disease', 'Asthma', 
    'Arthritis', 'Depression', 'Anxiety', 'Migraine'
  ];
  final List<String> _commonAllergies = [
    'Peanuts', 'Dairy', 'Gluten', 'Shellfish', 
    'Pollen', 'Dust', 'Medication', 'Latex'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _ageController = TextEditingController(text: widget.profile?.age.toString() ?? '');
    _phoneController = TextEditingController(text: widget.profile?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.profile?.email ?? '');
    _addressController = TextEditingController(text: widget.profile?.address ?? '');
    _emergencyNameController = TextEditingController(text: widget.profile?.emergencyContactName ?? '');
    _emergencyPhoneController = TextEditingController(text: widget.profile?.emergencyContactPhone ?? '');
    _emergencyRelationController = TextEditingController(text: widget.profile?.emergencyContactRelation ?? '');
    
    if (widget.profile != null) {
      _selectedGender = widget.profile!.gender;
      _selectedBloodGroup = widget.profile!.bloodGroup;
      _selectedLanguage = widget.profile!.preferredLanguage;
      _medicalConditions = List.from(widget.profile!.medicalConditions);
      _allergies = List.from(widget.profile!.allergies);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageService = context.watch<LanguageService>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null 
            ? languageService.translate('create_profile')
            : languageService.translate('edit_profile')),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              languageService.translate('save'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information
              _buildSectionCard(
                languageService.translate('personal_info'),
                [
                  _buildTextField(
                    controller: _nameController,
                    label: languageService.translate('name'),
                    validator: (value) => value?.isEmpty == true 
                        ? languageService.translate('name_required') : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _ageController,
                          label: languageService.translate('age'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return languageService.translate('age_required');
                            }
                            final age = int.tryParse(value!);
                            if (age == null || age < 1 || age > 120) {
                              return languageService.translate('age_invalid');
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedGender,
                          items: _genders,
                          label: languageService.translate('gender'),
                          onChanged: (value) => setState(() => _selectedGender = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    value: _selectedBloodGroup,
                    items: _bloodGroups,
                    label: languageService.translate('blood_group'),
                    onChanged: (value) => setState(() => _selectedBloodGroup = value!),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: languageService.translate('phone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.isEmpty == true 
                        ? languageService.translate('phone_required') : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: languageService.translate('email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return languageService.translate('email_required');
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                        return languageService.translate('email_invalid');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: languageService.translate('address'),
                    maxLines: 3,
                    validator: (value) => value?.isEmpty == true 
                        ? languageService.translate('address_required') : null,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Medical Information
              _buildSectionCard(
                languageService.translate('medical_info'),
                [
                  _buildMultiSelectChips(
                    label: languageService.translate('medical_conditions'),
                    items: _commonConditions,
                    selectedItems: _medicalConditions,
                    onChanged: (items) => setState(() => _medicalConditions = items),
                  ),
                  const SizedBox(height: 16),
                  _buildMultiSelectChips(
                    label: languageService.translate('allergies'),
                    items: _commonAllergies,
                    selectedItems: _allergies,
                    onChanged: (items) => setState(() => _allergies = items),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Emergency Contact
              _buildSectionCard(
                languageService.translate('emergency_contact'),
                [
                  _buildTextField(
                    controller: _emergencyNameController,
                    label: languageService.translate('name'),
                    validator: (value) => value?.isEmpty == true 
                        ? languageService.translate('emergency_name_required') : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emergencyPhoneController,
                    label: languageService.translate('phone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value?.isEmpty == true 
                        ? languageService.translate('emergency_phone_required') : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emergencyRelationController,
                    label: languageService.translate('relation'),
                    validator: (value) => value?.isEmpty == true 
                        ? languageService.translate('relation_required') : null,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Preferences
              _buildSectionCard(
                languageService.translate('preferences'),
                [
                  _buildDropdown(
                    value: _selectedLanguage,
                    items: _languages,
                    label: languageService.translate('preferred_language'),
                    onChanged: (value) => setState(() => _selectedLanguage = value!),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    languageService.translate('save'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildMultiSelectChips({
    required String label,
    required List<String> items,
    required List<String> selectedItems,
    required void Function(List<String>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onChanged([...selectedItems, item]);
                } else {
                  onChanged(selectedItems.where((i) => i != item).toList());
                }
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[600],
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final profile = UserProfile(
        id: widget.profile?.id,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        bloodGroup: _selectedBloodGroup,
        medicalConditions: _medicalConditions,
        allergies: _allergies,
        preferredLanguage: _selectedLanguage,
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim(),
        emergencyContactRelation: _emergencyRelationController.text.trim(),
        lastUpdated: DateTime.now(),
        createdAt: widget.profile?.createdAt ?? DateTime.now(),
      );

      if (widget.profile == null) {
        await _dbHelper.insertUserProfile(profile);
      } else {
        await _dbHelper.updateUserProfile(profile);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.profile == null 
                ? 'Profile created successfully!'
                : 'Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
