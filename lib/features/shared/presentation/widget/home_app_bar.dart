import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart'
    hide ReloadState;
import 'package:nsapp/features/provider/presentation/pages/provider_home_page.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_home_page.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/core/helpers/helpers.dart';

import '../bloc/shared_bloc.dart';
import 'package:nsapp/core/core.dart';

AppBar homeAppBar({
  String? title,
  Color? color,
  Function(bool)? onToggle,
  bool value = false,
  List<PopupMenuEntry<int>>? actions,
  required BuildContext context,
}) {
  final appBarColor = context.appColors.appBarBackground;
  final borderColor = context.appColors.glassBorder;
  final titleColor = context.appColors.primaryTextColor;
  final borderDecorColor = context.appColors.glassBorder;
  final switchInactiveThumb = context.appColors.secondaryTextColor;
  final switchInactiveTrack = context.appColors.iconContainerBackground;
  final iconColor = context.appColors.primaryTextColor;

  return AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    toolbarHeight: 80,
    centerTitle: true,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: appBarColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
    ),
    leadingWidth: 70,
    leading: Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.appColors.secondaryColor,
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: appBlueCardColor,
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
              ),
            ),
          ),
        );
      },
    ),
    title: Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderDecorColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (title ?? (DashboardState.isProvider ? 'PROVIDER' : 'SEEKER'))
                .toUpperCase(),
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    ),
    actions: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        child: BlocBuilder<SharedBloc, SharedState>(
          builder: (context, state) {
            return Helpers.isProvider(ReloadState.type)
                ? Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: value,
                      onChanged: onToggle,
                      activeThumbColor: context.appColors.secondaryColor,
                      activeTrackColor:
                          context.appColors.secondaryColor.withAlpha(50),
                      inactiveThumbColor: switchInactiveThumb,
                      inactiveTrackColor: switchInactiveTrack,
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: PlatformPopupMenu(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(color: borderDecorColor),
            ),
            child: Icon(Icons.grid_view_rounded, color: iconColor, size: 20),
          ),
          options: actions!,
        ),
      ),
    ],
  );
}

class PlatformPopupMenu extends StatelessWidget {
  final Widget icon;
  final List<PopupMenuEntry<int>> options;

  const PlatformPopupMenu({
    super.key,
    required this.icon,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final popupBg = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final dialogBg = context.appColors.cardBackground;
    final textColor = context.appColors.primaryTextColor;
    final subTextColor = context.appColors.secondaryTextColor;
    final shadowColor = context.appColors.glassBorder;

    return PopupMenuButton<int>(
      key: const ValueKey('home_app_bar_popup_menu'),
      icon: icon,
      color: popupBg,
      elevation: 10,
      shadowColor: Colors.black.withAlpha(100),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      itemBuilder: (context) => options,
      onSelected: (value) {
        switch (value) {
          case 1:
            Get.toNamed("/profile");
            break;

          case 2:
            showDialog(
              context: context,
              builder: (context) {
                return Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(24),
                      width: size(context).width * 0.85,
                      constraints: BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: dialogBg,
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: context.appColors.errorColor.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              size: 32,
                              color: context.appColors.errorColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "LOGOUT",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CustomTextWidget(
                            text: "Are you sure you want to logout?",
                            textAlign: TextAlign.center,
                            color: subTextColor,
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Get.back(),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: borderColor),
                                    ),
                                  ),
                                  child: Text(
                                    "CANCEL",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subTextColor,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<SharedBloc>().add(
                                      DisconnectNotificationSocketEvent(),
                                    );
                                    context.read<AuthenticationBloc>().add(
                                      LogoutAuthenticationEvent(),
                                    );
                                    SuccessGetProfileState.profile = Profile();
                                    NavigatorSeekerState.widget =
                                        const SeekerHomePage();
                                    NavigatorSeekerState.page = 1;
                                    NavigatorProviderState.widget =
                                        const ProviderHomePage();
                                    NavigatorProviderState.page = 1;
                                    Get.offAllNamed("/login");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.appColors.errorColor,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "LOGOUT",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
            break;
        }
      },
    );
  }
}
