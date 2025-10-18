import '../models/doctor.dart';
import '../models/medicine.dart';
import '../models/order.dart';
import '../models/user.dart';
import '../database/database_helper.dart';

class DummyDataService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static Future<void> addDummyDoctors() async {
    try {
      // Check if doctors already exist
      final existingDoctors = await _dbHelper.getAllDoctors();
      if (existingDoctors.isNotEmpty) {
        return; // Don't add if doctors already exist
      }

      final dummyDoctors = [
        Doctor(
          name: 'Dr. Sarah Johnson',
          specialization: 'Cardiology',
          qualification: 'MD, DM Cardiology',
          phoneNumber: '+1-555-0101',
          email: 'sarah.johnson@hospital.com',
          address: '123 Medical Center, Health City',
          clinicName: 'Heart Care Clinic',
          consultationFee: 500.0,
          workingHours: '9:00 AM - 5:00 PM',
          availableDays: ['1', '2', '3', '4', '5'], // Monday to Friday
          rating: 4.8,
          reviewCount: 156,
          bio: 'Experienced cardiologist with 15 years of practice. Specializes in heart disease prevention and treatment.',
          createdAt: DateTime.now(),
        ),
        Doctor(
          name: 'Dr. Michael Chen',
          specialization: 'Dermatology',
          qualification: 'MD, DNB Dermatology',
          phoneNumber: '+1-555-0102',
          email: 'michael.chen@clinic.com',
          address: '456 Skin Care Avenue, Beauty District',
          clinicName: 'Skin Health Center',
          consultationFee: 400.0,
          workingHours: '10:00 AM - 6:00 PM',
          availableDays: ['1', '2', '3', '4', '5', '6'], // Monday to Saturday
          rating: 4.6,
          reviewCount: 89,
          bio: 'Board-certified dermatologist specializing in cosmetic and medical dermatology.',
          createdAt: DateTime.now(),
        ),
        Doctor(
          name: 'Dr. Emily Rodriguez',
          specialization: 'Pediatrics',
          qualification: 'MD, DCH Pediatrics',
          phoneNumber: '+1-555-0103',
          email: 'emily.rodriguez@children.com',
          address: '789 Kids Street, Family Town',
          clinicName: 'Little Angels Clinic',
          consultationFee: 350.0,
          workingHours: '8:00 AM - 4:00 PM',
          availableDays: ['1', '2', '3', '4', '5'], // Monday to Friday
          rating: 4.9,
          reviewCount: 234,
          bio: 'Pediatrician with 12 years of experience caring for children from birth to adolescence.',
          createdAt: DateTime.now(),
        ),
        Doctor(
          name: 'Dr. David Kumar',
          specialization: 'Orthopedics',
          qualification: 'MS Orthopedics, MCh',
          phoneNumber: '+1-555-0104',
          email: 'david.kumar@ortho.com',
          address: '321 Bone Street, Sports City',
          clinicName: 'Sports Medicine Center',
          consultationFee: 600.0,
          workingHours: '9:00 AM - 7:00 PM',
          availableDays: ['1', '2', '3', '4', '5', '6'], // Monday to Saturday
          rating: 4.7,
          reviewCount: 178,
          bio: 'Orthopedic surgeon specializing in sports injuries and joint replacement surgeries.',
          createdAt: DateTime.now(),
        ),
        Doctor(
          name: 'Dr. Lisa Wang',
          specialization: 'Gynecology',
          qualification: 'MD, DGO Gynecology',
          phoneNumber: '+1-555-0105',
          email: 'lisa.wang@women.com',
          address: '654 Women\'s Health Plaza, Care City',
          clinicName: 'Women\'s Wellness Clinic',
          consultationFee: 450.0,
          workingHours: '9:00 AM - 5:00 PM',
          availableDays: ['1', '2', '3', '4', '5'], // Monday to Friday
          rating: 4.8,
          reviewCount: 145,
          bio: 'Gynecologist with expertise in women\'s health, pregnancy care, and reproductive medicine.',
          createdAt: DateTime.now(),
        ),
        Doctor(
          name: 'Dr. James Thompson',
          specialization: 'Neurology',
          qualification: 'MD, DM Neurology',
          phoneNumber: '+1-555-0106',
          email: 'james.thompson@neuro.com',
          address: '987 Brain Avenue, Medical District',
          clinicName: 'Neuro Care Institute',
          consultationFee: 700.0,
          workingHours: '8:00 AM - 6:00 PM',
          availableDays: ['1', '2', '3', '4', '5'], // Monday to Friday
          rating: 4.9,
          reviewCount: 201,
          bio: 'Neurologist specializing in brain and nervous system disorders with 18 years of experience.',
          createdAt: DateTime.now(),
        ),
        Doctor(
          name: 'Dr. Maria Garcia',
          specialization: 'Psychiatry',
          qualification: 'MD, DPM Psychiatry',
          phoneNumber: '+1-555-0107',
          email: 'maria.garcia@mental.com',
          address: '147 Mind Street, Wellness City',
          clinicName: 'Mental Health Center',
          consultationFee: 550.0,
          workingHours: '10:00 AM - 7:00 PM',
          availableDays: ['1', '2', '3', '4', '5', '6'], // Monday to Saturday
          rating: 4.7,
          reviewCount: 123,
          bio: 'Psychiatrist specializing in mental health disorders, therapy, and medication management.',
          createdAt: DateTime.now(),
        ),
        Doctor(
          name: 'Dr. Robert Kim',
          specialization: 'Ophthalmology',
          qualification: 'MS Ophthalmology, FRCS',
          phoneNumber: '+1-555-0108',
          email: 'robert.kim@eye.com',
          address: '258 Vision Lane, Sight City',
          clinicName: 'Eye Care Specialists',
          consultationFee: 400.0,
          workingHours: '9:00 AM - 5:00 PM',
          availableDays: ['1', '2', '3', '4', '5'], // Monday to Friday
          rating: 4.6,
          reviewCount: 167,
          bio: 'Ophthalmologist specializing in eye diseases, cataract surgery, and vision correction.',
          createdAt: DateTime.now(),
        ),
        Doctor(
          name: 'Dr. Jennifer Lee',
          specialization: 'Dentistry',
          qualification: 'BDS, MDS Oral Surgery',
          phoneNumber: '+1-555-0109',
          email: 'jennifer.lee@dental.com',
          address: '369 Smile Street, Dental District',
          clinicName: 'Perfect Smile Dental',
          consultationFee: 300.0,
          workingHours: '8:00 AM - 6:00 PM',
          availableDays: ['1', '2', '3', '4', '5', '6'], // Monday to Saturday
          rating: 4.5,
          reviewCount: 98,
          bio: 'Dentist specializing in general dentistry, cosmetic procedures, and oral surgery.',
          createdAt: DateTime.now(),
        ),
        Doctor(
          name: 'Dr. Ahmed Hassan',
          specialization: 'General Medicine',
          qualification: 'MD General Medicine',
          phoneNumber: '+1-555-0110',
          email: 'ahmed.hassan@general.com',
          address: '741 Health Boulevard, Primary Care',
          clinicName: 'Family Health Clinic',
          consultationFee: 250.0,
          workingHours: '8:00 AM - 8:00 PM',
          availableDays: ['1', '2', '3', '4', '5', '6', '0'], // All days
          rating: 4.4,
          reviewCount: 312,
          bio: 'General physician providing comprehensive primary care for all age groups.',
          createdAt: DateTime.now(),
        ),
      ];

      // Insert all dummy doctors
      for (final doctor in dummyDoctors) {
        await _dbHelper.insertDoctor(doctor);
      }

      print('Added ${dummyDoctors.length} dummy doctors to database');
    } catch (e) {
      print('Error adding dummy doctors: $e');
    }
  }

  static Future<void> addDummyMedicines() async {
    try {
      // Check if medicines already exist
      final existingMedicines = await _dbHelper.getAllMedicines();
      if (existingMedicines.isNotEmpty) {
        return; // Don't add if medicines already exist
      }

      final dummyMedicines = [
        // Antibiotics
        Medicine(
          name: 'Amoxicillin',
          genericName: 'Amoxicillin',
          manufacturer: 'Sun Pharma',
          category: 'Antibiotics',
          description: 'Broad-spectrum antibiotic used to treat bacterial infections',
          price: 45.0,
          stockQuantity: 100,
          dosageForm: 'Capsule',
          strength: '500mg',
          requiresPrescription: true,
          sideEffects: 'Nausea, diarrhea, allergic reactions',
          instructions: 'Take with food, complete full course',
          createdAt: DateTime.now(),
        ),
        Medicine(
          name: 'Azithromycin',
          genericName: 'Azithromycin',
          manufacturer: 'Cipla',
          category: 'Antibiotics',
          description: 'Macrolide antibiotic for respiratory and skin infections',
          price: 120.0,
          stockQuantity: 75,
          dosageForm: 'Tablet',
          strength: '250mg',
          requiresPrescription: true,
          sideEffects: 'Stomach upset, headache',
          instructions: 'Take once daily, with or without food',
          createdAt: DateTime.now(),
        ),
        
        // Pain Relief
        Medicine(
          name: 'Paracetamol',
          genericName: 'Acetaminophen',
          manufacturer: 'GSK',
          category: 'Pain Relief',
          description: 'Pain reliever and fever reducer',
          price: 25.0,
          stockQuantity: 200,
          dosageForm: 'Tablet',
          strength: '500mg',
          requiresPrescription: false,
          sideEffects: 'Rare allergic reactions',
          instructions: 'Take every 4-6 hours as needed',
          createdAt: DateTime.now(),
        ),
        Medicine(
          name: 'Ibuprofen',
          genericName: 'Ibuprofen',
          manufacturer: 'Pfizer',
          category: 'Pain Relief',
          description: 'Anti-inflammatory pain reliever',
          price: 35.0,
          stockQuantity: 150,
          dosageForm: 'Tablet',
          strength: '400mg',
          requiresPrescription: false,
          sideEffects: 'Stomach irritation, dizziness',
          instructions: 'Take with food, maximum 3 times daily',
          createdAt: DateTime.now(),
        ),
        
        // Vitamins
        Medicine(
          name: 'Vitamin D3',
          genericName: 'Cholecalciferol',
          manufacturer: 'Nature Made',
          category: 'Vitamins',
          description: 'Essential vitamin for bone health and immune function',
          price: 180.0,
          stockQuantity: 80,
          dosageForm: 'Softgel',
          strength: '1000 IU',
          requiresPrescription: false,
          sideEffects: 'Rare: nausea, weakness',
          instructions: 'Take once daily with food',
          createdAt: DateTime.now(),
        ),
        Medicine(
          name: 'Vitamin B12',
          genericName: 'Cyanocobalamin',
          manufacturer: 'Nature\'s Bounty',
          category: 'Vitamins',
          description: 'Essential for nerve function and red blood cell formation',
          price: 95.0,
          stockQuantity: 120,
          dosageForm: 'Tablet',
          strength: '1000mcg',
          requiresPrescription: false,
          sideEffects: 'Mild diarrhea',
          instructions: 'Take once daily',
          createdAt: DateTime.now(),
        ),
        
        // Diabetes
        Medicine(
          name: 'Metformin',
          genericName: 'Metformin HCl',
          manufacturer: 'Dr. Reddy\'s',
          category: 'Diabetes',
          description: 'First-line treatment for type 2 diabetes',
          price: 85.0,
          stockQuantity: 90,
          dosageForm: 'Tablet',
          strength: '500mg',
          requiresPrescription: true,
          sideEffects: 'Nausea, diarrhea, metallic taste',
          instructions: 'Take with meals, twice daily',
          createdAt: DateTime.now(),
        ),
        Medicine(
          name: 'Insulin Glargine',
          genericName: 'Insulin Glargine',
          manufacturer: 'Sanofi',
          category: 'Diabetes',
          description: 'Long-acting insulin for diabetes management',
          price: 450.0,
          stockQuantity: 25,
          dosageForm: 'Injection',
          strength: '100 units/ml',
          requiresPrescription: true,
          sideEffects: 'Hypoglycemia, injection site reactions',
          instructions: 'Inject once daily at same time',
          createdAt: DateTime.now(),
        ),
        
        // Heart
        Medicine(
          name: 'Atorvastatin',
          genericName: 'Atorvastatin Calcium',
          manufacturer: 'Pfizer',
          category: 'Heart',
          description: 'Statin medication to lower cholesterol',
          price: 150.0,
          stockQuantity: 60,
          dosageForm: 'Tablet',
          strength: '20mg',
          requiresPrescription: true,
          sideEffects: 'Muscle pain, liver enzyme changes',
          instructions: 'Take once daily in evening',
          createdAt: DateTime.now(),
        ),
        Medicine(
          name: 'Lisinopril',
          genericName: 'Lisinopril',
          manufacturer: 'Merck',
          category: 'Heart',
          description: 'ACE inhibitor for blood pressure control',
          price: 75.0,
          stockQuantity: 85,
          dosageForm: 'Tablet',
          strength: '10mg',
          requiresPrescription: true,
          sideEffects: 'Dry cough, dizziness',
          instructions: 'Take once daily',
          createdAt: DateTime.now(),
        ),
        
        // Respiratory
        Medicine(
          name: 'Salbutamol',
          genericName: 'Albuterol',
          manufacturer: 'GSK',
          category: 'Respiratory',
          description: 'Bronchodilator for asthma and COPD',
          price: 65.0,
          stockQuantity: 110,
          dosageForm: 'Inhaler',
          strength: '100mcg',
          requiresPrescription: true,
          sideEffects: 'Tremor, nervousness, rapid heartbeat',
          instructions: 'Use as needed for breathing difficulties',
          createdAt: DateTime.now(),
        ),
        Medicine(
          name: 'Montelukast',
          genericName: 'Montelukast Sodium',
          manufacturer: 'Merck',
          category: 'Respiratory',
          description: 'Leukotriene receptor antagonist for asthma',
          price: 125.0,
          stockQuantity: 70,
          dosageForm: 'Tablet',
          strength: '10mg',
          requiresPrescription: true,
          sideEffects: 'Headache, stomach pain',
          instructions: 'Take once daily in evening',
          createdAt: DateTime.now(),
        ),
        
        // Digestive
        Medicine(
          name: 'Omeprazole',
          genericName: 'Omeprazole',
          manufacturer: 'AstraZeneca',
          category: 'Digestive',
          description: 'Proton pump inhibitor for acid reflux',
          price: 95.0,
          stockQuantity: 95,
          dosageForm: 'Capsule',
          strength: '20mg',
          requiresPrescription: true,
          sideEffects: 'Headache, nausea, diarrhea',
          instructions: 'Take before breakfast',
          createdAt: DateTime.now(),
        ),
        Medicine(
          name: 'Loperamide',
          genericName: 'Loperamide HCl',
          manufacturer: 'Janssen',
          category: 'Digestive',
          description: 'Anti-diarrheal medication',
          price: 40.0,
          stockQuantity: 130,
          dosageForm: 'Capsule',
          strength: '2mg',
          requiresPrescription: false,
          sideEffects: 'Constipation, dizziness',
          instructions: 'Take after each loose bowel movement',
          createdAt: DateTime.now(),
        ),
        
        // Skincare
        Medicine(
          name: 'Hydrocortisone',
          genericName: 'Hydrocortisone',
          manufacturer: 'Pfizer',
          category: 'Skincare',
          description: 'Topical corticosteroid for skin inflammation',
          price: 55.0,
          stockQuantity: 80,
          dosageForm: 'Cream',
          strength: '1%',
          requiresPrescription: false,
          sideEffects: 'Skin thinning with prolonged use',
          instructions: 'Apply thin layer to affected area',
          createdAt: DateTime.now(),
        ),
        Medicine(
          name: 'Clotrimazole',
          genericName: 'Clotrimazole',
          manufacturer: 'Bayer',
          category: 'Skincare',
          description: 'Antifungal cream for skin infections',
          price: 65.0,
          stockQuantity: 75,
          dosageForm: 'Cream',
          strength: '1%',
          requiresPrescription: false,
          sideEffects: 'Skin irritation, burning',
          instructions: 'Apply twice daily to affected area',
          createdAt: DateTime.now(),
        ),
        
        // Mental Health
        Medicine(
          name: 'Sertraline',
          genericName: 'Sertraline HCl',
          manufacturer: 'Pfizer',
          category: 'Mental Health',
          description: 'SSRI antidepressant for depression and anxiety',
          price: 200.0,
          stockQuantity: 45,
          dosageForm: 'Tablet',
          strength: '50mg',
          requiresPrescription: true,
          sideEffects: 'Nausea, insomnia, sexual dysfunction',
          instructions: 'Take once daily in morning',
          createdAt: DateTime.now(),
        ),
        Medicine(
          name: 'Lorazepam',
          genericName: 'Lorazepam',
          manufacturer: 'Teva',
          category: 'Mental Health',
          description: 'Benzodiazepine for anxiety and sleep disorders',
          price: 85.0,
          stockQuantity: 35,
          dosageForm: 'Tablet',
          strength: '1mg',
          requiresPrescription: true,
          sideEffects: 'Drowsiness, dizziness, dependence',
          instructions: 'Take as directed by doctor',
          createdAt: DateTime.now(),
        ),
        
        // Women's Health
        Medicine(
          name: 'Folic Acid',
          genericName: 'Folic Acid',
          manufacturer: 'Nature Made',
          category: 'Women\'s Health',
          description: 'Essential vitamin for pregnancy and women\'s health',
          price: 35.0,
          stockQuantity: 150,
          dosageForm: 'Tablet',
          strength: '400mcg',
          requiresPrescription: false,
          sideEffects: 'Rare allergic reactions',
          instructions: 'Take once daily',
          createdAt: DateTime.now(),
        ),
        Medicine(
          name: 'Iron Supplement',
          genericName: 'Ferrous Sulfate',
          manufacturer: 'Nature\'s Bounty',
          category: 'Women\'s Health',
          description: 'Iron supplement for anemia prevention',
          price: 75.0,
          stockQuantity: 100,
          dosageForm: 'Tablet',
          strength: '65mg',
          requiresPrescription: false,
          sideEffects: 'Constipation, stomach upset',
          instructions: 'Take with food, avoid dairy',
          createdAt: DateTime.now(),
        ),
      ];

      // Insert all dummy medicines
      for (final medicine in dummyMedicines) {
        await _dbHelper.insertMedicine(medicine);
      }

      print('Added ${dummyMedicines.length} dummy medicines to database');
    } catch (e) {
      print('Error adding dummy medicines: $e');
    }
  }

  static Future<void> addDummyUsers() async {
    try {
      // Check if users already exist
      final existingUsers = await _dbHelper.getAllUsers();
      if (existingUsers.isNotEmpty) {
        return; // Don't add if users already exist
      }

      final sampleUsers = [
        User(
          name: 'John Doe',
          email: 'john.doe@example.com',
          password: 'password123',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        User(
          name: 'Jane Smith',
          email: 'jane.smith@example.com',
          password: 'password123',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
        ),
        User(
          name: 'Mike Johnson',
          email: 'mike.johnson@example.com',
          password: 'password123',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
        User(
          name: 'Sarah Wilson',
          email: 'sarah.wilson@example.com',
          password: 'password123',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        User(
          name: 'David Brown',
          email: 'david.brown@example.com',
          password: 'password123',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        User(
          name: 'Amit Kumar',
          email: 'amit@gmail.com',
          password: 'password123',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];

      // Insert all sample users
      for (final user in sampleUsers) {
        await _dbHelper.insertUser(user);
      }

      print('Added ${sampleUsers.length} sample users to database');
    } catch (e) {
      print('Error adding sample users: $e');
    }
  }

  static Future<void> addDummyOrders() async {
    try {
      // Check if orders already exist
      final existingOrders = await _dbHelper.getAllOrders();
      if (existingOrders.isNotEmpty) {
        return; // Don't add if orders already exist
      }

      // Get some medicines to create orders
      final medicines = await _dbHelper.getAllMedicines();
      if (medicines.isEmpty) {
        print('No medicines available to create orders');
        return;
      }

      final sampleOrders = [
        Order(
          orderNumber: 'ORD001',
          customerName: 'John Doe',
          customerPhone: '+1-555-0101',
          customerEmail: 'john.doe@example.com',
          deliveryAddress: '123 Main Street, City, State 12345',
          subtotal: 150.0,
          tax: 18.0,
          deliveryFee: 50.0,
          totalAmount: 218.0,
          status: OrderStatus.delivered,
          paymentStatus: PaymentStatus.paid,
          paymentMethod: 'Credit Card',
          notes: 'Please deliver after 6 PM',
          orderDate: DateTime.now().subtract(const Duration(days: 5)),
          deliveryDate: DateTime.now().subtract(const Duration(days: 3)),
          trackingNumber: 'TRK123456789',
        ),
        Order(
          orderNumber: 'ORD002',
          customerName: 'Jane Smith',
          customerPhone: '+1-555-0102',
          customerEmail: 'jane.smith@example.com',
          deliveryAddress: '456 Oak Avenue, City, State 12345',
          subtotal: 75.0,
          tax: 9.0,
          deliveryFee: 50.0,
          totalAmount: 134.0,
          status: OrderStatus.shipped,
          paymentStatus: PaymentStatus.paid,
          paymentMethod: 'UPI',
          notes: 'Leave at front door if no one answers',
          orderDate: DateTime.now().subtract(const Duration(days: 2)),
          trackingNumber: 'TRK987654321',
        ),
        Order(
          orderNumber: 'ORD003',
          customerName: 'Mike Johnson',
          customerPhone: '+1-555-0103',
          customerEmail: 'mike.johnson@example.com',
          deliveryAddress: '789 Pine Road, City, State 12345',
          subtotal: 200.0,
          tax: 24.0,
          deliveryFee: 50.0,
          totalAmount: 274.0,
          status: OrderStatus.processing,
          paymentStatus: PaymentStatus.paid,
          paymentMethod: 'Debit Card',
          notes: 'Urgent delivery needed',
          orderDate: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        Order(
          orderNumber: 'ORD004',
          customerName: 'Sarah Wilson',
          customerPhone: '+1-555-0104',
          customerEmail: 'sarah.wilson@example.com',
          deliveryAddress: '321 Elm Street, City, State 12345',
          subtotal: 120.0,
          tax: 14.4,
          deliveryFee: 50.0,
          totalAmount: 184.4,
          status: OrderStatus.pending,
          paymentStatus: PaymentStatus.pending,
          paymentMethod: 'Cash on Delivery',
          notes: 'Call before delivery',
          orderDate: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Order(
          orderNumber: 'ORD005',
          customerName: 'David Brown',
          customerPhone: '+1-555-0105',
          customerEmail: 'david.brown@example.com',
          deliveryAddress: '654 Maple Lane, City, State 12345',
          subtotal: 90.0,
          tax: 10.8,
          deliveryFee: 50.0,
          totalAmount: 150.8,
          status: OrderStatus.cancelled,
          paymentStatus: PaymentStatus.refunded,
          paymentMethod: 'Credit Card',
          notes: 'Customer cancelled order',
          orderDate: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      // Insert all sample orders
      for (final order in sampleOrders) {
        final orderId = await _dbHelper.insertOrder(order);
        
        // Add some order items for each order
        final selectedMedicines = medicines.take(2).toList();
        for (int i = 0; i < selectedMedicines.length; i++) {
          final medicine = selectedMedicines[i];
          final quantity = (i + 1) * 2; // 2, 4, etc.
          
          final orderItem = OrderItem(
            orderId: orderId,
            medicineId: medicine.id!,
            medicineName: medicine.name,
            unitPrice: medicine.price,
            quantity: quantity,
            totalPrice: medicine.price * quantity,
          );
          
          await _dbHelper.insertOrderItem(orderItem);
        }
      }

      print('Added ${sampleOrders.length} sample orders to database');
    } catch (e) {
      print('Error adding sample orders: $e');
    }
  }

  static Future<void> clearAllData() async {
    try {
      // This method can be used to clear all data if needed
      // Implementation would depend on your specific needs
      print('Clear all data method called');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  static Future<bool> hasDummyData() async {
    try {
      final doctors = await _dbHelper.getAllDoctors();
      final medicines = await _dbHelper.getAllMedicines();
      return doctors.isNotEmpty || medicines.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
