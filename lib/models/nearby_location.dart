class NearbyLocation {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int userRatingsTotal;
  final String? phoneNumber;
  final String? website;
  final List<String> types;
  final bool isOpen;
  final String? openingHours;
  final double distance; // Distance in meters from user location

  NearbyLocation({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.userRatingsTotal,
    this.phoneNumber,
    this.website,
    required this.types,
    required this.isOpen,
    this.openingHours,
    required this.distance,
  });

  factory NearbyLocation.fromMap(Map<String, dynamic> map) {
    final geometry = map['geometry'] as Map<String, dynamic>;
    final location = geometry['location'] as Map<String, dynamic>;
    
    return NearbyLocation(
      placeId: map['place_id'] ?? '',
      name: map['name'] ?? 'Unknown',
      address: map['vicinity'] ?? map['formatted_address'] ?? 'Address not available',
      latitude: location['lat']?.toDouble() ?? 0.0,
      longitude: location['lng']?.toDouble() ?? 0.0,
      rating: map['rating']?.toDouble() ?? 0.0,
      userRatingsTotal: map['user_ratings_total'] ?? 0,
      phoneNumber: map['formatted_phone_number'],
      website: map['website'],
      types: List<String>.from(map['types'] ?? []),
      isOpen: map['opening_hours']?['open_now'] ?? false,
      openingHours: map['opening_hours']?['weekday_text']?.join('\n'),
      distance: 0.0, // Will be calculated separately
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'place_id': placeId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'user_ratings_total': userRatingsTotal,
      'phone_number': phoneNumber,
      'website': website,
      'types': types,
      'is_open': isOpen,
      'opening_hours': openingHours,
      'distance': distance,
    };
  }

  // Get formatted distance
  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  // Get formatted rating
  String get formattedRating {
    if (rating == 0.0) {
      return 'No rating';
    }
    return '${rating.toStringAsFixed(1)} ⭐';
  }

  // Get primary type (first type from the list)
  String get primaryType {
    if (types.isEmpty) return 'unknown';
    return types.first;
  }

  // Get category icon based on type
  String get categoryIcon {
    final type = primaryType.toLowerCase();
    if (type.contains('hospital') || type.contains('health')) {
      return '🏥';
    } else if (type.contains('pharmacy') || type.contains('drugstore')) {
      return '💊';
    } else if (type.contains('grocery') || type.contains('supermarket') || type.contains('store')) {
      return '🛒';
    } else if (type.contains('police')) {
      return '🚔';
    } else if (type.contains('restaurant') || type.contains('food')) {
      return '🍽️';
    } else if (type.contains('gas_station') || type.contains('fuel')) {
      return '⛽';
    } else if (type.contains('bank') || type.contains('atm')) {
      return '🏦';
    } else if (type.contains('school') || type.contains('university')) {
      return '🎓';
    } else {
      return '📍';
    }
  }

  // Get category name
  String get categoryName {
    final type = primaryType.toLowerCase();
    if (type.contains('hospital') || type.contains('health')) {
      return 'Hospital';
    } else if (type.contains('pharmacy') || type.contains('drugstore')) {
      return 'Pharmacy';
    } else if (type.contains('grocery') || type.contains('supermarket') || type.contains('store')) {
      return 'Grocery Store';
    } else if (type.contains('police')) {
      return 'Police Station';
    } else if (type.contains('restaurant') || type.contains('food')) {
      return 'Restaurant';
    } else if (type.contains('gas_station') || type.contains('fuel')) {
      return 'Gas Station';
    } else if (type.contains('bank') || type.contains('atm')) {
      return 'Bank';
    } else if (type.contains('school') || type.contains('university')) {
      return 'School';
    } else {
      return 'Other';
    }
  }

  // Get status text
  String get statusText {
    if (isOpen) {
      return 'Open';
    } else {
      return 'Closed';
    }
  }

  // Get status color
  String get statusColor {
    return isOpen ? 'green' : 'red';
  }

  @override
  String toString() {
    return 'NearbyLocation{name: $name, address: $address, distance: $formattedDistance}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NearbyLocation && other.placeId == placeId;
  }

  @override
  int get hashCode => placeId.hashCode;
}

enum LocationCategory {
  hospital('hospital', '🏥', 'Hospitals'),
  pharmacy('pharmacy', '💊', 'Pharmacies'),
  grocery('grocery_or_supermarket', '🛒', 'Grocery Stores'),
  police('police', '🚔', 'Police Stations'),
  restaurant('restaurant', '🍽️', 'Restaurants'),
  gasStation('gas_station', '⛽', 'Gas Stations'),
  bank('bank', '🏦', 'Banks'),
  school('school', '🎓', 'Schools');

  const LocationCategory(this.type, this.icon, this.displayName);
  
  final String type;
  final String icon;
  final String displayName;
}
