import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TrackingService {
  WebSocketChannel? _channel;
  StreamSubscription<Position>? _positionSubscription;
  final _locationController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get locationStream => _locationController.stream;

  Future<void> startTracking(String appointmentId, bool isProvider) async {
    final token = await Helpers.getToken();
    // Construct the WebSocket URL. Replaces http with ws if needed.
    String wsUrl = baseMessagesWsUrl;
    if (!wsUrl.startsWith('ws')) {
      wsUrl = wsUrl.replaceFirst('http', 'ws');
    }

    final url = '$wsUrl/ws/tracking/$appointmentId/?token=$token';
    debugPrint('Connecting to Tracking WS: $url');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (message) {
          final data = json.decode(message);
          _locationController.add(data);
        },
        onError: (error) {
          debugPrint('Tracking WebSocket Error: $error');
        },
        onDone: () {
          debugPrint('Tracking WebSocket Closed');
        },
      );

      if (isProvider) {
        _startProvidingLocation();
      }
    } catch (e) {
      debugPrint('Error connecting to Tracking WebSocket: $e');
    }
  }

  void _startProvidingLocation() {
    _positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          if (_channel != null) {
            _channel!.sink.add(
              json.encode({
                'latitude': position.latitude,
                'longitude': position.longitude,
                'heading': position.heading,
              }),
            );
          }
        });
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
