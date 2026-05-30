import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_dashboard_page.dart';
import 'package:nsapp/features/provider/presentation/widgets/provider_drawer_widget.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_dashboard_page.dart';
import 'package:nsapp/features/seeker/presentation/widgets/seeker_drawer_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/notification/notification_bloc.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';

import 'package:nsapp/features/shared/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/home_app_bar.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/core/services/notification_navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> scaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is SuccessGetProfileState) {
      final userId = profileState.profile.user?.id;
      if (userId != null) {
        context.read<ProfileBloc>().add(CreateStripeCustomerEvent(userId: userId));
      }
      final isProvider = Helpers.isProvider(profileState.profile.userType);
      context.read<SettingsBloc>().add(ToggleDashboardEvent(isProvider: isProvider));
    }

    context.read<SubscriptionBloc>().add(CheckUserSubscriptionEvent());
    context.read<NotificationBloc>().add(ConnectNotificationSocketEvent());
    context.read<NotificationBloc>().add(GetTokenEvent());
    context.read<MessageBloc>().add(ConnectGlobalPresenceEvent());

    NotificationNavigator.consumePendingNavigation();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<MessageBloc>().add(ConnectGlobalPresenceEvent());
      context.read<MessageBloc>().add(GetMyMessagesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return BlocBuilder<ProviderBloc, ProviderState>(
          builder: (context, providerState) {
            return BlocBuilder<SeekerBloc, SeekerState>(
              builder: (context, seekerState) {
                final isProvider = settingsState.isProvider;


                return Scaffold(
                  extendBodyBehindAppBar: true,
                  key: scaffold,
                  appBar: homeAppBar(
                          context: context,
                          color: context.appColors.surfaceBackground,
                          title: isProvider ? 'PROVIDER' : 'SEEKER',
                          actions: [
                            PopupMenuItem(
                              value: 1,
                              child: BlocBuilder<ProfileBloc, ProfileState>(
                                builder: (context, profileState) {
                                  final profile = profileState.profile ?? Profile();
                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 15.r,
                                        backgroundImage:
                                            (profile.profilePictureUrl != null &&
                                                profile.profilePictureUrl!.isNotEmpty &&
                                                !profile.profilePictureUrl!.startsWith("file:///"))
                                            ? CachedNetworkImageProvider(profile.profilePictureUrl!)
                                            : AssetImage(logo2Assets) as ImageProvider,
                                      ),
                                      const SizedBox(width: 10),
                                      CustomTextWidget(
                                        text: profile.firstName ?? "",
                                        color: context.appColors.primaryTextColor,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            PopupMenuItem(
                              value: 2,
                              child: Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.rightFromBracket, size: 30.r, color: context.appColors.errorColor),
                                  SizedBox(width: 10.w),
                                  CustomTextWidget(
                                    text: "LOGOUT",
                                    color: context.appColors.errorColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          value: isProvider,
                          onToggle: (val) {
                            context.read<SettingsBloc>().add(
                              ToggleDashboardEvent(isProvider: val),
                            );
                          },
                        ),
                  drawer: isProvider
                      ? ProviderDrawerWidget()
                      : SeekerDrawerWidget(),
                  body: SafeArea(
                    child: IndexedStack(
                      index: isProvider ? 0 : 1,
                      children: const [
                        ProviderDashboardPage(),
                        SeekerDashboardPage(),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}


