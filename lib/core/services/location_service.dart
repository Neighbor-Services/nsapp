import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_directions/google_maps_directions.dart' as gmd;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/request_distance.dart';
import 'package:nsapp/core/models/user_location.dart';

class LocationService {
  static Future<gmd.DistanceValue> getDistance({
    required double sourceLat,
    required double sourceLng,
    required double destLat,
    required double destLng,
  }) async {
    var directions = await gmd.distance(
      sourceLat,
      sourceLng,
      destLat,
      destLng,
      googleAPIKey: mapAPIKey,
    );
    return directions;
  }

  static Future<Map<String, dynamic>> getFullDirections({
    required double sourceLat,
    required double sourceLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final results = await gmd.distance(
        sourceLat,
        sourceLng,
        destLat,
        destLng,
        googleAPIKey: mapAPIKey,
      );
      
      return {
        "distance": results.text,
        "duration": "${(results.meters / 1000 * 2).toStringAsFixed(1)} min",
      };
    } catch (e) {
      return {
        "distance": "...",
        "duration": "...",
      };
    }
  }

  static Future<List<LatLng>> getPolylinePoints({
    required double sourceLat,
    required double sourceLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final response = await dio.get(
        "https://maps.googleapis.com/maps/api/directions/json",
        queryParameters: {
          "origin": "$sourceLat,$sourceLng",
          "destination": "$destLat,$destLng",
          "key": mapAPIKey,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data["status"] == "OK") {
          final points = data["routes"][0]["overview_polyline"]["points"];
          return _decodePolyline(points);
        }
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching polyline points: $e");
      return [];
    }
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  static Future<UserLocation?> getLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return null;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
        return null;
      }

      Position position = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      final placemark = placemarks.first;
      
      return UserLocation(
        position: position,
        address: '${placemark.locality} ${placemark.country}',
        city: placemark.locality.toString(),
        state: placemark.administrativeArea.toString(),
        zipCode: placemark.postalCode.toString(),
        country: placemark.country.toString(),
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<UserLocation?> getUserLocationFromLatLng(LatLng loc) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );
      
      final placemark = placemarks.first;
      
      return UserLocation(
        position: Position(
          latitude: loc.latitude,
          longitude: loc.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
        address: '${placemark.locality} ${placemark.country}',
        city: placemark.locality.toString(),
        state: placemark.administrativeArea.toString(),
        zipCode: placemark.postalCode.toString(),
        country: placemark.country.toString(),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<String> getAddressFromMap(LatLng loc) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );
      final placemark = placemarks.first;
      return '${placemark.locality} ${placemark.country}';
    } catch (e) {
      return "";
    }
  }

  static Future<RequestDistance> getProfileDistance(
    String uid, {
    required double sourceLat,
    required double sourceLng,
    required double lat,
    required double lng,
  }) async {
    try {
      final distance = await getDistance(
        sourceLat: sourceLat,
        sourceLng: sourceLng,
        destLat: lat,
        destLng: lng,
      );

      return RequestDistance(
        distance: distance.text,
        dis: distance.meters,
        profile: Profile(),
      );
    } catch (e) {
      return RequestDistance();
    }
  }
}


