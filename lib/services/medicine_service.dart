import '../models/medicine.dart';
import '../models/order.dart';
import '../database/database_helper.dart';
import 'notification_service.dart';

class MedicineService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // Get all active medicines
  static Future<List<Medicine>> getAllMedicines() async {
    try {
      return await _dbHelper.getActiveMedicines();
    } catch (e) {
      throw Exception('Failed to get medicines: $e');
    }
  }

  // Get medicines by category
  static Future<List<Medicine>> getMedicinesByCategory(String category) async {
    try {
      return await _dbHelper.getMedicinesByCategory(category);
    } catch (e) {
      throw Exception('Failed to get medicines by category: $e');
    }
  }

  // Search medicines
  static Future<List<Medicine>> searchMedicines(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllMedicines();
      }
      return await _dbHelper.searchMedicines(query.trim());
    } catch (e) {
      throw Exception('Failed to search medicines: $e');
    }
  }

  // Get medicine by ID
  static Future<Medicine?> getMedicineById(int id) async {
    try {
      return await _dbHelper.getMedicineById(id);
    } catch (e) {
      throw Exception('Failed to get medicine: $e');
    }
  }

  // Get medicine categories
  static List<String> getMedicineCategories() {
    return [
      'All',
      'Antibiotics',
      'Pain Relief',
      'Vitamins',
      'Diabetes',
      'Heart',
      'Respiratory',
      'Digestive',
      'Skincare',
      'Mental Health',
      'Women\'s Health',
    ];
  }

  // Place an order
  static Future<String> placeOrder({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String deliveryAddress,
    required List<Map<String, dynamic>> cartItems,
    String? notes,
    String paymentMethod = 'Cash on Delivery',
  }) async {
    try {
      // Calculate totals
      double subtotal = 0.0;
      for (final item in cartItems) {
        final medicine = await getMedicineById(item['medicineId']);
        if (medicine == null) {
          throw Exception('Medicine not found: ${item['medicineId']}');
        }
        
        if (medicine.stockQuantity < item['quantity']) {
          throw Exception('Insufficient stock for ${medicine.name}');
        }
        
        subtotal += medicine.price * item['quantity'];
      }

      const double taxRate = 0.12; // 12% tax
      const double deliveryFee = 50.0; // Fixed delivery fee
      final double tax = subtotal * taxRate;
      final double totalAmount = subtotal + tax + deliveryFee;

      // Generate order number
      final String orderNumber = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      // Create order
      final order = Order(
        orderNumber: orderNumber,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        deliveryAddress: deliveryAddress,
        subtotal: subtotal,
        tax: tax,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        notes: notes,
        orderDate: DateTime.now(),
      );

      // Insert order
      print('Inserting order: $orderNumber for email: $customerEmail');
      final orderId = await _dbHelper.insertOrder(order);
      print('Order inserted with ID: $orderId');

      // Insert order items and update stock
      for (final item in cartItems) {
        final medicine = await getMedicineById(item['medicineId']);
        if (medicine != null) {
          // Create order item
          final orderItem = OrderItem(
            orderId: orderId,
            medicineId: medicine.id!,
            medicineName: medicine.name,
            unitPrice: medicine.price,
            quantity: item['quantity'],
            totalPrice: medicine.price * item['quantity'],
          );

          await _dbHelper.insertOrderItem(orderItem);

          // Update stock
          final newStock = medicine.stockQuantity - (item['quantity'] as int);
          await _dbHelper.updateMedicineStock(medicine.id!, newStock);
        }
      }

      // Get order items for email
      final orderItemsForEmail = <Map<String, dynamic>>[];
      for (final item in cartItems) {
        final medicine = await getMedicineById(item['medicineId']);
        if (medicine != null) {
          orderItemsForEmail.add({
            'medicine': medicine,
            'medicineName': medicine.name,
            'quantity': item['quantity'],
            'price': medicine.price,
          });
        }
      }

      // Send notification and email
      await NotificationService.notifyOrderPlaced(
        orderNumber: orderNumber,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        customerName: customerName,
        customerEmail: customerEmail,
        orderItems: orderItemsForEmail,
      );

      return orderNumber;
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  // Get orders by customer email
  static Future<List<Order>> getCustomerOrders(String email) async {
    try {
      print('Fetching orders for email: $email');
      final orders = await _dbHelper.getOrdersByCustomer(email);
      print('Found ${orders.length} orders for email: $email');
      
      // Load order items for each order and create new Order objects with items
      final ordersWithItems = <Order>[];
      for (final order in orders) {
        final items = await _dbHelper.getOrderItemsByOrderId(order.id!);
        print('Loaded ${items.length} items for order ${order.orderNumber}');
        
        // Create new order with items
        final orderWithItems = order.copyWith(items: items);
        ordersWithItems.add(orderWithItems);
      }
      
      return ordersWithItems;
    } catch (e) {
      print('Error getting customer orders: $e');
      throw Exception('Failed to get customer orders: $e');
    }
  }

  // Get order by ID
  static Future<Order?> getOrderById(int id) async {
    try {
      return await _dbHelper.getOrderById(id);
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // Get order items by order ID
  static Future<List<OrderItem>> getOrderItems(int orderId) async {
    try {
      return await _dbHelper.getOrderItemsByOrderId(orderId);
    } catch (e) {
      throw Exception('Failed to get order items: $e');
    }
  }

  // Cancel order
  static Future<void> cancelOrder(int orderId) async {
    try {
      // Get order before cancelling
      final order = await getOrderById(orderId);
      if (order == null) throw Exception('Order not found');
      
      // Get order items to restore stock
      final orderItems = await getOrderItems(orderId);
      
      // Restore stock for each item
      for (final item in orderItems) {
        final medicine = await getMedicineById(item.medicineId);
        if (medicine != null) {
          final newStock = medicine.stockQuantity + item.quantity;
          await _dbHelper.updateMedicineStock(medicine.id!, newStock);
        }
      }
      
      // Update order status
      await _dbHelper.updateOrderStatus(orderId, OrderStatus.cancelled);
      
      // Send notification and email
      await NotificationService.notifyOrderStatusUpdate(
        orderNumber: order.orderNumber,
        status: 'Cancelled',
      );
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Update order status (for admin)
  static Future<void> updateOrderStatus(int orderId, OrderStatus status) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) throw Exception('Order not found');
      
      await _dbHelper.updateOrderStatus(orderId, status);
      
      // Send notification and email
      await NotificationService.notifyOrderStatusUpdate(
        orderNumber: order.orderNumber,
        status: status.toString().split('.').last,
      );
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Update payment status
  static Future<void> updatePaymentStatus(int orderId, PaymentStatus paymentStatus) async {
    try {
      await _dbHelper.updateOrderPaymentStatus(orderId, paymentStatus);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Add tracking information
  static Future<void> addTrackingInfo(int orderId, String trackingNumber, DateTime? deliveryDate) async {
    try {
      final order = await getOrderById(orderId);
      if (order == null) throw Exception('Order not found');
      
      await _dbHelper.updateOrderTracking(orderId, trackingNumber, deliveryDate);
      
      // Send notification and email
      await NotificationService.notifyOrderStatusUpdate(
        orderNumber: order.orderNumber,
        status: 'Shipped',
        trackingNumber: trackingNumber,
      );
    } catch (e) {
      throw Exception('Failed to add tracking info: $e');
    }
  }

  // Get order statistics
  static Future<Map<String, int>> getOrderStats() async {
    try {
      return await _dbHelper.getOrderStats();
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  // Validate cart items
  static Future<List<String>> validateCartItems(List<Map<String, dynamic>> cartItems) async {
    List<String> errors = [];
    
    for (final item in cartItems) {
      final medicine = await getMedicineById(item['medicineId']);
      if (medicine == null) {
        errors.add('Medicine not found: ${item['medicineId']}');
        continue;
      }
      
      if (!medicine.isActive) {
        errors.add('${medicine.name} is not available');
        continue;
      }
      
      if (medicine.stockQuantity < item['quantity']) {
        errors.add('Insufficient stock for ${medicine.name}. Available: ${medicine.stockQuantity}');
        continue;
      }
      
      if (medicine.requiresPrescription && item['hasPrescription'] != true) {
        errors.add('${medicine.name} requires a prescription');
      }
    }
    
    return errors;
  }

  // Calculate cart total
  static Future<Map<String, double>> calculateCartTotal(List<Map<String, dynamic>> cartItems) async {
    double subtotal = 0.0;
    
    for (final item in cartItems) {
      final medicine = await getMedicineById(item['medicineId']);
      if (medicine != null) {
        subtotal += medicine.price * item['quantity'];
      }
    }
    
    const double taxRate = 0.12; // 12% tax
    const double deliveryFee = 50.0; // Fixed delivery fee
    final double tax = subtotal * taxRate;
    final double totalAmount = subtotal + tax + deliveryFee;
    
    return {
      'subtotal': subtotal,
      'tax': tax,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
    };
  }

  // Get popular medicines (mock implementation)
  static Future<List<Medicine>> getPopularMedicines() async {
    try {
      final allMedicines = await getAllMedicines();
      // Return first 10 medicines as "popular"
      return allMedicines.take(10).toList();
    } catch (e) {
      throw Exception('Failed to get popular medicines: $e');
    }
  }

  // Get low stock medicines (for admin)
  static Future<List<Medicine>> getLowStockMedicines() async {
    try {
      final allMedicines = await getAllMedicines();
      return allMedicines.where((medicine) => medicine.stockQuantity < 10).toList();
    } catch (e) {
      throw Exception('Failed to get low stock medicines: $e');
    }
  }
}
