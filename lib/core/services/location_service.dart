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
    // Assuming locationData is up-to-date or fetching it here if needed.
    // For now using the global locationData from init.dart as per original code.
    var directions = await gmd.distance(
      locationData.latitude,
      locationData.longitude,
      lat,
      lng,
      googleAPIKey: mapAPIKey,
    );
    return directions;
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
