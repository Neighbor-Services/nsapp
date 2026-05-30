import 'package:dio/dio.dart';
import 'package:web_socket_channel/io.dart';
import 'package:nsapp/core/di/injection_container.dart';

IOWebSocketChannel? channel;

Dio get dio => sl<Dio>();


