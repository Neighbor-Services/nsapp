import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SharedBloc, SharedState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          key: scaffold,
          appBar: homeAppBar(
            context: context,
            color: context.appColors.surfaceBackground,
            title: DashboardState.isProvider ? 'PROVIDER' : 'SEEKER',
            actions: [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 15.r,
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
                      color: context.appColors.primaryTextColor,
                    ),
                  ],
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
                      fontWeight: FontWeight.bold,
                    ),
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
          body: SafeArea(
            child: Center(
              child: (DashboardState.isProvider)
                  ? ProviderDashboardPage()
                  : SeekerDashboardPage(),
            ),
          ),
        );
      },
    );
  }
}



