import 'package:geolocator/geolocator.dart';

class UserLocation {
  final Position position;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;

  UserLocation({
    required this.position,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
  });

  factory UserLocation.initial() {
    return UserLocation(
      position: Position(
        longitude: 0,
        latitude: 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      ),
      address: "",
      city: "",
      state: "",
      country: "",
      zipCode: "",
    );
  }

  UserLocation copyWith({
    Position? position,
    String? address,
    String? city,
    String? state,
    String? country,
    String? zipCode,
  }) {
    return UserLocation(
      position: position ?? this.position,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      zipCode: zipCode ?? this.zipCode,
    );
  }
}
