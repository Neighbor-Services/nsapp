import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart'
    hide ReloadState;
import 'package:nsapp/features/provider/presentation/pages/provider_home_page.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_home_page.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import '../../../../core/constants/string_constants.dart';
import 'package:nsapp/core/helpers/helpers.dart';

import '../../../../core/constants/dimension.dart';
import '../bloc/shared_bloc.dart';

AppBar homeAppBar({
  String? title,
  Color? color,
  Function(bool)? onToggle,
  bool value = false,
  List<PopupMenuEntry<int>>? actions,
  required BuildContext context,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final appBarColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
  final borderColor = isDark ? Colors.white12 : Colors.black.withAlpha(20);
  final titleBg = isDark
      ? Colors.white.withAlpha(15)
      : Colors.black.withAlpha(5);
  final titleColor = isDark ? Colors.white : Colors.black87;
  final borderDecorColor = isDark
      ? Colors.white.withAlpha(20)
      : Colors.black.withAlpha(10);
  final switchInactiveThumb = isDark ? Colors.white70 : Colors.grey;
  final switchInactiveTrack = isDark
      ? Colors.white.withAlpha(20)
      : Colors.black.withAlpha(10);
  final iconColor = isDark ? Colors.white : Colors.black87;
  final actionIconBg = isDark
      ? Colors.white.withAlpha(15)
      : Colors.black.withAlpha(5);

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
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      appOrangeColor1.withAlpha(200),
                      appOrangeColor2.withAlpha(200),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: appOrangeColor1.withAlpha(80),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: titleBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderDecorColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title ?? (DashboardState.isProvider ? 'Provider' : 'Seeker'),
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: BlocBuilder<SharedBloc, SharedState>(
          builder: (context, state) {
            return Helpers.isProvider(ReloadState.type)
                ? Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: value,
                      onChanged: onToggle,
                      activeThumbColor: appOrangeColor1,
                      activeTrackColor: appOrangeColor1.withAlpha(50),
                      inactiveThumbColor: switchInactiveThumb,
                      inactiveTrackColor: switchInactiveTrack,
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: PlatformPopupMenu(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: actionIconBg,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final popupBg = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);
    final dialogBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white.withAlpha(200) : Colors.black54;
    final shadowColor = isDark
        ? Colors.black.withAlpha(40)
        : Colors.grey.withAlpha(30);

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
                      padding: const EdgeInsets.all(24),
                      width: size(context).width * 0.85,
                      constraints: const BoxConstraints(maxWidth: 400),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: dialogBg,
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              size: 32,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: borderColor),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: subTextColor,
                                      fontWeight: FontWeight.w600,
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
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
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
