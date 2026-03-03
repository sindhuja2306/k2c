import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  static Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current position
  static Future<Position?> getCurrentPosition() async {
    try {
      bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        print('Location permission not granted');
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      );

      print('Position obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Get address from coordinates
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      print('Getting address for: $latitude, $longitude');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      print('Placemarks received: ${placemarks.length}');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String? safeValue(String? Function() reader) {
          try {
            final value = reader();
            if (value == null) return null;
            final trimmed = value.trim();
            return trimmed.isEmpty ? null : trimmed;
          } catch (_) {
            return null;
          }
        }

        // Build a readable address with as much detail as available.
        List<String> addressParts = [];

        void addAddressPart(String? Function() reader) {
          final value = safeValue(reader);
          if (value != null) {
            addressParts.add(value);
          }
        }

        addAddressPart(() => place.name);
        addAddressPart(() => place.subThoroughfare);
        addAddressPart(() => place.thoroughfare);
        addAddressPart(() => place.street);
        addAddressPart(() => place.subLocality);
        addAddressPart(() => place.locality);
        addAddressPart(() => place.subAdministrativeArea);
        addAddressPart(() => place.administrativeArea);
        addAddressPart(() => place.postalCode);
        addAddressPart(() => place.country);

        if (addressParts.isEmpty) {
          final fallback =
              '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
          print('No address parts found, using coordinates: $fallback');
          return fallback;
        }

        String fullAddress = addressParts.join(', ');
        print('Full address: $fullAddress');
        return fullAddress;
      }

      final fallback = '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
      print('No placemarks found, using coordinates: $fallback');
      return fallback;
    } catch (e) {
      print('Error getting address: $e');
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    }
  }

  /// Get current location with address
  static Future<String?> getCurrentLocationAddress() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) {
        return null;
      }

      String? address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return address;
    } catch (e) {
      print('Error getting current location address: $e');
      return null;
    }
  }

  /// Open location settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
