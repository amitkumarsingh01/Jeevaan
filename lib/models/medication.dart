class Medication {
  final int? id;
  final String name;
  final String dosage;
  final String instructions;
  final List<int> reminderTimes; // List of minutes from midnight (e.g., 480 for 8:00 AM)
  final List<int> daysOfWeek; // 0-6 (Sunday-Saturday)
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastTaken;
  final int streakCount; // Days in a row taken
  final String? voiceNote; // Optional voice note for instructions

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.reminderTimes,
    required this.daysOfWeek,
    this.isActive = true,
    required this.createdAt,
    this.lastTaken,
    this.streakCount = 0,
    this.voiceNote,
  });

  // Convert Medication object to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'instructions': instructions,
      'reminder_times': reminderTimes.join(','),
      'days_of_week': daysOfWeek.join(','),
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_taken': lastTaken?.millisecondsSinceEpoch,
      'streak_count': streakCount,
      'voice_note': voiceNote,
    };
  }

  // Create Medication object from Map retrieved from database
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      instructions: map['instructions'],
      reminderTimes: map['reminder_times'] != null 
          ? map['reminder_times'].split(',').map((e) => int.parse(e)).toList()
          : [],
      daysOfWeek: map['days_of_week'] != null 
          ? map['days_of_week'].split(',').map((e) => int.parse(e)).toList()
          : [],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      lastTaken: map['last_taken'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_taken'])
          : null,
      streakCount: map['streak_count'] ?? 0,
      voiceNote: map['voice_note'],
    );
  }

  // Create a copy of Medication with updated fields
  Medication copyWith({
    int? id,
    String? name,
    String? dosage,
    String? instructions,
    List<int>? reminderTimes,
    List<int>? daysOfWeek,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastTaken,
    int? streakCount,
    String? voiceNote,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastTaken: lastTaken ?? this.lastTaken,
      streakCount: streakCount ?? this.streakCount,
      voiceNote: voiceNote ?? this.voiceNote,
    );
  }

  // Get formatted reminder times
  List<String> get formattedReminderTimes {
    return reminderTimes.map((minutes) {
      final hour = minutes ~/ 60;
      final minute = minutes % 60;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    }).toList();
  }

  // Get formatted days of week
  List<String> get formattedDaysOfWeek {
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return daysOfWeek.map((day) => dayNames[day]).toList();
  }

  // Check if medication should be taken today
  bool shouldTakeToday() {
    if (!isActive) return false;
    final today = DateTime.now().weekday % 7; // Convert to 0-6 format
    return daysOfWeek.contains(today);
  }

  // Check if medication was taken today
  bool wasTakenToday() {
    if (lastTaken == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastTakenDay = DateTime(lastTaken!.year, lastTaken!.month, lastTaken!.day);
    return today.isAtSameMomentAs(lastTakenDay);
  }

  @override
  String toString() {
    return 'Medication{id: $id, name: $name, dosage: $dosage, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medication &&
        other.id == id &&
        other.name == name &&
        other.dosage == dosage &&
        other.instructions == instructions &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        dosage.hashCode ^
        instructions.hashCode ^
        isActive.hashCode;
  }
}
