import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/emergency_contact.dart';
import '../models/medication.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/medicine.dart';
import '../models/order.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'jeevaan.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE TABLE emergency_contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        relationship TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        is_primary INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE medications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        instructions TEXT NOT NULL,
        reminder_times TEXT NOT NULL,
        days_of_week TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        last_taken INTEGER,
        streak_count INTEGER NOT NULL DEFAULT 0,
        voice_note TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE doctors(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        specialization TEXT NOT NULL,
        qualification TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        clinic_name TEXT NOT NULL,
        consultation_fee REAL NOT NULL,
        working_hours TEXT NOT NULL,
        available_days TEXT NOT NULL,
        profile_image TEXT,
        rating REAL NOT NULL DEFAULT 0.0,
        review_count INTEGER NOT NULL DEFAULT 0,
        bio TEXT,
        created_at INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    
    await db.execute('''
      CREATE TABLE appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctor_id INTEGER NOT NULL,
        patient_name TEXT NOT NULL,
        patient_phone TEXT NOT NULL,
        patient_email TEXT NOT NULL,
        appointment_date INTEGER NOT NULL,
        appointment_time TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'scheduled',
        reason TEXT,
        notes TEXT,
        fee REAL,
        created_at INTEGER NOT NULL,
        reminder_sent_at INTEGER,
        prescription TEXT,
        diagnosis TEXT,
        FOREIGN KEY (doctor_id) REFERENCES doctors (id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        generic_name TEXT NOT NULL,
        manufacturer TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        stock_quantity INTEGER NOT NULL,
        dosage_form TEXT NOT NULL,
        strength TEXT NOT NULL,
        image_url TEXT,
        requires_prescription INTEGER NOT NULL DEFAULT 0,
        side_effects TEXT,
        instructions TEXT,
        created_at INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT NOT NULL UNIQUE,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        customer_email TEXT NOT NULL,
        delivery_address TEXT NOT NULL,
        subtotal REAL NOT NULL,
        tax REAL NOT NULL,
        delivery_fee REAL NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        payment_status TEXT NOT NULL DEFAULT 'pending',
        payment_method TEXT,
        notes TEXT,
        order_date INTEGER NOT NULL,
        delivery_date INTEGER,
        tracking_number TEXT
      )
    ''');
    
    await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        medicine_id INTEGER NOT NULL,
        medicine_name TEXT NOT NULL,
        unit_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (medicine_id) REFERENCES medicines (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add medicines and orders tables
      await db.execute('''
        CREATE TABLE medicines(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          generic_name TEXT NOT NULL,
          manufacturer TEXT NOT NULL,
          category TEXT NOT NULL,
          description TEXT NOT NULL,
          price REAL NOT NULL,
          stock_quantity INTEGER NOT NULL,
          dosage_form TEXT NOT NULL,
          strength TEXT NOT NULL,
          image_url TEXT,
          requires_prescription INTEGER NOT NULL DEFAULT 0,
          side_effects TEXT,
          instructions TEXT,
          created_at INTEGER NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1
        )
      ''');
      
      await db.execute('''
        CREATE TABLE orders(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_number TEXT NOT NULL UNIQUE,
          customer_name TEXT NOT NULL,
          customer_phone TEXT NOT NULL,
          customer_email TEXT NOT NULL,
          delivery_address TEXT NOT NULL,
          subtotal REAL NOT NULL,
          tax REAL NOT NULL,
          delivery_fee REAL NOT NULL,
          total_amount REAL NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending',
          payment_status TEXT NOT NULL DEFAULT 'pending',
          payment_method TEXT,
          notes TEXT,
          order_date INTEGER NOT NULL,
          delivery_date INTEGER,
          tracking_number TEXT
        )
      ''');
      
      await db.execute('''
        CREATE TABLE order_items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id INTEGER NOT NULL,
          medicine_id INTEGER NOT NULL,
          medicine_name TEXT NOT NULL,
          unit_price REAL NOT NULL,
          quantity INTEGER NOT NULL,
          total_price REAL NOT NULL,
          FOREIGN KEY (order_id) REFERENCES orders (id),
          FOREIGN KEY (medicine_id) REFERENCES medicines (id)
        )
      ''');
    }
  }

  // Insert a new user
  Future<int> insertUser(User user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      throw Exception('Email already exists');
    }
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Get user by email and password (for login)
  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Update user
  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Emergency Contact Methods
  
  // Insert a new emergency contact
  Future<int> insertEmergencyContact(EmergencyContact contact) async {
    final db = await database;
    
    // If this is set as primary, remove primary status from others
    if (contact.isPrimary) {
      await db.update(
        'emergency_contacts',
        {'is_primary': 0},
        where: 'is_primary = ?',
        whereArgs: [1],
      );
    }
    
    return await db.insert('emergency_contacts', contact.toMap());
  }

  // Get all emergency contacts
  Future<List<EmergencyContact>> getAllEmergencyContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'emergency_contacts',
      orderBy: 'is_primary DESC, created_at ASC',
    );

    return List.generate(maps.length, (i) {
      return EmergencyContact.fromMap(maps[i]);
    });
  }

  // Get primary emergency contact
  Future<EmergencyContact?> getPrimaryEmergencyContact() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'emergency_contacts',
      where: 'is_primary = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return EmergencyContact.fromMap(maps.first);
    }
    return null;
  }

  // Update emergency contact
  Future<int> updateEmergencyContact(EmergencyContact contact) async {
    final db = await database;
    
    // If this is set as primary, remove primary status from others
    if (contact.isPrimary) {
      await db.update(
        'emergency_contacts',
        {'is_primary': 0},
        where: 'is_primary = ? AND id != ?',
        whereArgs: [1, contact.id],
      );
    }
    
    return await db.update(
      'emergency_contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  // Delete emergency contact
  Future<int> deleteEmergencyContact(int id) async {
    final db = await database;
    return await db.delete(
      'emergency_contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Set primary emergency contact
  Future<int> setPrimaryEmergencyContact(int id) async {
    final db = await database;
    
    // Remove primary status from all contacts
    await db.update(
      'emergency_contacts',
      {'is_primary': 0},
    );
    
    // Set the selected contact as primary
    return await db.update(
      'emergency_contacts',
      {'is_primary': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Medication Methods
  
  // Insert a new medication
  Future<int> insertMedication(Medication medication) async {
    final db = await database;
    return await db.insert('medications', medication.toMap());
  }

  // Get all medications
  Future<List<Medication>> getAllMedications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Medication.fromMap(maps[i]);
    });
  }

  // Get active medications
  Future<List<Medication>> getActiveMedications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medications',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Medication.fromMap(maps[i]);
    });
  }

  // Get medications for today
  Future<List<Medication>> getMedicationsForToday() async {
    final activeMedications = await getActiveMedications();
    final today = DateTime.now().weekday % 7; // Convert to 0-6 format
    
    return activeMedications.where((med) => med.daysOfWeek.contains(today)).toList();
  }

  // Update medication
  Future<int> updateMedication(Medication medication) async {
    final db = await database;
    return await db.update(
      'medications',
      medication.toMap(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  // Mark medication as taken
  Future<int> markMedicationTaken(int medicationId) async {
    final db = await database;
    final now = DateTime.now();
    
    // Update last taken time and increment streak
    return await db.rawUpdate('''
      UPDATE medications 
      SET last_taken = ?, 
          streak_count = streak_count + 1
      WHERE id = ?
    ''', [now.millisecondsSinceEpoch, medicationId]);
  }

  // Delete medication
  Future<int> deleteMedication(int id) async {
    final db = await database;
    return await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Toggle medication active status
  Future<int> toggleMedicationStatus(int id, bool isActive) async {
    final db = await database;
    return await db.update(
      'medications',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Doctor Methods
  
  // Insert a new doctor
  Future<int> insertDoctor(Doctor doctor) async {
    final db = await database;
    return await db.insert('doctors', doctor.toMap());
  }

  // Get all doctors
  Future<List<Doctor>> getAllDoctors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Doctor.fromMap(maps[i]);
    });
  }

  // Get active doctors
  Future<List<Doctor>> getActiveDoctors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'rating DESC, created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Doctor.fromMap(maps[i]);
    });
  }

  // Get doctors by specialization
  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'specialization = ? AND is_active = ?',
      whereArgs: [specialization, 1],
      orderBy: 'rating DESC',
    );

    return List.generate(maps.length, (i) {
      return Doctor.fromMap(maps[i]);
    });
  }

  // Get doctor by ID
  Future<Doctor?> getDoctorById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Doctor.fromMap(maps.first);
    }
    return null;
  }

  // Update doctor
  Future<int> updateDoctor(Doctor doctor) async {
    final db = await database;
    return await db.update(
      'doctors',
      doctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }

  // Delete doctor
  Future<int> deleteDoctor(int id) async {
    final db = await database;
    return await db.delete(
      'doctors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Toggle doctor active status
  Future<int> toggleDoctorStatus(int id, bool isActive) async {
    final db = await database;
    return await db.update(
      'doctors',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Appointment Methods
  
  // Insert a new appointment
  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  // Get all appointments
  Future<List<Appointment>> getAllAppointments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      orderBy: 'appointment_date DESC, appointment_time DESC',
    );

    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  // Get appointments by doctor
  Future<List<Appointment>> getAppointmentsByDoctor(int doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'appointment_date DESC, appointment_time DESC',
    );

    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  // Get upcoming appointments
  Future<List<Appointment>> getUpcomingAppointments() async {
    final db = await database;
    final now = DateTime.now();
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'appointment_date >= ? AND status != ?',
      whereArgs: [now.millisecondsSinceEpoch, AppointmentStatus.cancelled.name],
      orderBy: 'appointment_date ASC, appointment_time ASC',
    );

    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  // Get appointments for today
  Future<List<Appointment>> getTodayAppointments() async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'appointment_date >= ? AND appointment_date < ?',
      whereArgs: [today.millisecondsSinceEpoch, tomorrow.millisecondsSinceEpoch],
      orderBy: 'appointment_time ASC',
    );

    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  // Get appointments by status
  Future<List<Appointment>> getAppointmentsByStatus(AppointmentStatus status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'appointment_date DESC, appointment_time DESC',
    );

    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  // Update appointment
  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  // Update appointment status
  Future<int> updateAppointmentStatus(int id, AppointmentStatus status) async {
    final db = await database;
    return await db.update(
      'appointments',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Mark reminder as sent
  Future<int> markReminderSent(int appointmentId) async {
    final db = await database;
    return await db.update(
      'appointments',
      {'reminder_sent_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  // Delete appointment
  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get appointments needing reminders
  Future<List<Appointment>> getAppointmentsNeedingReminders() async {
    final appointments = await getUpcomingAppointments();
    return appointments.where((appointment) => appointment.shouldSendReminder()).toList();
  }

  // Medicine Methods
  
  // Insert a new medicine
  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    return await db.insert('medicines', medicine.toMap());
  }

  // Get all medicines
  Future<List<Medicine>> getAllMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Medicine.fromMap(maps[i]);
    });
  }

  // Get active medicines
  Future<List<Medicine>> getActiveMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Medicine.fromMap(maps[i]);
    });
  }

  // Get medicines by category
  Future<List<Medicine>> getMedicinesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'category = ? AND is_active = ?',
      whereArgs: [category, 1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Medicine.fromMap(maps[i]);
    });
  }

  // Get medicine by ID
  Future<Medicine?> getMedicineById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Medicine.fromMap(maps.first);
    }
    return null;
  }

  // Search medicines
  Future<List<Medicine>> searchMedicines(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicines',
      where: 'name LIKE ? OR generic_name LIKE ? AND is_active = ?',
      whereArgs: ['%$query%', '%$query%', 1],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Medicine.fromMap(maps[i]);
    });
  }

  // Update medicine
  Future<int> updateMedicine(Medicine medicine) async {
    final db = await database;
    return await db.update(
      'medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  // Update medicine stock
  Future<int> updateMedicineStock(int id, int newStock) async {
    final db = await database;
    return await db.update(
      'medicines',
      {'stock_quantity': newStock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete medicine
  Future<int> deleteMedicine(int id) async {
    final db = await database;
    return await db.delete(
      'medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Order Methods
  
  // Insert a new order
  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  // Insert order item
  Future<int> insertOrderItem(OrderItem orderItem) async {
    final db = await database;
    return await db.insert('order_items', orderItem.toMap());
  }

  // Get all orders
  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      orderBy: 'order_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  // Get orders by customer email
  Future<List<Order>> getOrdersByCustomer(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'customer_email = ?',
      whereArgs: [email],
      orderBy: 'order_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  // Get order by ID
  Future<Order?> getOrderById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Order.fromMap(maps.first);
    }
    return null;
  }

  // Get order items by order ID
  Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'id ASC',
    );

    return List.generate(maps.length, (i) {
      return OrderItem.fromMap(maps[i]);
    });
  }

  // Get orders by status
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'order_date DESC',
    );

    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  // Update order status
  Future<int> updateOrderStatus(int id, OrderStatus status) async {
    final db = await database;
    return await db.update(
      'orders',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update order payment status
  Future<int> updateOrderPaymentStatus(int id, PaymentStatus paymentStatus) async {
    final db = await database;
    return await db.update(
      'orders',
      {'payment_status': paymentStatus.name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update order tracking
  Future<int> updateOrderTracking(int id, String trackingNumber, DateTime? deliveryDate) async {
    final db = await database;
    return await db.update(
      'orders',
      {
        'tracking_number': trackingNumber,
        'delivery_date': deliveryDate?.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete order
  Future<int> deleteOrder(int id) async {
    final db = await database;
    
    // First delete order items
    await db.delete(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [id],
    );
    
    // Then delete order
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get order statistics
  Future<Map<String, int>> getOrderStats() async {
    final orders = await getAllOrders();
    
    return {
      'total': orders.length,
      'pending': orders.where((order) => order.status == OrderStatus.pending).length,
      'confirmed': orders.where((order) => order.status == OrderStatus.confirmed).length,
      'processing': orders.where((order) => order.status == OrderStatus.processing).length,
      'shipped': orders.where((order) => order.status == OrderStatus.shipped).length,
      'delivered': orders.where((order) => order.status == OrderStatus.delivered).length,
      'cancelled': orders.where((order) => order.status == OrderStatus.cancelled).length,
    };
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Reset database (for development/testing)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
    
    // Delete the database file
    String path = join(await getDatabasesPath(), 'jeevaan.db');
    await deleteDatabase(path);
    
    // Recreate database
    _database = await _initDatabase();
  }
}
