class Medicine {
  final int? id;
  final String name;
  final String genericName;
  final String manufacturer;
  final String category;
  final String description;
  final double price;
  final int stockQuantity;
  final String dosageForm; // Tablet, Capsule, Syrup, Injection, etc.
  final String strength; // 500mg, 10ml, etc.
  final String? imageUrl;
  final bool requiresPrescription;
  final String? sideEffects;
  final String? instructions;
  final DateTime createdAt;
  final bool isActive;

  Medicine({
    this.id,
    required this.name,
    required this.genericName,
    required this.manufacturer,
    required this.category,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.dosageForm,
    required this.strength,
    this.imageUrl,
    this.requiresPrescription = false,
    this.sideEffects,
    this.instructions,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'generic_name': genericName,
      'manufacturer': manufacturer,
      'category': category,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'dosage_form': dosageForm,
      'strength': strength,
      'image_url': imageUrl,
      'requires_prescription': requiresPrescription ? 1 : 0,
      'side_effects': sideEffects,
      'instructions': instructions,
      'created_at': createdAt.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      genericName: map['generic_name'],
      manufacturer: map['manufacturer'],
      category: map['category'],
      description: map['description'],
      price: map['price']?.toDouble() ?? 0.0,
      stockQuantity: map['stock_quantity'] ?? 0,
      dosageForm: map['dosage_form'],
      strength: map['strength'],
      imageUrl: map['image_url'],
      requiresPrescription: map['requires_prescription'] == 1,
      sideEffects: map['side_effects'],
      instructions: map['instructions'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      isActive: map['is_active'] == 1,
    );
  }

  Medicine copyWith({
    int? id,
    String? name,
    String? genericName,
    String? manufacturer,
    String? category,
    String? description,
    double? price,
    int? stockQuantity,
    String? dosageForm,
    String? strength,
    String? imageUrl,
    bool? requiresPrescription,
    String? sideEffects,
    String? instructions,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      dosageForm: dosageForm ?? this.dosageForm,
      strength: strength ?? this.strength,
      imageUrl: imageUrl ?? this.imageUrl,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      sideEffects: sideEffects ?? this.sideEffects,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Get formatted price
  String get formattedPrice {
    return '₹${price.toStringAsFixed(2)}';
  }

  // Get stock status
  String get stockStatus {
    if (stockQuantity == 0) {
      return 'Out of Stock';
    } else if (stockQuantity < 10) {
      return 'Low Stock';
    } else {
      return 'In Stock';
    }
  }

  // Get stock status color
  String get stockStatusColor {
    if (stockQuantity == 0) {
      return 'red';
    } else if (stockQuantity < 10) {
      return 'orange';
    } else {
      return 'green';
    }
  }

  // Get category icon
  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'antibiotics':
        return '💊';
      case 'pain relief':
        return '🩹';
      case 'vitamins':
        return '💊';
      case 'diabetes':
        return '🩸';
      case 'heart':
        return '❤️';
      case 'respiratory':
        return '🫁';
      case 'digestive':
        return '🫄';
      case 'skincare':
        return '🧴';
      case 'mental health':
        return '🧠';
      case 'women\'s health':
        return '👩';
      default:
        return '💊';
    }
  }

  // Check if medicine is available
  bool get isAvailable {
    return isActive && stockQuantity > 0;
  }

  // Get prescription requirement text
  String get prescriptionText {
    return requiresPrescription ? 'Prescription Required' : 'OTC (Over the Counter)';
  }

  @override
  String toString() {
    return 'Medicine{id: $id, name: $name, price: $formattedPrice}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicine && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
