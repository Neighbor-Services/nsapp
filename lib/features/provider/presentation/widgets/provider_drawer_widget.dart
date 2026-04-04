import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/profile/presentation/pages/about_page.dart';
import 'package:nsapp/features/profile/presentation/pages/add_about_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_accepted_request_page.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_home_page.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/pages/report_page.dart';
import 'package:nsapp/features/shared/presentation/pages/settings_page.dart';
import 'package:nsapp/features/shared/presentation/pages/subscription_page.dart';
import 'package:nsapp/features/shared/presentation/pages/disputes_list_page.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../bloc/provider_bloc.dart';
import '../pages/provider_appointment_list_page.dart';
import '../pages/provider_home_page.dart';
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
              _buildHeader(context, isDark, textColor, secondaryTextColor),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.home_rounded,
                      title: "Home",
                      onTap: () {
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(
                            page: 1,
                            widget: ProviderHomePage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isSelected: NavigatorProviderState.page == 1,
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.check_circle_outline_rounded,
                      title: "My Jobs",
                      onTap: () {
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(
                            page: NavigatorProviderState.page,
                            widget: ProviderAcceptedRequestPage(),
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
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(
                            page: NavigatorProviderState.page,
                            widget: const ProviderAppointmentListPage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.subscriptions_rounded,
                      title: "Subscription",
                      onTap: () {
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(
                            page: NavigatorProviderState.page,
                            widget: SubscriptionPage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    if (SuccessGetProfileState.profile.preferredPaymentMode !=
                        'ON_SITE')
                      _buildDrawerItem(
                        context,
                        icon: Icons.account_balance_wallet_rounded,
                        title: "Wallet",
                        onTap: () {
                          context.read<ProviderBloc>().add(
                            NavigateProviderEvent(
                              page: 1,
                              widget: const WalletPage(),
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
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(
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
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Divider(
                        color: context.appColors.glassBorder,
                      ),
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: "Portfolio",
                      onTap: () {
                        context.read<ProfileBloc>().add(
                          AboutUserEvent(
                            userID:
                                SuccessGetProfileState.profile.user?.id ?? "",
                          ),
                        );
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(page: 1, widget: AboutPage()),
                        );
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: "About",
                      onTap: () {
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(
                            page: 1,
                            widget: AddAboutPage(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      isDark: isDark,
                      textColor: textColor,
                    ),
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings_rounded,
                      title: "Settings",
                      onTap: () {
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(
                            page: NavigatorProviderState.page,
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
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(
                            page: NavigatorProviderState.page,
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
              _buildIconButton(context, Icons.edit_note_rounded, () {
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
              fontWeight: FontWeight.bold,
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
                  Icons.engineering_rounded,
                  size: 12.r,
                  color: context.appColors.primaryColor,
                ),
                SizedBox(width: 4.w),
                Text(
                  "PROVIDER",
                  style: TextStyle(
                    color: context.appColors.primaryColor,
                    fontSize: 10.sp,
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
                  width: size(context).width * 0.85,
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
                          Icons.logout_rounded,
                          size: 32.r,
                          color: context.appColors.errorColor,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
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
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
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
            Icon(Icons.logout_rounded, color: context.appColors.errorColor, size: 20.r),
            SizedBox(width: 12.w),
            Text(
              "Logout",
              style: TextStyle(
                color: context.appColors.primaryTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
