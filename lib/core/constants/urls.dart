import 'package:nsapp/core/config/app_config.dart';

String domaineUrl = 'https://neighborservice.com';
String baseUrl = 'https://neighborservice.com/api/v1';
String baseRequestUrl = baseUrl;
String baseMessagesUrl = baseUrl;
String baseAccountsUrl = baseUrl;
String basePaymentUrl = baseUrl;

String baseMessagesWsUrl = 'wss://neighborservice.com';

Map<String, dynamic> dioHeaders(String token) => {
  "Authorization": "Bearer $token",
  "Content-Type": "application/json",
};

Map<String, dynamic> dioMultiPartHeaders(String token) => {
  "Authorization": "Bearer $token",
};

// Agora Configuration removed



