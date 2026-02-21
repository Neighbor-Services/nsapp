import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_directions/google_maps_directions.dart' as gmd;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/request_distance.dart';

class LocationService {
  static Future<gmd.DistanceValue> getDistance({
    required double lat,
    required double lng,
  }) async {
    var directions = await gmd.distance(
      locationData.latitude,
      locationData.longitude,
      lat,
      lng,
      googleAPIKey: mapAPIKey,
    );
    return directions;
  }

  static Future<Map<String, dynamic>> getFullDirections({
    required double lat,
    required double lng,
  }) async {
    try {
      final results = await gmd.distance(
        locationData.latitude,
        locationData.longitude,
        lat,
        lng,
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

  static Future<bool> getLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return false;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
          'Location permissions are permanently denied, we cannot request permissions.',
        );
        return false;
      }

      locationData = await Geolocator.getCurrentPosition();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        locationData.latitude,
        locationData.longitude,
      );
      city = placemarks.first.locality.toString();
      countryState = placemarks.first.administrativeArea.toString();
      zipCode = placemarks.first.postalCode.toString();
      country = placemarks.first.country.toString();

      myAddress = '${placemarks.first.locality} ${placemarks.first.country}';
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<String> getAddressFromMap(LatLng loc) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        loc.latitude,
        loc.longitude,
      );
      city = placemarks.first.locality.toString();
      countryState = placemarks.first.administrativeArea.toString();
      zipCode = placemarks.first.postalCode.toString();
      country = placemarks.first.country.toString();
      myAddress = '${placemarks.first.locality} ${placemarks.first.country}';
      return myAddress;
    } catch (e) {
      return "";
    }
  }

  static Future<RequestDistance> getProfileDistance(
    String uid, {
    required double lat,
    required double lng,
  }) async {
    try {
      final distance = await getDistance(lat: lat, lng: lng);
      // final user = await store.collection("profiles").doc(uid).get();

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
