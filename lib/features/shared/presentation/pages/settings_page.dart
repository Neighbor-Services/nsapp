import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/constants/dimension.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);

    return Scaffold(
      key: scaffold,
      body: BlocConsumer<SharedBloc, SharedState>(
        listener: (context, state) {
          if (state is SuccessConnectAccountState) {
            FlutterWebBrowser.openWebPage(
              url: SuccessConnectAccountState.accountLink!.url,
              customTabsOptions: CustomTabsOptions(
                colorScheme: isDark
                    ? CustomTabsColorScheme.dark
                    : CustomTabsColorScheme.light,
                shareState: CustomTabsShareState.on,
                instantAppsEnabled: true,
                showTitle: true,
                urlBarHidingEnabled: true,
              ),
              safariVCOptions: SafariViewControllerOptions(
                barCollapsingEnabled: true,
                preferredBarTintColor: isDark
                    ? const Color(0xFF1E1E2E)
                    : Colors.white,
                preferredControlTintColor: appOrangeColor1,
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
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 32 : 20,
                          vertical: 24,
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
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withAlpha(20)
                                        : Colors.black.withAlpha(5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withAlpha(40)
                                          : Colors.black.withAlpha(10),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "Settings",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader("Appearance", isDark),
                          const SizedBox(height: 12),
                          _buildSettingsCard(context, [
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.dark_mode_rounded,
                              iconColor: Colors.amber,
                              title: "Dark Mode",
                              subtitle: "Toggle between dark and light themes",
                              trailing: Switch.adaptive(
                                value:
                                    ThemeModeState.themeMode == ThemeMode.dark,
                                activeColor: appOrangeColor1,
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
                          const SizedBox(height: 24),
                          _buildSectionHeader("Account", isDark),
                          const SizedBox(height: 12),
                          _buildSettingsCard(context, [
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.fingerprint_rounded,
                              iconColor: Colors.purple,
                              title: "Use Biometric",
                              subtitle: "Unlock with fingerprint or face",
                              trailing: Switch.adaptive(
                                value: UseBiometricState.usebiometric,
                                activeColor: appOrangeColor1,
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
                                                options:
                                                    const AuthenticationOptions(
                                                      biometricOnly: true,
                                                    ),
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
                              icon: Icons.lock_outline_rounded,
                              iconColor: Colors.blue,
                              title: "Change Password",
                              subtitle: "Update your account password",
                              onTap: () => Get.toNamed("/change-password"),
                            ),
                          ]),
                          const SizedBox(height: 24),
                          _buildSectionHeader("Payments", isDark),
                          const SizedBox(height: 12),
                          _buildSettingsCard(context, [
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.payment_rounded,
                              iconColor: Colors.green,
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
                                icon: Icons.account_balance_outlined,
                                iconColor: Colors.teal,
                                title: "Payment Account",
                                subtitle: "Manage payout settings",
                                onTap: () {
                                  Get.bottomSheet(
                                    Container(
                                      width: size(context).width,
                                      height: 350,
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E1E2E)
                                            : Colors.white,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(25),
                                            ),
                                      ),
                                      child: const ConnectAccountSetupWidget(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ]),
                          const SizedBox(height: 24),
                          _buildSectionHeader("Other", isDark),
                          const SizedBox(height: 12),
                          _buildSettingsCard(context, [
                            _buildSettingsTile(
                              context: context,
                              icon: Icons.swap_horiz_rounded,
                              iconColor: Colors.indigo,
                              title: "Change User Type",
                              subtitle: "Switch between seeker and provider",
                              onTap: () {
                                Get.bottomSheet(
                                  Container(
                                    width: size(context).width,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E1E2E)
                                          : Colors.white,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(25),
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
                              icon: Icons.logout_rounded,
                              iconColor: Colors.red,
                              title: "Logout",
                              subtitle: "Sign out of your account",
                              onTap: () => _showLogoutDialog(context),
                            ),
                          ]),
                          const SizedBox(height: 40),
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

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: isDark
              ? Colors.white.withAlpha(150)
              : const Color(0xFF1E1E2E).withAlpha(150),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2E3E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(30)
              : Colors.black.withAlpha(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final subtitleColor = isDark
        ? Colors.white.withAlpha(150)
        : const Color(0xFF1E1E2E).withAlpha(150);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: textColor.withAlpha(100),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: 74,
      color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(10),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Logout",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            "Are you sure you want to logout?",
            style: TextStyle(
              color: isDark
                  ? Colors.white.withAlpha(180)
                  : Colors.black.withAlpha(180),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withAlpha(150)
                      : Colors.black.withAlpha(150),
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
              label: "Logout",
              isPrimary: true,
            ),
          ],
        );
      },
    );
  }
}
