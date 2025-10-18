import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../database/database_helper.dart';

class EmergencyContactPage extends StatefulWidget {
  const EmergencyContactPage({super.key});

  @override
  State<EmergencyContactPage> createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<EmergencyContact> _contacts = [];
  EmergencyContact? _primaryContact;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _dbHelper.getAllEmergencyContacts();
    final primaryContact = await _dbHelper.getPrimaryEmergencyContact();
    
    setState(() {
      _contacts = contacts;
      _primaryContact = primaryContact;
    });
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (context) => _ContactDialog(
        onSave: (contact) async {
          await _dbHelper.insertEmergencyContact(contact);
          if (mounted) {
            _loadContacts();
          }
        },
      ),
    );
  }

  void _showEditContactDialog(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => _ContactDialog(
        contact: contact,
        onSave: (updatedContact) async {
          await _dbHelper.updateEmergencyContact(updatedContact);
          if (mounted) {
            _loadContacts();
          }
        },
      ),
    );
  }

  void _deleteContact(EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _dbHelper.deleteEmergencyContact(contact.id!);
              _loadContacts();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _setPrimaryContact(EmergencyContact contact) async {
    await _dbHelper.setPrimaryEmergencyContact(contact.id!);
    _loadContacts();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${contact.name} set as primary emergency contact')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddContactDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _contacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emergency,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Emergency Contacts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Add emergency contacts to get help quickly',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _showAddContactDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Emergency Contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
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
                // Primary Contact Card
                if (_primaryContact != null)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.red[100],
                          child: Icon(
                            Icons.star,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Primary Emergency Contact',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _primaryContact!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _primaryContact!.phoneNumber,
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                _primaryContact!.relationship,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // This will be handled by the emergency help page
                          },
                          icon: Icon(
                            Icons.phone,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Contacts List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: contact.isPrimary
                                ? Colors.red[100]
                                : Colors.blue[100],
                            child: Icon(
                              contact.isPrimary ? Icons.star : Icons.person,
                              color: contact.isPrimary
                                  ? Colors.red[600]
                                  : Colors.blue[600],
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: TextStyle(
                              fontWeight: contact.isPrimary
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contact.phoneNumber),
                              Text(
                                contact.relationship,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'set_primary',
                                enabled: !contact.isPrimary,
                                child: const Text('Set as Primary'),
                              ),
                              PopupMenuItem(
                                value: 'edit',
                                child: const Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: const Text('Delete'),
                              ),
                            ],
                            onSelected: (value) {
                              switch (value) {
                                case 'set_primary':
                                  _setPrimaryContact(contact);
                                  break;
                                case 'edit':
                                  _showEditContactDialog(contact);
                                  break;
                                case 'delete':
                                  _deleteContact(contact);
                                  break;
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: Colors.red[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ContactDialog extends StatefulWidget {
  final EmergencyContact? contact;
  final Function(EmergencyContact) onSave;

  const _ContactDialog({
    this.contact,
    required this.onSave,
  });

  @override
  State<_ContactDialog> createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _phoneController.text = widget.contact!.phoneNumber;
      _relationshipController.text = widget.contact!.relationship;
      _isPrimary = widget.contact!.isPrimary;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final contact = EmergencyContact(
        id: widget.contact?.id,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
        createdAt: widget.contact?.createdAt ?? DateTime.now(),
        isPrimary: _isPrimary,
      );
      
      widget.onSave(contact);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
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
                  return 'Please enter a phone number';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                prefixIcon: Icon(Icons.group),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter relationship';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Set as Primary Emergency Contact'),
              value: _isPrimary,
              onChanged: (value) {
                setState(() {
                  _isPrimary = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveContact,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
          ),
          child: Text(widget.contact == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
