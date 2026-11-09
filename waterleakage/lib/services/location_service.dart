import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final bool isSuccess;
  final double? latitude;
  final double? longitude;
  final String? errorMessage;
  final String? addressSuggestion;

  LocationResult({
    required this.isSuccess,
    this.latitude,
    this.longitude,
    this.errorMessage,
    this.addressSuggestion,
  });

  String get formattedCoordinates {
    if (latitude != null && longitude != null) {
      final latSuffix = latitude! >= 0 ? 'N' : 'S';
      final lonSuffix = longitude! >= 0 ? 'E' : 'W';
      return '${latitude!.abs().toStringAsFixed(4)}° $latSuffix, ${longitude!.abs().toStringAsFixed(4)}° $lonSuffix';
    }
    return 'Coordinates unavailable';
  }
}

class LocationService {
  /// Fetches the user's current GPS position with full permission checks.
  static Future<LocationResult> getCurrentLocation() async {
    try {
      // 1. Check if location services are enabled on the device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          isSuccess: false,
          errorMessage: 'Location services are disabled on your device. Please enable GPS in device settings.',
        );
      }

      // 2. Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            isSuccess: false,
            errorMessage: 'Location permissions were denied by the user.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          isSuccess: false,
          errorMessage: 'Location permissions are permanently denied. Please grant location access from app settings.',
        );
      }

      // 3. Obtain location coordinates
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      return LocationResult(
        isSuccess: true,
        latitude: position.latitude,
        longitude: position.longitude,
        addressSuggestion: 'GPS Pin: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
      );
    } catch (e) {
      debugPrint('Error getting GPS location: $e');
      // Graceful fallback for emulators or unsupported platforms
      return LocationResult(
        isSuccess: false,
        errorMessage: 'Unable to acquire GPS signal. You can manually enter the street address.',
      );
    }
  }
}
