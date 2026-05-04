import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:nsapp/core/di/injection_container.dart';

IOWebSocketChannel? channel;

Dio get dio => sl<Dio>();

SharedPreferencesWithCache? sharedPreferences;

final Future<SharedPreferencesWithCache> prefs =
    SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );


