import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../database/database_helper.dart';
import '../services/medication_reminder_service.dart';
import '../services/notification_service.dart';
import '../widgets/voice_input_button.dart';

class MedicationManagementPage extends StatefulWidget {
  const MedicationManagementPage({super.key});

  @override
  State<MedicationManagementPage> createState() => _MedicationManagementPageState();
}

class _MedicationManagementPageState extends State<MedicationManagementPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Medication> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      setState(() {
        // Show loading state if needed
      });
      final medications = await _dbHelper.getAllMedications();
      print('Loaded ${medications.length} medications');
      setState(() {
        _medications = medications;
      });
    } catch (e) {
      print('Error loading medications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading medications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        onSave: (medication) async {
          try {
            print('Saving medication: ${medication.name}');
            final id = await _dbHelper.insertMedication(medication);
            print('Medication saved with ID: $id');
            final newMedication = medication.copyWith(id: id);
            await MedicationReminderService.scheduleMedicationReminders(newMedication);
            
            // Send notification and email
            await NotificationService.notifyMedicationAdded(
              medicationName: medication.name,
            );
            
            if (mounted) {
              Navigator.pop(context);
              _loadMedications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medication added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('Error saving medication: $e');
            if (mounted) {
              String errorMessage = 'Error saving medication';
              if (e.toString().contains('exact_alarms_not_permitted')) {
                errorMessage = 'Medication saved, but reminder permission needed. Please enable "Schedule exact alarms" in Settings.';
              } else {
                errorMessage = 'Error saving medication: ${e.toString().split(':').first}';
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditMedicationDialog(Medication medication) {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        medication: medication,
        onSave: (updatedMedication) async {
          try {
            print('Updating medication: ${updatedMedication.name}');
            await _dbHelper.updateMedication(updatedMedication);
            await MedicationReminderService.scheduleMedicationReminders(updatedMedication);
            
            // Send notification and email
            await NotificationService.notifyMedicationUpdated(
              medicationName: updatedMedication.name,
            );
            
            if (mounted) {
              Navigator.pop(context);
              _loadMedications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medication updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('Error updating medication: $e');
            if (mounted) {
              String errorMessage = 'Error updating medication';
              if (e.toString().contains('exact_alarms_not_permitted')) {
                errorMessage = 'Medication updated, but reminder permission needed. Please enable "Schedule exact alarms" in Settings.';
              } else {
                errorMessage = 'Error updating medication: ${e.toString().split(':').first}';
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _deleteMedication(Medication medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete "${medication.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final medicationName = medication.name;
                
                // Cancel reminders first (pass medication object for reliable cancellation)
                await MedicationReminderService.cancelMedicationReminders(medication.id!, medication: medication);
                
                // Delete from database
                final result = await _dbHelper.deleteMedication(medication.id!);
                
                if (result > 0) {
                  // Send notification and email
                  await NotificationService.notifyMedicationDeleted(
                    medicationName: medicationName,
                  );
                  
                  // Reload medications
                  await _loadMedications();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$medicationName deleted successfully'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to delete medication. Please try again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                print('Error deleting medication: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting medication: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleMedicationStatus(Medication medication) async {
    try {
      final newStatus = !medication.isActive;
      print('Toggling medication ${medication.name} to ${newStatus ? "active" : "inactive"}');
      
      await _dbHelper.toggleMedicationStatus(medication.id!, newStatus);
      
      // Create updated medication with new status
      final updatedMedication = medication.copyWith(isActive: newStatus);
      
      if (newStatus) {
        await MedicationReminderService.scheduleMedicationReminders(updatedMedication);
      } else {
        await MedicationReminderService.cancelMedicationReminders(medication.id!, medication: medication);
      }
      
      // Reload medications to reflect the change
      await _loadMedications();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medication ${newStatus ? "enabled" : "disabled"} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error toggling medication status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating medication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _markAsTaken(Medication medication) async {
    await _dbHelper.markMedicationTaken(medication.id!);
    
    // Send notification and email
    await NotificationService.notifyMedicationTaken(
      medicationName: medication.name,
    );
    
    _loadMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Management'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddMedicationDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _medications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication,
                    size: 80,
                    color: Colors.blue[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Medications Added',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Add your medications to get reminders',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _showAddMedicationDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Medication'),
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
          : Column(
              children: [
                // Today's Medications
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.today, color: Colors.blue[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Medications',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                            Text(
                              '${_medications.where((m) => m.shouldTakeToday()).length} medications scheduled',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Medications List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _medications.length,
                    itemBuilder: (context, index) {
                      final medication = _medications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: medication.isActive 
                                ? Colors.blue[100] 
                                : Colors.grey[300],
                            child: Icon(
                              Icons.medication,
                              color: medication.isActive 
                                  ? Colors.blue[600] 
                                  : Colors.grey[600],
                            ),
                          ),
                          title: Text(
                            medication.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: medication.isActive 
                                  ? Colors.black 
                                  : Colors.grey[600],
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${medication.dosage} - ${medication.instructions}'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    medication.formattedReminderTimes.join(', '),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    medication.formattedDaysOfWeek.join(', '),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              if (medication.streakCount > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      size: 16,
                                      color: Colors.orange[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${medication.streakCount} day streak',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (medication.isActive && medication.shouldTakeToday() && !medication.wasTakenToday())
                                IconButton(
                                  onPressed: () => _markAsTaken(medication),
                                  icon: const Icon(Icons.check_circle_outline),
                                  color: Colors.green[600],
                                ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: const Text('Edit'),
                                  ),
                                  // PopupMenuItem(
                                  //   value: 'toggle',
                                  //   child: Text(medication.isActive ? 'Disable' : 'Enable'),
                                  // ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: const Text('Delete'),
                                  ),
                                ],
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _showEditMedicationDialog(medication);
                                      break;
                                    case 'toggle':
                                      _toggleMedicationStatus(medication);
                                      break;
                                    case 'delete':
                                      _deleteMedication(medication);
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
        onPressed: _showAddMedicationDialog,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _MedicationDialog extends StatefulWidget {
  final Medication? medication;
  final Function(Medication) onSave;

  const _MedicationDialog({
    this.medication,
    required this.onSave,
  });

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  List<int> _selectedDays = [];
  List<int> _selectedTimes = [];
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _dosageController.text = widget.medication!.dosage;
      _instructionsController.text = widget.medication!.instructions;
      _selectedDays = List.from(widget.medication!.daysOfWeek);
      _selectedTimes = List.from(widget.medication!.reminderTimes);
      _isActive = widget.medication!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one reminder time'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final medication = Medication(
        id: widget.medication?.id,
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        instructions: _instructionsController.text.trim(),
        reminderTimes: _selectedTimes,
        daysOfWeek: _selectedDays,
        isActive: _isActive,
        createdAt: widget.medication?.createdAt ?? DateTime.now(),
        lastTaken: widget.medication?.lastTaken,
        streakCount: widget.medication?.streakCount ?? 0,
      );
      
      // Don't close dialog here - let onSave callback handle it
      widget.onSave(medication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Medication Name',
                  prefixIcon: const Icon(Icons.medication),
                  suffixIcon: VoiceInputButton(
                    onResult: (text) {
                      setState(() {
                        _nameController.text = text;
                      });
                    },
                    color: Colors.blue,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'Dosage',
                  prefixIcon: const Icon(Icons.straighten),
                  suffixIcon: VoiceInputButton(
                    onResult: (text) {
                      setState(() {
                        _dosageController.text = text;
                      });
                    },
                    color: Colors.blue,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: InputDecoration(
                  labelText: 'Instructions',
                  prefixIcon: const Icon(Icons.info),
                  suffixIcon: VoiceInputButton(
                    onResult: (text) {
                      setState(() {
                        _instructionsController.text = text;
                      });
                    },
                    color: Colors.blue,
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Days of Week Selection
              const Text('Days of Week:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                  final isSelected = _selectedDays.contains(index);
                  return FilterChip(
                    label: Text(dayNames[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(index);
                        } else {
                          _selectedDays.remove(index);
                        }
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              
              // Time Selection
              const Text('Reminder Times:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  '8:00 AM', '12:00 PM', '6:00 PM', '9:00 PM'
                ].map((time) {
                  final minutes = _getMinutesFromTime(time);
                  final isSelected = _selectedTimes.contains(minutes);
                  return FilterChip(
                    label: Text(time),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTimes.add(minutes);
                        } else {
                          _selectedTimes.remove(minutes);
                        }
                      });
                    },
                  );
                }).toList(),
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
          onPressed: _saveMedication,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
          ),
          child: Text(widget.medication == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  int _getMinutesFromTime(String time) {
    final parts = time.split(' ');
    final timePart = parts[0];
    final period = parts[1];
    final hourMinute = timePart.split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    
    if (period == 'PM' && hour != 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;
    
    return hour * 60 + minute;
  }
}
