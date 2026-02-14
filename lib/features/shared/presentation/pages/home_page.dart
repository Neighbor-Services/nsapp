import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_dashboard_page.dart';
import 'package:nsapp/features/provider/presentation/widgets/provider_drawer_widget.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_dashboard_page.dart';
import 'package:nsapp/features/seeker/presentation/widgets/seeker_drawer_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/home_app_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> scaffold = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Helpers.createStripeCustomer();

    context.read<SharedBloc>().add(CheckUserSubscriptionEvent());
    context.read<SharedBloc>().add(ConnectNotificationSocketEvent());
    context.read<SharedBloc>().add(GetTokenEvent());
    if (Helpers.isProvider(SuccessGetProfileState.profile.userType)) {
      context.read<SharedBloc>().add(SharedBlocReloadEvent("PROVIDER"));
      context.read<SharedBloc>().add(ToggleDashboardEvent(isProvider: true));
    }
    super.initState();
    InternetConnection().onStatusChange.listen((status) {
      switch (status) {
        case InternetStatus.connected:
          Helpers.getLocation();

          break;
        case InternetStatus.disconnected:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomTextWidget(
                text: "Please check your internet connection",
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          );

          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocConsumer<SharedBloc, SharedState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          key: scaffold,
          appBar: homeAppBar(
            context: context,
            color: DashboardState.isProvider
                ? appBlueCardColor
                : appOrangeColor1,
            title: DashboardState.isProvider ? 'PROVIDER' : 'SEEKER',
            actions: [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundImage:
                          (SuccessGetProfileState.profile.profilePictureUrl !=
                                  null &&
                              SuccessGetProfileState
                                  .profile
                                  .profilePictureUrl!
                                  .isNotEmpty &&
                              !SuccessGetProfileState.profile.profilePictureUrl!
                                  .startsWith("file:///"))
                          ? NetworkImage(
                              SuccessGetProfileState.profile.profilePictureUrl!,
                            )
                          : AssetImage(logo2Assets) as ImageProvider,
                    ),
                    const SizedBox(width: 10),
                    CustomTextWidget(
                      text: SuccessGetProfileState.profile.firstName ?? "",
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 30, color: Colors.redAccent),
                    const SizedBox(width: 10),
                    CustomTextWidget(text: "Logout", color: Colors.redAccent),
                  ],
                ),
              ),
            ],
            value: DashboardState.isProvider,
            onToggle: (val) {
              context.read<SharedBloc>().add(
                ToggleDashboardEvent(isProvider: val),
              );
            },
          ),
          drawer: (DashboardState.isProvider)
              ? ProviderDrawerWidget()
              : SeekerDrawerWidget(),
          body: Center(
            child: (DashboardState.isProvider)
                ? ProviderDashboardPage()
                : SeekerDashboardPage(),
          ),
        );
      },
    );
  }
}
