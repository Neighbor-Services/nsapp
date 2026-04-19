import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_home_page.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_home_page.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/change_user_type_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/connect_account_setup_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:nsapp/core/core.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  final LocalAuthentication localAuthentication = LocalAuthentication();
  GlobalKey<ScaffoldState> scaffold = GlobalKey<ScaffoldState>();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final textColor = context.appColors.primaryTextColor;

    return Scaffold(
      key: scaffold,
      body: BlocConsumer<SharedBloc, SharedState>(
        listener: (context, state) {
          if (state is SuccessConnectAccountState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            FlutterWebBrowser.openWebPage(
              url: SuccessConnectAccountState.accountLink!.url,
              customTabsOptions: CustomTabsOptions(
                colorScheme: isDark ? CustomTabsColorScheme.dark : CustomTabsColorScheme.light,
                shareState: CustomTabsShareState.on,
                instantAppsEnabled: true,
                showTitle: true,
                urlBarHidingEnabled: true,
              ),
              safariVCOptions: SafariViewControllerOptions(
                barCollapsingEnabled: true,
                preferredBarTintColor: context.appColors.cardBackground,
                preferredControlTintColor: context.appColors.secondaryColor,
                dismissButtonStyle:
                    SafariViewControllerDismissButtonStyle.close,
                modalPresentationCapturesStatusBarAppearance: true,
              ),
            );
          }
          if (state is SuccessChangeUserTypeState) {
            context.read<ProfileBloc>().add(GetProfileEvent());
            if (Helpers.isSeeker(UserTypeProfileState.userType)) {
              context.read<SharedBloc>().add(
                ToggleDashboardEvent(isProvider: false),
              );
            }
            context.read<SharedBloc>().add(
              SharedBlocReloadEvent(UserTypeProfileState.userType),
            );
            customAlert(context, AlertType.success, "Update Successful");
          }
          if (state is FailureChangeUserTypeState) {
            context.read<SharedBloc>().add(
              SharedBlocReloadEvent(UserTypeProfileState.userType),
            );
            customAlert(context, AlertType.error, "Update Failed");
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is SharedLoadingState),
            child: GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 32.w : 20.w,
                          vertical: 24.h,
                        ),
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (DashboardState.isProvider) {
                                    context.read<ProviderBloc>().add(
                                      ProviderBackPressedEvent(),
                                    );
                                  } else {
                                    context.read<SeekerBloc>().add(
                                      SeekerBackPressedEvent(),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: context.appColors.cardBackground,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: context.appColors.glassBorder,
                                    ),
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.chevronLeft,
                                    color: textColor,
                                    size: 20.r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Text(
                                "SETTINGS",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),
                          _buildSectionHeader("Appearance"),
                          SizedBox(height: 12.h),
                          _buildSettingsCard(context, [
                            _buildSettingsTile(
                              context: context,
                              icon: FontAwesomeIcons.moon,
                              iconColor: Colors.amber,
                              title: "Dark Mode",
                              subtitle: "Toggle between dark and light themes",
                              trailing: Switch.adaptive(
                                value:
                                    ThemeModeState.themeMode == ThemeMode.dark,
                                activeThumbColor: context.appColors.secondaryColor,
                                onChanged: (val) {
                                  context.read<SharedBloc>().add(
                                    ToggleThemeModeEvent(
                                      themeMode: val
                                          ? ThemeMode.dark
                                          : ThemeMode.light,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ]),
                          SizedBox(height: 24.h),
                          _buildSectionHeader("Account"),
                          SizedBox(height: 12.h),
                          _buildSettingsCard(context, [
                            _buildSettingsTile(
                              context: context,
                              icon: FontAwesomeIcons.fingerprint,
                              iconColor: Colors.purple,
                              title: "Use Biometric",
                              subtitle: "Unlock with fingerprint or face",
                              trailing: Switch.adaptive(
                                value: UseBiometricState.usebiometric,
                                activeThumbColor: context.appColors.secondaryColor,
                                onChanged: (val) async {
                                  try {
                                    final bool hasBiometric =
                                        await localAuthentication
                                            .canCheckBiometrics;
                                    if (hasBiometric) {
                                      final isAuthenticated =
                                          await localAuthentication
                                              .authenticate(
                                                localizedReason:
                                                    "Unlock neighbor service",

                                                biometricOnly: true,
                                              );
                                      if (isAuthenticated) {
                                        scaffold.currentContext!
                                            .read<SharedBloc>()
                                            .add(
                                              UseBiometricEvent(
                                                usebiometric: val,
                                              ),
                                            );
                                      }
                                    } else if (!val) {
                                      // Disabling without auth check
                                      const secureStorage =
                                          FlutterSecureStorage();
                                      await secureStorage.delete(key: "email");
                                      await secureStorage.delete(
                                        key: "password",
                                      );
                                      scaffold.currentContext!
                                          .read<SharedBloc>()
                                          .add(
                                            UseBiometricEvent(
                                              usebiometric: val,
                                            ),
                                          );
                                    } else {
                                      customAlert(
                                        context,
                                        AlertType.warning,
                                        "Biometric not available",
                                      );
                                    }
                                  } catch (e) {
                                    customAlert(
                                      context,
                                      AlertType.error,
                                      "Biometric not available",
                                    );
                                  }
                                },
                              ),
                            ),
                            _buildDivider(context),
                            _buildSettingsTile(
                              context: context,
                              icon: FontAwesomeIcons.lock,
                              iconColor: context.appColors.infoColor,
                              title: "Change Password",
                              subtitle: "Update your account password",
                              onTap: () => Get.toNamed("/change-password"),
                            ),
                          ]),
                          SizedBox(height: 24.h),
                          _buildSectionHeader("Payments"),
                          SizedBox(height: 12.h),
                          _buildSettingsCard(context, [
                            _buildSettingsTile(
                              context: context,
                              icon: FontAwesomeIcons.creditCard,
                              iconColor: context.appColors.successColor,
                              title: "Setup Payment",
                              subtitle: "Configure payment methods",
                              onTap: () => Payment.setupStripeCustomer(context),
                            ),
                            if (Helpers.isProvider(
                              SuccessGetProfileState.profile.userType,
                            )) ...[
                              _buildDivider(context),
                              _buildSettingsTile(
                                context: context,
                                icon: FontAwesomeIcons.creditCard,
                                iconColor: context.appColors.warningColor,
                                title: "Preferred Payment Method",
                                subtitle: SuccessGetProfileState.profile
                                            .preferredPaymentMode ==
                                        'IN_APP'
                                    ? "In-App Payments"
                                    : "On-Site Payments",
                                onTap: () => _showPaymentModeSheet(context),
                              ),
                            ],
                            if (Helpers.isProvider(
                              SuccessGetProfileState.profile.userType,
                            ) &&
                                SuccessGetProfileState.profile
                                        .preferredPaymentMode !=
                                    'ON_SITE') ...[
                              _buildDivider(context),
                              _buildSettingsTile(
                                context: context,
                                icon: FontAwesomeIcons.buildingColumns,
                                iconColor: Colors.teal,
                                title: "Payment Account",
                                subtitle: "Manage payout settings",
                                onTap: () {
                                  Get.bottomSheet(
                                    Container(
                                      width: size(context).width,
                                      height: 350.h,
                                      padding: EdgeInsets.all(24.r),
                                      decoration: BoxDecoration(
                                        color: context.appColors.cardBackground,
                                        borderRadius:
                                            BorderRadius.vertical(
                                              top: Radius.circular(25.r),
                                            ),
                                      ),
                                      child: const ConnectAccountSetupWidget(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ]),
                          SizedBox(height: 24.h),
                          _buildSectionHeader("Other"),
                          SizedBox(height: 12.h),
                          _buildSettingsCard(context, [
                            _buildSettingsTile(
                              context: context,
                              icon: FontAwesomeIcons.gavel,
                              iconColor: Colors.deepOrange,
                              title: "Terms of Service",
                              subtitle: "Read our terms and conditions",
                              onTap: () => Get.toNamed('/legal', arguments: 'TERMS'),
                            ),
                            _buildDivider(context),
                            _buildSettingsTile(
                              context: context,
                              icon: FontAwesomeIcons.shieldHalved,
                              iconColor: Colors.teal,
                              title: "Privacy Policy",
                              subtitle: "Learn how we handle your data",
                              onTap: () => Get.toNamed('/legal', arguments: 'PRIVACY'),
                            ),
                          ]),
                          SizedBox(height: 24.h),
                          _buildSectionHeader("Other"),
                          SizedBox(height: 12.h),
                          _buildSettingsCard(context, [
                            _buildSettingsTile(
                              context: context,
                              icon: FontAwesomeIcons.rightLeft,
                              iconColor: Colors.indigo,
                              title: "Change User Type",
                              subtitle: "Switch between seeker and provider",
                              onTap: () {
                                Get.bottomSheet(
                                  Container(
                                    width: size(context).width,
                                    padding: EdgeInsets.all(24.r),
                                    decoration: BoxDecoration(
                                      color: context.appColors.cardBackground,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(25.r),
                                      ),
                                    ),
                                    child: const ChangeUserTypeWidget(),
                                  ),
                                );
                              },
                            ),
                            _buildDivider(context),
                            _buildSettingsTile(
                              context: context,
                              icon: FontAwesomeIcons.rightFromBracket,
                              iconColor: context.appColors.errorColor,
                              title: "Logout",
                              subtitle: "Sign out of your account",
                              onTap: () => _showLogoutDialog(context),
                            ),
                          ]),
                          SizedBox(height: 24.h),
                          _buildSectionHeader("Danger Zone"),
                          SizedBox(height: 12.h),
                          _buildSettingsCard(context, [
                            _buildSettingsTile(
                              context: context,
                              icon: FontAwesomeIcons.trashCan,
                              iconColor: context.appColors.errorColor,
                              title: "Delete Account",
                              subtitle: "Permanently delete your account",
                              onTap: () => _showDeleteAccountDialog(context),
                            ),
                          ]),
                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: context.appColors.secondaryTextColor,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: context.appColors.glassBorder,
        ),
       
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final textColor = context.appColors.primaryTextColor;
    final subtitleColor = context.appColors.secondaryTextColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: context.appColors.primaryColor, size: 22.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.sp, color: subtitleColor),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                FontAwesomeIcons.chevronRight,
                color: textColor.withAlpha(100),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1.h,
      indent: 74.w,
      color: context.appColors.glassBorder,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.appColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            "LOGOUT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.appColors.primaryTextColor,
              letterSpacing: 0.5,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              color: context.appColors.secondaryTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: context.appColors.secondaryTextColor,
                ),
              ),
            ),
            SolidButton(
              onPressed: () {
                context.read<AuthenticationBloc>().add(
                  LogoutAuthenticationEvent(),
                );
                SuccessGetProfileState.profile = Profile();
                NavigatorSeekerState.widget = const SeekerHomePage();
                NavigatorSeekerState.page = 1;
                NavigatorProviderState.widget = const ProviderHomePage();
                NavigatorProviderState.page = 1;
                Get.offAllNamed("/login");
              },
              label: "LOGOUT",
              isPrimary: true,
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.appColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            "DELETE ACCOUNT",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.appColors.errorColor,
              letterSpacing: 0.5,
            ),
          ),
          content: Text(
            "Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.",
            style: TextStyle(
              color: context.appColors.secondaryTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: context.appColors.secondaryTextColor,
                ),
              ),
            ),
            SolidButton(
              onPressed: () {
                context.read<AuthenticationBloc>().add(
                  DeleteAccountEvent(),
                );
                SuccessGetProfileState.profile = Profile();
                NavigatorSeekerState.widget = const SeekerHomePage();
                NavigatorSeekerState.page = 1;
                NavigatorProviderState.widget = const ProviderHomePage();
                NavigatorProviderState.page = 1;
                Get.offAllNamed("/login");
              },
              label: "DELETE",
              isPrimary: true,
              color: context.appColors.errorColor,
            ),
          ],
        );
      },
    );
  }

  void _showPaymentModeSheet(BuildContext context) {
    final profile = SuccessGetProfileState.profile;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(28.r),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "PREFERRED PAYMENT METHOD",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: context.appColors.primaryTextColor,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Choose how you'd like to receive payments from seekers.",
              style: TextStyle(
                fontSize: 14.sp,
                color: context.appColors.secondaryTextColor,
              ),
            ),
            SizedBox(height: 24.h),
            _buildPaymentOption(
              context: context,
              icon: FontAwesomeIcons.wallet,
              title: "In-App Payments",
              description: "Secure payments handled through the app",
              value: "IN_APP",
              currentValue: profile.preferredPaymentMode ?? "ON_SITE",
              onChanged: (val) => _updatePaymentMode(context, val),
            ),
            SizedBox(height: 16.h),
            _buildPaymentOption(
              context: context,
              icon: FontAwesomeIcons.handshake,
              title: "On-Site Payments",
              description: "Direct payments from seekers at the service location",
              value: "ON_SITE",
              currentValue: profile.preferredPaymentMode ?? "ON_SITE",
              onChanged: (val) => _updatePaymentMode(context, val),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required String currentValue,
    required Function(String) onChanged,
  }) {
    final isSelected = value == currentValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.primaryColor.withAlpha(20)
              : context.appColors.glassBorder,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? context.appColors.primaryColor.withAlpha(100)
                : context.appColors.glassBorder,
            width: 1.5.r,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.appColors.primaryColor.withAlpha(40)
                    : context.appColors.surfaceBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? context.appColors.primaryColor : context.appColors.secondaryTextColor,
                size: 24.r,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.primaryTextColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: context.appColors.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              FaIcon(FontAwesomeIcons.circleCheck, color: context.appColors.primaryColor, size: 24.r),
          ],
        ),
      ),
    );
  }

  void _updatePaymentMode(BuildContext context, String mode) {
    if (SuccessGetProfileState.profile.preferredPaymentMode == mode) {
      Get.back();
      return;
    }

    final updatedProfile = SuccessGetProfileState.profile;
    updatedProfile.preferredPaymentMode = mode;

    context.read<ProfileBloc>().add(UpdateProfileEvent(profile: updatedProfile));
    Get.back();
    customAlert(context, AlertType.success, "Payment preference updated");
  }
}



