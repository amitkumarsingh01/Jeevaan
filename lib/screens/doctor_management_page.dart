import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../database/database_helper.dart';

class DoctorManagementPage extends StatefulWidget {
  const DoctorManagementPage({super.key});

  @override
  State<DoctorManagementPage> createState() => _DoctorManagementPageState();
}

class _DoctorManagementPageState extends State<DoctorManagementPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSpecialization = 'All';

  final List<String> _specializations = [
    'All',
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Psychiatry',
    'Ophthalmology',
    'Dentistry',
    'General Medicine',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final doctors = await _dbHelper.getActiveDoctors();
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddDoctorDialog() {
    showDialog(
      context: context,
      builder: (context) => _DoctorDialog(
        onSave: (doctor) async {
          await _dbHelper.insertDoctor(doctor);
          _loadDoctors();
        },
      ),
    );
  }

  void _showEditDoctorDialog(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => _DoctorDialog(
        doctor: doctor,
        onSave: (updatedDoctor) async {
          await _dbHelper.updateDoctor(updatedDoctor);
          _loadDoctors();
        },
      ),
    );
  }

  void _deleteDoctor(Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Doctor'),
        content: Text('Are you sure you want to delete Dr. ${doctor.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbHelper.deleteDoctor(doctor.id!);
              _loadDoctors();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleDoctorStatus(Doctor doctor) async {
    final newStatus = !doctor.isActive;
    await _dbHelper.toggleDoctorStatus(doctor.id!, newStatus);
    _loadDoctors();
  }

  List<Doctor> get _filteredDoctors {
    List<Doctor> filtered = _doctors;

    // Filter by specialization
    if (_selectedSpecialization != 'All') {
      filtered = filtered.where((doctor) => doctor.specialization == _selectedSpecialization).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((doctor) =>
          doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doctor.specialization.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doctor.clinicName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Management'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddDoctorDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search doctors...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Specialization Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _specializations.map((specialization) {
                      final isSelected = _selectedSpecialization == specialization;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(specialization),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSpecialization = specialization;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Doctors List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 80,
                              color: Colors.blue[300],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No Doctors Found',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Add doctors to get started',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton.icon(
                              onPressed: _showAddDoctorDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Doctor'),
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
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _filteredDoctors[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  doctor.specializationIcon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              title: Text(
                                'Dr. ${doctor.name}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    doctor.specialization,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctor.clinicName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctor.formattedFee,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctor.formattedRating,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.amber[600],
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _toggleDoctorStatus(doctor),
                                    icon: Icon(
                                      doctor.isActive ? Icons.visibility : Icons.visibility_off,
                                      color: doctor.isActive ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _showEditDoctorDialog(doctor);
                                          break;
                                        case 'delete':
                                          _deleteDoctor(doctor);
                                          break;
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDoctorDialog,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _DoctorDialog extends StatefulWidget {
  final Doctor? doctor;
  final Function(Doctor) onSave;

  const _DoctorDialog({
    this.doctor,
    required this.onSave,
  });

  @override
  State<_DoctorDialog> createState() => _DoctorDialogState();
}

class _DoctorDialogState extends State<_DoctorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _clinicController = TextEditingController();
  final _feeController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _bioController = TextEditingController();
  
  List<String> _selectedDays = [];
  bool _isActive = true;

  final List<String> _specializations = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Psychiatry',
    'Ophthalmology',
    'Dentistry',
    'General Medicine',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _nameController.text = widget.doctor!.name;
      _specializationController.text = widget.doctor!.specialization;
      _qualificationController.text = widget.doctor!.qualification;
      _phoneController.text = widget.doctor!.phoneNumber;
      _emailController.text = widget.doctor!.email;
      _addressController.text = widget.doctor!.address;
      _clinicController.text = widget.doctor!.clinicName;
      _feeController.text = widget.doctor!.consultationFee.toString();
      _workingHoursController.text = widget.doctor!.workingHours;
      _bioController.text = widget.doctor!.bio ?? '';
      _selectedDays = List.from(widget.doctor!.availableDays);
      _isActive = widget.doctor!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _qualificationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _clinicController.dispose();
    _feeController.dispose();
    _workingHoursController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveDoctor() {
    if (_formKey.currentState!.validate() && _selectedDays.isNotEmpty) {
      final doctor = Doctor(
        id: widget.doctor?.id,
        name: _nameController.text.trim(),
        specialization: _specializationController.text.trim(),
        qualification: _qualificationController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        clinicName: _clinicController.text.trim(),
        consultationFee: double.tryParse(_feeController.text) ?? 0.0,
        workingHours: _workingHoursController.text.trim(),
        availableDays: _selectedDays,
        bio: _bioController.text.trim(),
        isActive: _isActive,
        createdAt: widget.doctor?.createdAt ?? DateTime.now(),
        rating: widget.doctor?.rating ?? 0.0,
        reviewCount: widget.doctor?.reviewCount ?? 0,
      );
      
      widget.onSave(doctor);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.doctor == null ? 'Add Doctor' : 'Edit Doctor'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter doctor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _specializationController.text.isNotEmpty ? _specializationController.text : null,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                items: _specializations.map((specialization) {
                  return DropdownMenuItem(
                    value: specialization,
                    child: Text(specialization),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _specializationController.text = value;
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select specialization';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(
                  labelText: 'Qualification',
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter qualification';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _clinicController,
                decoration: const InputDecoration(
                  labelText: 'Clinic Name',
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter clinic name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _feeController,
                decoration: const InputDecoration(
                  labelText: 'Consultation Fee',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter consultation fee';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _workingHoursController,
                decoration: const InputDecoration(
                  labelText: 'Working Hours',
                  prefixIcon: Icon(Icons.access_time),
                  hintText: 'e.g., 9:00 AM - 5:00 PM',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter working hours';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Days of Week Selection
              const Text('Available Days:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                  final isSelected = _selectedDays.contains(index.toString());
                  return FilterChip(
                    label: Text(dayNames[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(index.toString());
                        } else {
                          _selectedDays.remove(index.toString());
                        }
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio (Optional)',
                  prefixIcon: Icon(Icons.info),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              
              CheckboxListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value ?? true;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveDoctor,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
          child: Text(widget.doctor == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
