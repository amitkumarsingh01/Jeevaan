enum OrderStatus {
  pending('Pending', '⏳'),
  confirmed('Confirmed', '✅'),
  processing('Processing', '🔄'),
  shipped('Shipped', '📦'),
  delivered('Delivered', '✅'),
  cancelled('Cancelled', '❌'),
  returned('Returned', '↩️');

  const OrderStatus(this.displayName, this.icon);
  
  final String displayName;
  final String icon;
}

enum PaymentStatus {
  pending('Pending', '⏳'),
  paid('Paid', '✅'),
  failed('Failed', '❌'),
  refunded('Refunded', '↩️');

  const PaymentStatus(this.displayName, this.icon);
  
  final String displayName;
  final String icon;
}

class OrderItem {
  final int? id;
  final int orderId;
  final int medicineId;
  final String medicineName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  OrderItem({
    this.id,
    required this.orderId,
    required this.medicineId,
    required this.medicineName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'medicine_id': medicineId,
      'medicine_name': medicineName,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['order_id'],
      medicineId: map['medicine_id'],
      medicineName: map['medicine_name'],
      unitPrice: map['unit_price']?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 0,
      totalPrice: map['total_price']?.toDouble() ?? 0.0,
    );
  }

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? medicineId,
    String? medicineName,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  @override
  String toString() {
    return 'OrderItem{medicineName: $medicineName, quantity: $quantity, totalPrice: $totalPrice}';
  }
}

class Order {
  final int? id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String deliveryAddress;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? paymentMethod;
  final String? notes;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String? trackingNumber;
  final List<OrderItem> items;

  Order({
    this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.deliveryAddress,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod,
    this.notes,
    required this.orderDate,
    this.deliveryDate,
    this.trackingNumber,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_email': customerEmail,
      'delivery_address': deliveryAddress,
      'subtotal': subtotal,
      'tax': tax,
      'delivery_fee': deliveryFee,
      'total_amount': totalAmount,
      'status': status.name,
      'payment_status': paymentStatus.name,
      'payment_method': paymentMethod,
      'notes': notes,
      'order_date': orderDate.millisecondsSinceEpoch,
      'delivery_date': deliveryDate?.millisecondsSinceEpoch,
      'tracking_number': trackingNumber,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      orderNumber: map['order_number'],
      customerName: map['customer_name'],
      customerPhone: map['customer_phone'],
      customerEmail: map['customer_email'],
      deliveryAddress: map['delivery_address'],
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      deliveryFee: map['delivery_fee']?.toDouble() ?? 0.0,
      totalAmount: map['total_amount']?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == map['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: map['payment_method'],
      notes: map['notes'],
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['order_date']),
      deliveryDate: map['delivery_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['delivery_date'])
          : null,
      trackingNumber: map['tracking_number'],
    );
  }

  Order copyWith({
    int? id,
    String? orderNumber,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? deliveryAddress,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? totalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? paymentMethod,
    String? notes,
    DateTime? orderDate,
    DateTime? deliveryDate,
    String? trackingNumber,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      items: items ?? this.items,
    );
  }

  // Get formatted order date
  String get formattedOrderDate {
    return '${orderDate.day}/${orderDate.month}/${orderDate.year}';
  }

  // Get formatted delivery date
  String get formattedDeliveryDate {
    if (deliveryDate == null) return 'Not scheduled';
    return '${deliveryDate!.day}/${deliveryDate!.month}/${deliveryDate!.year}';
  }

  // Get formatted total amount
  String get formattedTotalAmount {
    return '₹${totalAmount.toStringAsFixed(2)}';
  }

  // Get formatted subtotal
  String get formattedSubtotal {
    return '₹${subtotal.toStringAsFixed(2)}';
  }

  // Get formatted tax
  String get formattedTax {
    return '₹${tax.toStringAsFixed(2)}';
  }

  // Get formatted delivery fee
  String get formattedDeliveryFee {
    return '₹${deliveryFee.toStringAsFixed(2)}';
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return 'orange';
      case OrderStatus.confirmed:
        return 'blue';
      case OrderStatus.processing:
        return 'purple';
      case OrderStatus.shipped:
        return 'indigo';
      case OrderStatus.delivered:
        return 'green';
      case OrderStatus.cancelled:
        return 'red';
      case OrderStatus.returned:
        return 'grey';
    }
  }

  // Get payment status color
  String get paymentStatusColor {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'orange';
      case PaymentStatus.paid:
        return 'green';
      case PaymentStatus.failed:
        return 'red';
      case PaymentStatus.refunded:
        return 'blue';
    }
  }

  // Check if order can be cancelled
  bool get canBeCancelled {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  // Check if order is completed
  bool get isCompleted {
    return status == OrderStatus.delivered;
  }

  // Get total items count
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  String toString() {
    return 'Order{id: $id, orderNumber: $orderNumber, status: $status, totalAmount: $formattedTotalAmount}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
