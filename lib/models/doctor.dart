class Doctor {
  final int? id;
  final String name;
  final String specialization;
  final String qualification;
  final String phoneNumber;
  final String email;
  final String address;
  final String clinicName;
  final double consultationFee;
  final String workingHours;
  final List<String> availableDays; // Days of week (0-6)
  final String? profileImage;
  final double rating;
  final int reviewCount;
  final String? bio;
  final DateTime createdAt;
  final bool isActive;

  Doctor({
    this.id,
    required this.name,
    required this.specialization,
    required this.qualification,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.clinicName,
    required this.consultationFee,
    required this.workingHours,
    required this.availableDays,
    this.profileImage,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.bio,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'qualification': qualification,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'clinic_name': clinicName,
      'consultation_fee': consultationFee,
      'working_hours': workingHours,
      'available_days': availableDays.join(','),
      'profile_image': profileImage,
      'rating': rating,
      'review_count': reviewCount,
      'bio': bio,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      name: map['name'],
      specialization: map['specialization'],
      qualification: map['qualification'],
      phoneNumber: map['phone_number'],
      email: map['email'],
      address: map['address'],
      clinicName: map['clinic_name'],
      consultationFee: map['consultation_fee']?.toDouble() ?? 0.0,
      workingHours: map['working_hours'],
      availableDays: map['available_days'] != null 
          ? map['available_days'].split(',').toList()
          : [],
      profileImage: map['profile_image'],
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewCount: map['review_count'] ?? 0,
      bio: map['bio'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isActive: map['is_active'] == 1,
    );
  }

  Doctor copyWith({
    int? id,
    String? name,
    String? specialization,
    String? qualification,
    String? phoneNumber,
    String? email,
    String? address,
    String? clinicName,
    double? consultationFee,
    String? workingHours,
    List<String>? availableDays,
    String? profileImage,
    double? rating,
    int? reviewCount,
    String? bio,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      qualification: qualification ?? this.qualification,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      clinicName: clinicName ?? this.clinicName,
      consultationFee: consultationFee ?? this.consultationFee,
      workingHours: workingHours ?? this.workingHours,
      availableDays: availableDays ?? this.availableDays,
      profileImage: profileImage ?? this.profileImage,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Get formatted available days
  List<String> get formattedAvailableDays {
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return availableDays.map((day) => dayNames[int.parse(day)]).toList();
  }

  // Get formatted consultation fee
  String get formattedFee {
    return '₹${consultationFee.toStringAsFixed(0)}';
  }

  // Get formatted rating
  String get formattedRating {
    if (rating == 0.0) {
      return 'No rating';
    }
    return '${rating.toStringAsFixed(1)} ⭐ (${reviewCount} reviews)';
  }

  // Check if doctor is available on a specific day
  bool isAvailableOnDay(int dayOfWeek) {
    return availableDays.contains(dayOfWeek.toString());
  }

  // Get specialization icon
  String get specializationIcon {
    switch (specialization.toLowerCase()) {
      case 'cardiology':
        return '❤️';
      case 'dermatology':
        return '🧴';
      case 'neurology':
        return '🧠';
      case 'orthopedics':
        return '🦴';
      case 'pediatrics':
        return '👶';
      case 'gynecology':
        return '👩';
      case 'psychiatry':
        return '🧘';
      case 'ophthalmology':
        return '👁️';
      case 'dentistry':
        return '🦷';
      case 'general medicine':
        return '🩺';
      default:
        return '👨‍⚕️';
    }
  }

  @override
  String toString() {
    return 'Doctor{id: $id, name: $name, specialization: $specialization}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
