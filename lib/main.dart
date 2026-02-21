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
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/helpers/pages.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/core/services/local_notification_service.dart';
import 'package:nsapp/core/services/background_notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");

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

  // Background Service Init
  await BackgroundNotificationService.initializeService();

  // Location Permission (Delegated to Helpers/LocationService)
  // If requestPermission exists in Helpers, call it. Otherwise getLocation checks permissions.
  // Using getLocation calls init logic.
  Helpers.getLocation();

  // Request Notifications Permission
  await Permission.notification.request();

  runApp(const NeighborServiceApp());
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
        BlocProvider<SharedBloc>(
          create: (_) => di.sl<SharedBloc>()..add(LoadThemeModeEvent()),
        ),
        BlocProvider<MessageBloc>(create: (_) => di.sl<MessageBloc>()),
        BlocProvider<SeekerBloc>(create: (_) => di.sl<SeekerBloc>()),
        BlocProvider<ProviderBloc>(create: (_) => di.sl<ProviderBloc>()),
      ],
      child: BlocBuilder<SharedBloc, SharedState>(
        buildWhen: (previous, current) => current is ThemeModeState,
        builder: (context, snapshot) {
          return GetMaterialApp(
            title: "Neighbor Service App",
            theme: providerLightTheme,
            darkTheme: providerDarkTheme,
            themeMode: ThemeModeState.themeMode,
            initialRoute: "/",
            getPages: pages,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
