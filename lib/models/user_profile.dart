class UserProfile {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final String bloodGroup;
  final List<String> medicalConditions;
  final List<String> allergies;
  final String preferredLanguage;
  final String phoneNumber;
  final String email;
  final String address;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyContactRelation;
  final DateTime? lastUpdated;
  final DateTime createdAt;

  const UserProfile({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.medicalConditions,
    required this.allergies,
    required this.preferredLanguage,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.emergencyContactRelation,
    this.lastUpdated,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'blood_group': bloodGroup,
      'medical_conditions': medicalConditions.join(','),
      'allergies': allergies.join(','),
      'preferred_language': preferredLanguage,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      'last_updated': lastUpdated?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      bloodGroup: map['blood_group'],
      medicalConditions: map['medical_conditions']?.split(',') ?? [],
      allergies: map['allergies']?.split(',') ?? [],
      preferredLanguage: map['preferred_language'],
      phoneNumber: map['phone_number'],
      email: map['email'],
      address: map['address'],
      emergencyContactName: map['emergency_contact_name'],
      emergencyContactPhone: map['emergency_contact_phone'],
      emergencyContactRelation: map['emergency_contact_relation'],
      lastUpdated: map['last_updated'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_updated'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  UserProfile copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    String? bloodGroup,
    List<String>? medicalConditions,
    List<String>? allergies,
    String? preferredLanguage,
    String? phoneNumber,
    String? email,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
