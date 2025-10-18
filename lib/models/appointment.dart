enum AppointmentStatus {
  scheduled('Scheduled', '📅'),
  confirmed('Confirmed', '✅'),
  completed('Completed', '✅'),
  cancelled('Cancelled', '❌'),
  rescheduled('Rescheduled', '🔄');

  const AppointmentStatus(this.displayName, this.icon);
  
  final String displayName;
  final String icon;
}

enum AppointmentType {
  consultation('Consultation', '🩺'),
  followUp('Follow-up', '🔄'),
  checkup('Check-up', '🔍'),
  emergency('Emergency', '🚨'),
  surgery('Surgery', '🏥');

  const AppointmentType(this.displayName, this.icon);
  
  final String displayName;
  final String icon;
}

class Appointment {
  final int? id;
  final int doctorId;
  final String patientName;
  final String patientPhone;
  final String patientEmail;
  final DateTime appointmentDate;
  final String appointmentTime;
  final AppointmentType type;
  final AppointmentStatus status;
  final String? reason;
  final String? notes;
  final double? fee;
  final DateTime createdAt;
  final DateTime? reminderSentAt;
  final String? prescription;
  final String? diagnosis;

  Appointment({
    this.id,
    required this.doctorId,
    required this.patientName,
    required this.patientPhone,
    required this.patientEmail,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.type,
    this.status = AppointmentStatus.scheduled,
    this.reason,
    this.notes,
    this.fee,
    required this.createdAt,
    this.reminderSentAt,
    this.prescription,
    this.diagnosis,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'patient_email': patientEmail,
      'appointment_date': appointmentDate.millisecondsSinceEpoch,
      'appointment_time': appointmentTime,
      'type': type.name,
      'status': status.name,
      'reason': reason,
      'notes': notes,
      'fee': fee,
      'created_at': createdAt.millisecondsSinceEpoch,
      'reminder_sent_at': reminderSentAt?.millisecondsSinceEpoch,
      'prescription': prescription,
      'diagnosis': diagnosis,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      doctorId: map['doctor_id'],
      patientName: map['patient_name'],
      patientPhone: map['patient_phone'],
      patientEmail: map['patient_email'],
      appointmentDate: DateTime.fromMillisecondsSinceEpoch(map['appointment_date']),
      appointmentTime: map['appointment_time'],
      type: AppointmentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AppointmentType.consultation,
      ),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      reason: map['reason'],
      notes: map['notes'],
      fee: map['fee']?.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      reminderSentAt: map['reminder_sent_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['reminder_sent_at'])
          : null,
      prescription: map['prescription'],
      diagnosis: map['diagnosis'],
    );
  }

  Appointment copyWith({
    int? id,
    int? doctorId,
    String? patientName,
    String? patientPhone,
    String? patientEmail,
    DateTime? appointmentDate,
    String? appointmentTime,
    AppointmentType? type,
    AppointmentStatus? status,
    String? reason,
    String? notes,
    double? fee,
    DateTime? createdAt,
    DateTime? reminderSentAt,
    String? prescription,
    String? diagnosis,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientEmail: patientEmail ?? this.patientEmail,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      type: type ?? this.type,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      fee: fee ?? this.fee,
      createdAt: createdAt ?? this.createdAt,
      reminderSentAt: reminderSentAt ?? this.reminderSentAt,
      prescription: prescription ?? this.prescription,
      diagnosis: diagnosis ?? this.diagnosis,
    );
  }

  // Get formatted appointment date
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
    
    if (appointmentDay.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (appointmentDay.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    } else if (appointmentDay.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}';
    }
  }

  // Get formatted appointment time
  String get formattedTime {
    return appointmentTime;
  }

  // Get formatted date and time
  String get formattedDateTime {
    return '$formattedDate at $formattedTime';
  }

  // Check if appointment is today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
    return appointmentDay.isAtSameMomentAs(today);
  }

  // Check if appointment is upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    return appointmentDate.isAfter(now);
  }

  // Check if appointment is past
  bool get isPast {
    final now = DateTime.now();
    return appointmentDate.isBefore(now);
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'blue';
      case AppointmentStatus.confirmed:
        return 'green';
      case AppointmentStatus.completed:
        return 'green';
      case AppointmentStatus.cancelled:
        return 'red';
      case AppointmentStatus.rescheduled:
        return 'orange';
    }
  }

  // Get formatted fee
  String get formattedFee {
    if (fee == null) return 'Not set';
    return '₹${fee!.toStringAsFixed(0)}';
  }

  // Check if reminder should be sent
  bool shouldSendReminder() {
    if (reminderSentAt != null) return false;
    if (status == AppointmentStatus.cancelled) return false;
    
    final now = DateTime.now();
    final appointmentDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.parse(appointmentTime.split(':')[0]),
      int.parse(appointmentTime.split(':')[1]),
    );
    
    // Send reminder 24 hours before appointment
    final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
    return now.isAfter(reminderTime) && now.isBefore(appointmentDateTime);
  }

  @override
  String toString() {
    return 'Appointment{id: $id, patientName: $patientName, appointmentDate: $formattedDate, appointmentTime: $appointmentTime}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
