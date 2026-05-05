import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/constants/app_dark_theme.dart';
import 'package:nsapp/core/constants/app_light_theme.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/di/injection_container.dart' as di;
import 'package:nsapp/core/helpers/pages.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

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
  Stripe.publishableKey = stripePublishableKey;
  Stripe.merchantIdentifier = "merchant.flutter.stripe.test";
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  // Dio Setup
  dio.options.baseUrl = baseUrl;

  // Dependency Injection Init
  await di.init();

  // Local Notifications Init
  await LocalNotificationService.initialize();

  // Background Service Init (Android only)
  await BackgroundNotificationService.initializeService();

  // Foreground WebSocket
  BackgroundNotificationService.connectForeground();

  // Initialize Native Notification Token Listener (iOS)
  DeviceTokenService.initialize();


  // Request Notifications Permission
  await Permission.notification.request();

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
          return GetMaterialApp(
            title: "Neighbor Service App",
            theme: providerLightTheme,
            darkTheme: providerDarkTheme,
            themeMode: state.themeMode,
            initialRoute: "/",
            getPages: pages,
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


