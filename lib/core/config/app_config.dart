enum AppEnvironment { dev, stage, prod }

class AppConfig {
  final AppEnvironment environment;
  final String baseUrl;
  final String wsUrl;
  final String stripePublishableKey;
  final String googleMapApiKey;
  final String agoraAppId;

  AppConfig({
    required this.environment,
    required this.baseUrl,
    required this.wsUrl,
    required this.stripePublishableKey,
    required this.googleMapApiKey,
    required this.agoraAppId,
  });

  static late AppConfig _instance;

  static AppConfig get instance => _instance;

  static void setConfig(AppConfig config) {
    _instance = config;
  }

  bool get isDev => environment == AppEnvironment.dev;
  bool get isStage => environment == AppEnvironment.stage;
  bool get isProd => environment == AppEnvironment.prod;
}
