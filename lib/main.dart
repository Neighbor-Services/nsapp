import 'package:flutter/material.dart';
import 'package:nsapp/core/routes/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nsapp/core/constants/app_dark_theme.dart';
import 'package:nsapp/core/constants/app_light_theme.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/di/injection_container.dart' as di;
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/utils/responsive_size.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/core/services/local_notification_service.dart';
import 'package:nsapp/features/shared/presentation/bloc/location/location_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/dispute/dispute_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/notification/notification_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/legal/legal_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/core/services/background_notification_service.dart';
import 'package:nsapp/core/services/device_token_service.dart';
import 'firebase_options.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart' hide Transition;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:nsapp/core/config/app_config.dart';

Future<void> main() async {
  await bootstrap(AppEnvironment.prod);
}

Future<void> bootstrap(AppEnvironment env) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  String envFile = "assets/.env.dev";
  if (env == AppEnvironment.stage) envFile = "assets/.env.stage";
  if (env == AppEnvironment.prod) envFile = "assets/.env.prod";
  
  await dotenv.load(fileName: envFile);

  AppConfig.setConfig(AppConfig(
    environment: env,
    baseUrl: dotenv.env['BASE_URL'] ?? domaineUrl,
    wsUrl: dotenv.env['WS_URL'] ?? baseMessagesWsUrl,
    stripePublishableKey: dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? "",
    googleMapApiKey: dotenv.env['GOOGLE_MAP_API'] ?? "",
    agoraAppId: dotenv.env['AGORA_APP_ID'] ?? "",
  ));

  // Firebase Setup
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  // HydratedBloc Setup
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = storage;

  
  // Stripe Setup
  Stripe.publishableKey = AppConfig.instance.stripePublishableKey;
  Stripe.merchantIdentifier = "merchant.flutter.stripe.test";
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  // Dependency Injection Init
  await di.init();

  // Dio Setup
  dio.options.baseUrl = AppConfig.instance.baseUrl;

  // Local Notifications Init
  await LocalNotificationService.initialize();

  // Background Service Init (Android only)
  await BackgroundNotificationService.initializeService();

  // Foreground WebSocket — connected after login, not at cold boot.
  // BackgroundNotificationService.connectForeground() is called in AuthenticationBloc
  // after a successful login / token validation.

  // Initialize Native Notification Token Listener (iOS)
  DeviceTokenService.initialize();


  // Notification permission is requested inside BackgroundNotificationService.initializeService()
  // via FirebaseMessaging.instance.requestPermission(), covering both iOS and Android 13+.

  runApp(
      const NeighborServiceApp(),
  );
}

class NeighborServiceApp extends StatelessWidget {
  const NeighborServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (_) => di.sl<AuthenticationBloc>(),
        ),
        BlocProvider<ProfileBloc>(create: (_) => di.sl<ProfileBloc>()),
        BlocProvider<MessageBloc>(create: (_) => di.sl<MessageBloc>()),
        BlocProvider<SeekerBloc>(create: (_) => di.sl<SeekerBloc>()),
        BlocProvider<ProviderBloc>(create: (_) => di.sl<ProviderBloc>()),
        BlocProvider<LocationBloc>(
          create: (_) => di.sl<LocationBloc>()..add(GetLocationEvent()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => di.sl<SettingsBloc>()..add(LoadThemeModeEvent()),
        ),
        BlocProvider<WalletBloc>(create: (_) => di.sl<WalletBloc>()),
        BlocProvider<DisputeBloc>(create: (_) => di.sl<DisputeBloc>()),
        BlocProvider<NotificationBloc>(create: (_) => di.sl<NotificationBloc>()),
        BlocProvider<LegalBloc>(create: (_) => di.sl<LegalBloc>()),
        BlocProvider<SubscriptionBloc>(create: (_) => di.sl<SubscriptionBloc>()),
        BlocProvider<CommonBloc>(create: (_) => di.sl<CommonBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) => previous.themeMode != current.themeMode,
        builder: (context, state) {
          return MaterialApp.router(
            title: "Neighbor Service App",
            theme: providerLightTheme,
            darkTheme: providerDarkTheme,
            themeMode: state.themeMode,
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              Responsive.init(context);
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}


