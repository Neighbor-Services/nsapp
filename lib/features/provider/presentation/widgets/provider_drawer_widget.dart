import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/constants/dimension.dart';
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
import '../../../../core/constants/string_constants.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';
import '../bloc/provider_bloc.dart';
import '../pages/provider_appointment_list_page.dart';
import '../pages/provider_home_page.dart';

class ProviderDrawerWidget extends StatelessWidget {
  const ProviderDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(120)
        : const Color(0xFF1E1E2E).withAlpha(120);

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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withAlpha(10),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [appBlueCardColor, Color(0xFF4A90E2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: appBlueCardColor.withAlpha(50),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: isDark ? appBlueCardColor : Colors.black12,
                  backgroundImage:
                      (profile.profilePictureUrl != null &&
                          profile.profilePictureUrl!.isNotEmpty &&
                          !profile.profilePictureUrl!.startsWith("file:///"))
                      ? NetworkImage(profile.profilePictureUrl!)
                      : const AssetImage(logo2Assets) as ImageProvider,
                ),
              ),
              const Spacer(),
              _buildIconButton(Icons.edit_note_rounded, () {
                Navigator.pop(context);
                Get.toNamed("/edit-profile");
              }, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.firstName ?? "Provider",
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: appBlueCardColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: appBlueCardColor.withAlpha(50)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.engineering_rounded,
                  size: 12,
                  color: Color(0xFF4A90E2),
                ),
                SizedBox(width: 4),
                Text(
                  "PROVIDER",
                  style: TextStyle(
                    color: Color(0xFF4A90E2),
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected
                  ? (isDark
                        ? Colors.white.withAlpha(15)
                        : Colors.black.withAlpha(10))
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : Colors.black.withAlpha(10),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF4A90E2)
                      : (isDark ? Colors.white70 : Colors.black54),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? textColor
                        : (isDark ? Colors.white70 : Colors.black54),
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

  Widget _buildIconButton(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withAlpha(15)
              : Colors.black.withAlpha(5),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(20)
                : Colors.black.withAlpha(10),
          ),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : const Color(0xFF1E1E2E),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark, Color textColor) {
    final subTextColor = isDark ? Colors.white.withAlpha(200) : Colors.black54;
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);
    final shadowColor = isDark
        ? Colors.black.withAlpha(40)
        : Colors.grey.withAlpha(30);

    final dialogBg = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    return GestureDetector(
      onTap: () {
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
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.black.withAlpha(10),
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            const SizedBox(width: 12),
            Text(
              "Logout",
              style: TextStyle(
                color: Colors.redAccent.withAlpha(isDark ? 200 : 180),
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
