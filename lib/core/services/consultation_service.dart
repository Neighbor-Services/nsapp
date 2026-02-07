import 'package:dio/dio.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';

class ConsultationService {
  static Future<Map<String, dynamic>?> getRTCToken({
    required String channelName,
    int uid = 0,
  }) async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseUrl/consultations/rtc-token/",
        queryParameters: {'channel_name': channelName, 'uid': uid},
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getRTMToken() async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseUrl/consultations/rtm-token/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
