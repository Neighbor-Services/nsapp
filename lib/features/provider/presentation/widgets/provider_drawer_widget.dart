import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/profile/presentation/pages/about_page.dart';
import 'package:nsapp/features/profile/presentation/pages/add_about_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_accepted_request_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_active_tasks_page.dart';
import 'package:nsapp/features/shared/presentation/bloc/notification/notification_bloc.dart';
import 'package:nsapp/features/shared/presentation/pages/report_page.dart';
import 'package:nsapp/features/shared/presentation/pages/settings_page.dart';
import 'package:nsapp/features/shared/presentation/pages/subscription_page.dart';
import 'package:nsapp/features/shared/presentation/pages/disputes_list_page.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../bloc/provider_bloc.dart';
import '../pages/provider_appointment_list_page.dart';
import 'package:nsapp/core/core.dart';

class ProviderDrawerWidget extends StatelessWidget {
  const ProviderDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.appColors.primaryBackground;
    final borderColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;

    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => 
        current is SuccessGetProfileState || 
        current is SuccessGetProfileStreamState,
      builder: (context, profileState) {
        final profile = (profileState is SuccessGetProfileState)
            ? profileState.profile
            : Profile();

        return BlocBuilder<ProviderBloc, ProviderState>(
          builder: (context, providerState) {
            final currentPage = (providerState is ProviderTabChangedState)
                ? providerState.tabIndex
                : 1;

            return Drawer(
              backgroundColor: Colors.transparent,
              elevation: 0,
              width: 280.w,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border(right: BorderSide(color: borderColor, width: 0.5.w)),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context, profile, isDark, textColor, secondaryTextColor),
                      SizedBox(height: 20.h),
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          children: [
                            _buildDrawerItem(
                              context,
                              icon: FontAwesomeIcons.house,
                              title: "Home",
                              onTap: () {
                                Navigator.pop(context);
                                context.read<ProviderBloc>().add(ChangeProviderTabEvent(tabIndex: 1));
                              },
                              isSelected: currentPage == 1,
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: FontAwesomeIcons.circleCheck,
                              title: "My Jobs",
                              onTap: () {
                                Navigator.pop(context);
                                Get.to(() => const ProviderAcceptedRequestPage());
                              },
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: FontAwesomeIcons.briefcase,
                              title: "Active Tasks",
                              onTap: () {
                                Navigator.pop(context);
                                Get.to(() => const ProviderActiveTasksPage());
                              },
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: FontAwesomeIcons.listUl,
                              title: "Appointments",
                              onTap: () {
                                Navigator.pop(context);
                                Get.to(() => const ProviderAppointmentListPage());
                              },
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: FontAwesomeIcons.video,
                              title: "Subscription",
                              onTap: () {
                                Navigator.pop(context);
                                Get.to(() => const SubscriptionPage());
                              },
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            if (profile.preferredPaymentMode != 'ON_SITE')
                              _buildDrawerItem(
                                context,
                                icon: FontAwesomeIcons.wallet,
                                title: "Wallet",
                                onTap: () {
                                  Get.to(() => const WalletPage());
                                  Navigator.pop(context);
                                },
                                isDark: isDark,
                                textColor: textColor,
                              ),
                            _buildDrawerItem(
                              context,
                              icon: FontAwesomeIcons.gavel,
                              title: "Disputes",
                              onTap: () {
                                Navigator.pop(context);
                                Get.to(() => const DisputesListPage());
                              },
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Divider(
                                color: context.appColors.glassBorder,
                              ),
                            ),
                            _buildDrawerItem(
                              context,
                              icon: FontAwesomeIcons.circleInfo,
                              title: "Portfolio",
                              onTap: () {
                                Navigator.pop(context);
                                context.read<ProfileBloc>().add(
                                  AboutUserEvent(
                                    userID: profile.user?.id ?? "",
                                  ),
                                );
                                Get.to(() => AboutPage(profile: profile));
                              },
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: FontAwesomeIcons.user,
                              title: "About",
                              onTap: () {
                                Navigator.pop(context);
                                Get.to(() => const AddAboutPage());
                              },
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: FontAwesomeIcons.gear,
                              title: "Settings",
                              onTap: () {
                                Navigator.pop(context);
                                Get.to(() => const SettingsPage());
                              },
                              isDark: isDark,
                              textColor: textColor,
                            ),
                            _buildDrawerItem(
                              context,
                              icon: FontAwesomeIcons.triangleExclamation,
                              title: "Report Issue",
                              onTap: () {
                                Navigator.pop(context);
                                Get.to(() => const ReportPage());
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
          },
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Profile profile,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Container(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.r),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: context.appColors.primaryGradient,
                  
                ),
                child: CircleAvatar(
                  radius: 32.r,
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
              _buildIconButton(context, FontAwesomeIcons.penToSquare, () {
                Navigator.pop(context);
                Get.toNamed("/edit-profile");
              }, isDark),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            profile.firstName ?? "Provider",
            style: TextStyle(
              color: textColor,
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            profile.user?.email ?? "",
            style: TextStyle(color: context.appColors.secondaryTextColor, fontSize: 12.sp),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: context.appColors.primaryColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: context.appColors.primaryColor.withAlpha(50)),
            ),
            child:  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.helmetSafety,
                  size: 12.r,
                  color: context.appColors.primaryColor,
                ),
                SizedBox(width: 4.w),
                Text(
                  "PROVIDER",
                  style: TextStyle(
                    color: context.appColors.primaryColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
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
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
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
                  size: 22.r,
                ),
                SizedBox(width: 16.w),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? context.appColors.primaryColor
                        : context.appColors.primaryTextColor,
                    fontSize: 15.sp,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
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
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: context.appColors.primaryColor.withAlpha(50),
          shape: BoxShape.circle,
          border: Border.all(
            color: context.appColors.primaryColor,
          ),
        ),
        child: Icon(
          icon,
          color: context.appColors.primaryColor,
          size: 20.r,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark, Color textColor) {
    final subTextColor = context.appColors.secondaryTextColor;
    final borderColor = context.appColors.glassBorder;

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
                  padding: EdgeInsets.all(24.r),
                  width: MediaQuery.of(context).size.width * 0.85,
                  constraints: BoxConstraints(maxWidth: 400.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    color: dialogBg,
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: context.appColors.errorColor.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FontAwesomeIcons.rightFromBracket,
                          size: 32.r,
                          color: context.appColors.errorColor,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      CustomTextWidget(
                        text: "Are you sure you want to logout?",
                        textAlign: TextAlign.center,
                        color: subTextColor,
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Get.back(),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  side: BorderSide(color: borderColor),
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: subTextColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<NotificationBloc>().add(
                                  DisconnectNotificationSocketEvent(),
                                );
                                context.read<AuthenticationBloc>().add(
                                  LogoutAuthenticationEvent(),
                                );
                                Get.offAllNamed("/login");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.appColors.errorColor,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
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
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.appColors.glassBorder,
            ),
          ),
        ),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.rightFromBracket, color: context.appColors.errorColor, size: 20.r),
            SizedBox(width: 12.w),
            Text(
              "Logout",
              style: TextStyle(
                color: context.appColors.primaryTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


