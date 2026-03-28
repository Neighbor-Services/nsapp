import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_home_page.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_appointment_list_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_appointment_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_home_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_page.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/pages/report_page.dart';
import 'package:nsapp/features/shared/presentation/pages/settings_page.dart';
import 'package:nsapp/features/shared/presentation/pages/disputes_list_page.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/core/core.dart';

class SeekerDrawerWidget extends StatelessWidget {
  const SeekerDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.appColors.primaryBackground;
    final borderColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.secondaryTextColor;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(right: BorderSide(color: borderColor, width: 0.5)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, isDark, textColor, secondaryTextColor),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.home_rounded,
                      title: "Home",
                      onTap: () {
                        context.read<SeekerBloc>().add(
                          NavigateSeekerEvent(
                            page: 1,
                            widget: SeekerHomePage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isSelected: NavigatorSeekerState.page == 1,
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.description_rounded,
                      title: "My Requests",
                      onTap: () {
                        context.read<SeekerBloc>().add(
                          NavigateSeekerEvent(
                            page: NavigatorSeekerState.page,
                            widget: SeekerRequestPage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.calendar_month_rounded,
                      title: "Calendar",
                      onTap: () {
                        context.read<SeekerBloc>().add(
                          NavigateSeekerEvent(
                            page: NavigatorSeekerState.page,
                            widget: SeekerAppointmentPage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.view_list_rounded,
                      title: "Appointments",
                      onTap: () {
                        context.read<SeekerBloc>().add(
                          NavigateSeekerEvent(
                            page: NavigatorSeekerState.page,
                            widget: const SeekerAppointmentListPage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.gavel_rounded,
                      title: "Disputes",
                      onTap: () {
                        context.read<SeekerBloc>().add(
                          NavigateSeekerEvent(
                            page: 1,
                            widget: const DisputesListPage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(
                        color: context.appColors.glassBorder,
                      ),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings_rounded,
                      title: "Settings",
                      onTap: () {
                        context.read<SeekerBloc>().add(
                          NavigateSeekerEvent(
                            page: NavigatorSeekerState.page,
                            widget: SettingsPage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.report_problem_rounded,
                      title: "Report Issue",
                      onTap: () {
                        context.read<SeekerBloc>().add(
                          NavigateSeekerEvent(
                            page: NavigatorSeekerState.page,
                            widget: ReportPage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                      textColor: textColor,
                    ),
                  ],
                ),
              ),
              _buildFooter(context, isDark, textColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final profile = SuccessGetProfileState.profile;
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [context.appColors.secondaryColor, context.appColors.secondaryColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.secondaryColor.withAlpha(50),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: context.appColors.primaryTextColor,
                  backgroundImage:
                      (profile.profilePictureUrl != null &&
                          profile.profilePictureUrl!.isNotEmpty &&
                          !profile.profilePictureUrl!.startsWith("file:///"))
                      ? NetworkImage(profile.profilePictureUrl!)
                      : const AssetImage(logo2Assets) as ImageProvider,
                ),
              ),
              const Spacer(),
              _buildIconButton(context, Icons.edit_note_rounded, () {
                Navigator.pop(context);
                Get.toNamed("/edit-profile");
              }, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.firstName ?? "Seeker",
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.user?.email ?? "",
            style: TextStyle(color: secondaryTextColor, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.appColors.secondaryColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.appColors.secondaryColor.withAlpha(50)),
            ),
            child:  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 12,
                  color: context.appColors.secondaryColor,
                ),
                SizedBox(width: 4),
                Text(
                  "SEEKER",
                  style: TextStyle(
                    color: context.appColors.secondaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    required bool isDark,
    required Color textColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected
                  ? context.appColors.glassBorder
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: context.appColors.glassBorder,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? context.appColors.primaryColor
                      : context.appColors.primaryTextColor,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? context.appColors.primaryColor
                        : context.appColors.primaryTextColor,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.appColors.primaryColor.withAlpha(30),
          shape: BoxShape.circle,
          border: Border.all(
            color: context.appColors.glassBorder,
          ),
        ),
        child: Icon(
          icon,
          color: context.appColors.primaryColor,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark, Color textColor) {
    final subTextColor = context.appColors.secondaryTextColor;
    final borderColor = context.appColors.glassBorder;
    final shadowColor = context.appColors.glassBorder;

    final dialogBg = context.appColors.primaryBackground;
    return GestureDetector(
      onTap: () {
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
                        child:  Icon(
                          Icons.logout_rounded,
                          size: 32,
                          color: context.appColors.errorColor,
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
                                padding: EdgeInsets.symmetric(
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
                                backgroundColor: context.appColors.errorColor,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: context.appColors.errorColor,
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
      },
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.appColors.glassBorder,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.logout_rounded, color: context.appColors.errorColor, size: 20),
            const SizedBox(width: 12),
            Text(
              "Logout",
              style: TextStyle(
                color: context.appColors.primaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
