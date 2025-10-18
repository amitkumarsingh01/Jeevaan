class EmergencyContact {
  final int? id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final DateTime createdAt;
  final bool isPrimary;

  EmergencyContact({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    required this.createdAt,
    this.isPrimary = false,
  });

  // Convert EmergencyContact object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_primary': isPrimary ? 1 : 0,
    };
  }

  // Create EmergencyContact object from Map retrieved from database
  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phone_number'],
      relationship: map['relationship'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isPrimary: map['is_primary'] == 1,
    );
  }

  // Create a copy of EmergencyContact with updated fields
  EmergencyContact copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    DateTime? createdAt,
    bool? isPrimary,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      createdAt: createdAt ?? this.createdAt,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  String toString() {
    return 'EmergencyContact{id: $id, name: $name, phoneNumber: $phoneNumber, relationship: $relationship, isPrimary: $isPrimary}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyContact &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.relationship == relationship &&
        other.createdAt == createdAt &&
        other.isPrimary == isPrimary;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        relationship.hashCode ^
        createdAt.hashCode ^
        isPrimary.hashCode;
  }
}
