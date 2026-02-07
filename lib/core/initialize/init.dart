import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

Position locationData = Position(
  longitude: 12.5433,
  latitude: 1.5433,
  timestamp: DateTime.now(),
  accuracy: 10.0,
  altitude: 12.0,
  altitudeAccuracy: 10.0,
  heading: 10.0,
  headingAccuracy: 10.0,
  speed: 10.0,
  speedAccuracy: 10.0,
);
String myAddress = "";
String country = "";
String city = "";
String countryState = "";
String zipCode = "";

IOWebSocketChannel? channel;
XFile? image;

Dio dio = Dio();

List<XFile>? images;

bool isAuthenticated = false;

TextEditingController locController = TextEditingController();

int radiusDistance = 25;
SharedPreferencesWithCache? sharedPreferences;

final Future<SharedPreferencesWithCache> prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
