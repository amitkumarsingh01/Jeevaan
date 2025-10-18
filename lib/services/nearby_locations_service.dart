import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../models/nearby_location.dart';
import '../config/app_config.dart';
import 'location_service.dart';

class NearbyLocationsService {
  // Use API key from config
  static String get _apiKey => AppConfig.googlePlacesApiKey;
  static String get _baseUrl => AppConfig.googleMapsBaseUrl;

  // Search for nearby places by category
  static Future<List<NearbyLocation>> searchNearbyPlaces(
    LocationCategory category, {
    double radius = AppConfig.defaultSearchRadius,
    int limit = AppConfig.maxResultsPerCategory,
  }) async {
    try {
      // Get current location
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Build the request URL
      final url = Uri.parse(
        '${AppConfig.placesNearbyUrl}?'
        'location=${position.latitude},${position.longitude}&'
        'radius=$radius&'
        'type=${category.type}&'
        'key=$_apiKey',
      );

      // Make the API request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          
          // Convert results to NearbyLocation objects
          List<NearbyLocation> locations = results.map((result) {
            final location = NearbyLocation.fromMap(result);
            
            // Calculate distance from user location
            final distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              location.latitude,
              location.longitude,
            );
            
            return location.copyWith(distance: distance);
          }).toList();

          // Sort by distance and limit results
          locations.sort((a, b) => a.distance.compareTo(b.distance));
          return locations.take(limit).toList();
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching nearby places: $e');
      return [];
    }
  }

  // Search for specific place by name
  static Future<List<NearbyLocation>> searchPlaceByName(
    String query, {
    double radius = 5000,
    int limit = 10,
  }) async {
    try {
      // Get current location
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Build the request URL
      final url = Uri.parse(
        '${AppConfig.placesTextSearchUrl}?'
        'query=$query&'
        'location=${position.latitude},${position.longitude}&'
        'radius=$radius&'
        'key=$_apiKey',
      );

      // Make the API request
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          
          // Convert results to NearbyLocation objects
          List<NearbyLocation> locations = results.map((result) {
            final location = NearbyLocation.fromMap(result);
            
            // Calculate distance from user location
            final distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              location.latitude,
              location.longitude,
            );
            
            return location.copyWith(distance: distance);
          }).toList();

          // Sort by distance and limit results
          locations.sort((a, b) => a.distance.compareTo(b.distance));
          return locations.take(limit).toList();
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching places by name: $e');
      return [];
    }
  }

  // Get place details by place ID
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        '${AppConfig.placesDetailsUrl}?'
        'place_id=$placeId&'
        'fields=name,formatted_address,formatted_phone_number,website,opening_hours,rating,user_ratings_total&'
        'key=$_apiKey',
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          return data['result'];
        } else {
          throw Exception('Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting place details: $e');
      return null;
    }
  }

  // Get directions to a place
  static Future<String?> getDirectionsUrl(double latitude, double longitude) async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position == null) {
        return null;
      }

      return 'https://www.google.com/maps/dir/'
          '${position.latitude},${position.longitude}/'
          '$latitude,$longitude';
    } catch (e) {
      print('Error generating directions URL: $e');
      return null;
    }
  }

  // Get all nearby essential services
  static Future<Map<LocationCategory, List<NearbyLocation>>> getAllNearbyServices({
    double radius = 5000,
    int limitPerCategory = 5,
  }) async {
    Map<LocationCategory, List<NearbyLocation>> results = {};
    
    // Search for each category
    for (LocationCategory category in LocationCategory.values) {
      try {
        final locations = await searchNearbyPlaces(
          category,
          radius: radius,
          limit: limitPerCategory,
        );
        results[category] = locations;
      } catch (e) {
        print('Error searching for ${category.displayName}: $e');
        results[category] = [];
      }
    }
    
    return results;
  }

  // Get emergency services (hospitals and police)
  static Future<List<NearbyLocation>> getEmergencyServices({
    double radius = AppConfig.emergencySearchRadius,
    int limit = 10,
  }) async {
    List<NearbyLocation> emergencyServices = [];
    
    try {
      // Get hospitals
      final hospitals = await searchNearbyPlaces(
        LocationCategory.hospital,
        radius: radius,
        limit: limit ~/ 2,
      );
      emergencyServices.addAll(hospitals);
      
      // Get police stations
      final police = await searchNearbyPlaces(
        LocationCategory.police,
        radius: radius,
        limit: limit ~/ 2,
      );
      emergencyServices.addAll(police);
      
      // Sort by distance
      emergencyServices.sort((a, b) => a.distance.compareTo(b.distance));
      
      return emergencyServices.take(limit).toList();
    } catch (e) {
      print('Error getting emergency services: $e');
      return [];
    }
  }

  // Get healthcare services (hospitals and pharmacies)
  static Future<List<NearbyLocation>> getHealthcareServices({
    double radius = AppConfig.healthcareSearchRadius,
    int limit = 10,
  }) async {
    List<NearbyLocation> healthcareServices = [];
    
    try {
      // Get hospitals
      final hospitals = await searchNearbyPlaces(
        LocationCategory.hospital,
        radius: radius,
        limit: limit ~/ 2,
      );
      healthcareServices.addAll(hospitals);
      
      // Get pharmacies
      final pharmacies = await searchNearbyPlaces(
        LocationCategory.pharmacy,
        radius: radius,
        limit: limit ~/ 2,
      );
      healthcareServices.addAll(pharmacies);
      
      // Sort by distance
      healthcareServices.sort((a, b) => a.distance.compareTo(b.distance));
      
      return healthcareServices.take(limit).toList();
    } catch (e) {
      print('Error getting healthcare services: $e');
      return [];
    }
  }
}

// Extension to add copyWith method to NearbyLocation
extension NearbyLocationCopyWith on NearbyLocation {
  NearbyLocation copyWith({
    String? placeId,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? rating,
    int? userRatingsTotal,
    String? phoneNumber,
    String? website,
    List<String>? types,
    bool? isOpen,
    String? openingHours,
    double? distance,
  }) {
    return NearbyLocation(
      placeId: placeId ?? this.placeId,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rating: rating ?? this.rating,
      userRatingsTotal: userRatingsTotal ?? this.userRatingsTotal,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      types: types ?? this.types,
      isOpen: isOpen ?? this.isOpen,
      openingHours: openingHours ?? this.openingHours,
      distance: distance ?? this.distance,
    );
  }
}
