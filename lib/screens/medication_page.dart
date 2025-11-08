import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../database/database_helper.dart';
import '../services/medication_reminder_service.dart';
import 'medication_management_page.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Medication> _todayMedications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayMedications();
  }

  Future<void> _loadTodayMedications() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get all active medications, not just today's
      final medications = await _dbHelper.getActiveMedications();
      setState(() {
        _todayMedications = medications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading medications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsTaken(Medication medication) async {
    await _dbHelper.markMedicationTaken(medication.id!);
    await MedicationReminderService.showMedicationTakenDialog(medication);
    _loadTodayMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicationManagementPage(),
                ),
              ).then((_) => _loadTodayMedications());
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todayMedications.isEmpty
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
                        'No Medications Today',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'You have no active medications',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MedicationManagementPage(),
                            ),
                          ).then((_) => _loadTodayMedications());
                        },
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
                    // Header
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[50]!, Colors.blue[100]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue[600],
                            child: const Icon(
                              Icons.medication,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Active Medications',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                                Text(
                                  '${_todayMedications.length} active medications',
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
                    
                    // Medications List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _todayMedications.length,
                        itemBuilder: (context, index) {
                          final medication = _todayMedications[index];
                          final isTaken = medication.wasTakenToday();
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isTaken ? Colors.green[50] : Colors.white,
                                border: Border.all(
                                  color: isTaken ? Colors.green[200]! : Colors.grey[200]!,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: isTaken 
                                      ? Colors.green[100] 
                                      : Colors.blue[100],
                                  child: Icon(
                                    isTaken ? Icons.check_circle : Icons.medication,
                                    color: isTaken 
                                        ? Colors.green[600] 
                                        : Colors.blue[600],
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  medication.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isTaken ? Colors.green[800] : Colors.black,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'Dosage: ${medication.dosage}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isTaken ? Colors.green[600] : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Instructions: ${medication.instructions}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isTaken ? Colors.green[600] : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          size: 16,
                                          color: isTaken ? Colors.green[600] : Colors.blue[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Times: ${medication.formattedReminderTimes.join(', ')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isTaken ? Colors.green[600] : Colors.blue[600],
                                            fontWeight: FontWeight.w500,
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
                                trailing: isTaken
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green[100],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Taken',
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    : ElevatedButton.icon(
                                        onPressed: () => _markAsTaken(medication),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Mark Taken'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[600],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicationManagementPage(),
            ),
          ).then((_) => _loadTodayMedications());
        },
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Manage Medications', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
