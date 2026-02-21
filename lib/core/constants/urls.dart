const String domaineUrl = "https://neighborservice.com";
const String baseUrl = "$domaineUrl/api/v1";
const String baseRequestUrl = baseUrl;
const String baseMessagesUrl = baseUrl;
const String baseAccountsUrl = baseUrl;
const String basePaymentUrl = baseUrl;

const String baseMessagesWsUrl = "wss://neighborservice.com";

Map<String, dynamic> dioHeaders(String token) => {
  "Authorization": "Bearer $token",
  "Content-Type": "application/json",
};

Map<String, dynamic> dioMultiPartHeaders(String token) => {
  "Authorization": "Bearer $token",
};

// Agora Configuration (Fetched from backend, this is a placeholder/fallback)
const String agoraAppId = "b0896e1d349345b2bda08c7ad32dc112";

