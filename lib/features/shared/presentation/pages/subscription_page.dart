// ignore_for_file: unused_local_variable

import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/core/models/subscription_plan.dart';
import 'package:nsapp/core/core.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isValid = false;
  List<SubscriptionPlan> _allPlans = [];
  String selectedInterval = 'month'; // 'month' or 'year'

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetProfileEvent());
    context.read<SubscriptionBloc>().add(CheckUserSubscriptionEvent());
    context.read<SubscriptionBloc>().add(GetSubscriptionPlansEvent());

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

    return Scaffold(
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SuccessDeleteUserSubscriptionState) {
            context.read<SubscriptionBloc>().add(CheckUserSubscriptionEvent());
            customAlert(context, AlertType.success, "Subscription Canceled");
          }
          if (state is SubscriptionFailure) {
            customAlert(context, AlertType.error, state.message ?? "Error");
          }
          if (state is ValidUserSubscriptionState) {
            setState(() {
              _isValid = state.isValid;
            });
            if (!state.isValid) {
              context.read<SubscriptionBloc>().add(GetSubscriptionPlansEvent());
            }
          }
          if (state is SuccessGetSubscriptionPlansState) {
            setState(() {
              _allPlans = state.plans;
            });
          }
          if (state is SubscriptionFailure) {
            setState(() {
              _allPlans = [];
            });
          }
          if (state is SuccessMakeSubscriptionState) {
            context.read<SubscriptionBloc>().add(CheckUserSubscriptionEvent());
            context.read<ProfileBloc>().add(GetProfileEvent());
            _subscriptionMade(context);
          }
        },
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = context.appColors.primaryTextColor;
          final secondaryTextColor = context.appColors.secondaryTextColor;
          final buttonColor = context.appColors.primaryColor.withAlpha(30);
          final borderColor = context.appColors.glassBorder;

          return LoadingView(
            isLoading: (state is SubscriptionLoading),
            child: GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 800.w),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<ProfileBloc>().add(
                          GetProfileStreamEvent(),
                        );
                        context.read<ProfileBloc>().add(GetProfileEvent());
                        context.read<SubscriptionBloc>().add(
                          GetSubscriptionPlansEvent(),
                        );
                        context.read<SubscriptionBloc>().add(
                          CheckUserSubscriptionEvent(),
                        );
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 32.w : 20.w,
                          vertical: 24.h,
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Back Button
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Container(
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: context.appColors.cardBackground,
                                      borderRadius: BorderRadius.circular(14.r),
                                      border: Border.all(color: borderColor),
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.chevronLeft,
                                      color: textColor,
                                      size: 20.r,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 24.h),

                              // _isValid
                              //     ? _buildActiveSubscription(
                              //         context,
                              //         isDark,
                              //         textColor,
                              //         secondaryTextColor,
                              //       )
                              // :
                              _buildSubscriptionPlans(
                                context,
                                isLargeScreen,
                                isDark,
                                textColor,
                                secondaryTextColor,
                                buttonColor,
                                borderColor,
                                state,
                              ),
                            ],
                          ),
                        ),
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

  Widget _buildActiveSubscription(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Column(
      children: [
        // SizedBox(height: 60.h),

        // Container(
        //   width: 120.w,
        //   height: 120.h,
        //   decoration: BoxDecoration(
        //     color: context.appColors.primaryColor,
        //     shape: BoxShape.circle,
        //   ),
        //   child: Center(
        //     child: FaIcon(
        //       FontAwesomeIcons.check,
        //       color: Colors.white,
        //       size: 60.r,
        //     ),
        //   ),
        // ),
        // SizedBox(height: 40.h),
        // Text(
        //   "YOU'RE SUBSCRIBED!",
        //   style: TextStyle(
        //     fontSize: 24.sp,
        //     fontWeight: FontWeight.w500,
        //     color: textColor,
        //     letterSpacing: 1.2,
        //   ),
        // ),
        // SizedBox(height: 12.h),
        // Text(
        //   "Enjoy unlimited access to your premium benefits",
        //   style: TextStyle(
        //     fontSize: 14.sp,
        //     color: context.appColors.secondaryTextColor,
        //     letterSpacing: 0.3,
        //   ),
        //   textAlign: TextAlign.center,
        // ),
        // SizedBox(height: 60.h),
        SolidContainer(
          padding: EdgeInsets.all(32.r),
          child: Column(
            children: [
              // FaIcon(
              //   FontAwesomeIcons.sliders,
              //   size: 40.r,
              //   color: context.appColors.primaryColor,
              // ),
              // SizedBox(height: 20.h),
              // Text(
              //   "MANAGE SUBSCRIPTION",
              //   style: TextStyle(
              //     fontSize: 18.sp,
              //     fontWeight: FontWeight.w500,
              //     color: textColor,
              //     letterSpacing: 0.5,
              //   ),
              // ),
              SizedBox(height: 8.h),
              Text(
                "Cancel anytime with no hidden fees",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: context.appColors.secondaryTextColor,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: OutlinedButton(
                  onPressed: () {
                    _cancelSubscription(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.appColors.errorColor,
                    side: BorderSide(color: context.appColors.errorColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: const Text(
                    "CANCEL SUBSCRIPTION",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionPlans(
    BuildContext context,
    bool isLargeScreen,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color buttonColor,
    Color borderColor,
    SubscriptionState state,
  ) {
    if (_allPlans.isNotEmpty) {
      final plans =
          _allPlans.where((plan) => plan.interval == selectedInterval).toList()
            ..sort(
              (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
            );

      return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          return Column(
            children: [
              FaIcon(
                _isValid ? FontAwesomeIcons.check : FontAwesomeIcons.crown,
                size: 60.r,
                color: secondaryTextColor.withAlpha(220),
              ),
              SizedBox(height: 16.h),
              Text(
                _isValid ? "SUBSCRIPTION IS ACTIVE" : "CHOOSE YOUR PLAN",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                _isValid
                    ? "You currently on the ${profileState.profile?.subscriptionInterval ?? ''} subscription"
                    : "Unlock premium features and grow your business",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: secondaryTextColor,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),

              _buildIntervalToggle(
                isDark,
                textColor,
                secondaryTextColor,
                buttonColor,
                borderColor,
              ),

              SizedBox(height: 40.h),

              if (plans.isEmpty)
                _buildEmptyPlans(textColor, secondaryTextColor)
              else
                isLargeScreen
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: plans
                            .map(
                              (plan) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                  ),
                                  child: _buildPlanCard(
                                    plan,
                                    context,
                                    plan.tier == 'GOLD',
                                    isDark,
                                    textColor,
                                    secondaryTextColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : Column(
                        children: plans
                            .map(
                              (plan) => Padding(
                                padding: EdgeInsets.only(bottom: 20.h),
                                child: _buildPlanCard(
                                  plan,
                                  context,
                                  plan.tier == 'GOLD',
                                  isDark,
                                  textColor,
                                  secondaryTextColor,
                                ),
                              ),
                            )
                            .toList(),
                      ),
              SizedBox(height: 20.h),
              (_isValid)
                  ? _buildActiveSubscription(
                      context,
                      isDark,
                      textColor,
                      secondaryTextColor,
                    )
                  : SizedBox.shrink(),
            ],
          );
        },
      );
    }

    if (state is SubscriptionFailure) {
      return _buildFailureView(textColor, secondaryTextColor);
    }

    return _buildLoadingView(textColor);
  }

  Widget _buildIntervalToggle(
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
    Color buttonColor,
    Color borderColor,
  ) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            "Monthly",
            'month',
            isDark,
            textColor,
            secondaryTextColor,
          ),
          _buildToggleButton(
            "Yearly (Save 20%)",
            'year',
            isDark,
            textColor,
            secondaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    String interval,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    bool isSelected = selectedInterval == interval;
    return GestureDetector(
      onTap: () => setState(() => selectedInterval = interval),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.primaryColor
              : context.appColors.primaryColor.withAlpha(30),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : secondaryTextColor,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlans(Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        FaIcon(
          FontAwesomeIcons.faceFrown,
          size: 48.r,
          color: secondaryTextColor,
        ),
        SizedBox(height: 16.h),
        Text(
          "No plans found for this interval",
          style: TextStyle(color: textColor, fontSize: 18.sp),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    SubscriptionPlan plan,
    BuildContext context,
    bool isPopular,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final features = plan.features ?? [];

    Color primaryColor;
    List<Color> gradientColors;
    FaIconData tierIcon;

    switch (plan.tier) {
      case 'PLATINUM':
        primaryColor = Color(0xFF673AB7);
        gradientColors = [Color(0xFF673AB7), Color(0xFF9575CD)];
        tierIcon = FontAwesomeIcons.wandMagicSparkles;
        break;
      case 'GOLD':
        primaryColor = Color(0xFFFFB300);
        gradientColors = [Color(0xFFFFB300), Color(0xFFFFD54F)];
        tierIcon = FontAwesomeIcons.crown;
        break;
      case 'SILVER':
        primaryColor = Color(0xFF78909C);
        gradientColors = [Color(0xFF78909C), Color(0xFFB0BEC5)];
        tierIcon = FontAwesomeIcons.shield;
        break;
      default:
        primaryColor = Color(0xFFFF6B35);
        gradientColors = [Color(0xFFFF6B35), Color(0xFFFF8E53)];
        tierIcon = FontAwesomeIcons.star;
    }

    // String commissionText = "20% platform fee";
    // String priorityText = "Standard visibility";

    // if (plan.tier == 'SILVER') {
    //   commissionText = "15% platform fee";
    //   priorityText = "1.1x visibility boost";
    // } else if (plan.tier == 'GOLD') {
    //   commissionText = "10% platform fee";
    //   priorityText = "1.2x visibility boost";
    // } else if (plan.tier == 'PLATINUM') {
    //   commissionText = "5% platform fee";
    //   priorityText = "1.5x matching boost";
    // }

    final maxServices = plan.maxCatalogServices ?? 1;
    final limitText = maxServices == 0
        ? "Unlimited catalog services"
        : "$maxServices catalog service${maxServices > 1 ? 's' : ''}";

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, profileState) {
        setState(() {});
      },
      builder: (context, profileState) {
        return GestureDetector(
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: _isValid
                    ? (profileState.profile!.maxCatalogServices! ==
                                  plan.maxCatalogServices! &&
                              profileState.profile!.subscriptionInterval! ==
                                  plan.interval!)
                          ? context.appColors.primaryColor
                          : context.appColors.glassBorder
                    : context.appColors.glassBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: context.appColors.primaryColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    tierIcon,
                    color: context.appColors.primaryColor,
                    size: 32.r,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  (plan.name ?? "Plan").toUpperCase(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "\$${plan.price?.toStringAsFixed(2) ?? '0.00'}",
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    Text(
                      "/${plan.interval == 'year' ? 'YR' : 'MO'}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                _buildBenefitItem(
                  limitText,
                  FontAwesomeIcons.briefcase,
                  false,
                  textColor,
                  secondaryTextColor,
                ),

                Divider(color: context.appColors.glassBorder, height: 32.h),

                ...features.map(
                  (feature) =>
                      _buildFeatureItem(feature, false, secondaryTextColor),
                ),

                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () {
                    if (_isValid) {
                      if (profileState.profile!.maxCatalogServices! !=
                          plan.maxCatalogServices!) {
                        _downgradeSubscription(
                          context,
                          "",
                          plan,
                          profileState.profile!,
                        );
                      }
                    } else {
                      if (profileState.profile!.catalogServiceNames!.length >
                          plan.maxCatalogServices!) {
                        customAlert(
                          context,
                          AlertType.warning,
                          "Your profile service catalog number exceeds the maximum number of service for the selected plan",
                        );
                      } else {
                        context.read<SubscriptionBloc>().add(
                          MakeSubscriptionEvent(
                            planId: plan.id!,
                            context: context,
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: context.appColors.primaryColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: context.appColors.glassBorder),
                    ),
                    child: Center(
                      child: Text(
                        _isValid
                            ? profileState.profile!.maxCatalogServices! <
                                      plan.maxCatalogServices!
                                  ? "UPGRADE TO ${plan.tier?.toUpperCase() ?? 'PLAN'}"
                                  : profileState.profile!.maxCatalogServices! >
                                        plan.maxCatalogServices!
                                  ? "DOWNGRADE TO ${plan.tier?.toUpperCase() ?? 'PLAN'}"
                                  : (profileState
                                            .profile!
                                            .subscriptionInterval! !=
                                        plan.interval!)
                                  ? "USE THIS RECURING INTERVAL"
                                  : "YOUR CURRENT PLAN"
                            : "CHOOSE ${plan.tier?.toUpperCase() ?? 'PLAN'}",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.primaryColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBenefitItem(
    String text,
    FaIconData icon,
    bool isHighlighted,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          FaIcon(icon, size: 16.r, color: secondaryTextColor),
          SizedBox(width: 8.w),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    String text,
    bool isHighlighted,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.circleCheck,
            size: 16.r,
            color: isHighlighted ? Colors.white70 : secondaryTextColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 11.sp,
                color: secondaryTextColor,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureView(Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        FaIcon(
          FontAwesomeIcons.circleExclamation,
          size: 60.r,
          color: secondaryTextColor,
        ),
        SizedBox(height: 16.h),
        Text(
          "Failed to Load Plans",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Please check your connection and try again",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16.sp, color: secondaryTextColor),
        ),
        SizedBox(height: 24.h),
        ElevatedButton(
          onPressed: () {
            context.read<SubscriptionBloc>().add(GetSubscriptionPlansEvent());
          },
          child: const Text("Retry"),
        ),
      ],
    );
  }

  Widget _buildLoadingView(Color textColor) {
    return Column(
      children: [
        SizedBox(height: 40.h),
        CircularProgressIndicator(color: textColor),
        SizedBox(height: 20.h),
        Text("Fetching great deals...", style: TextStyle(color: textColor)),
      ],
    );
  }
}

void _downgradeSubscription(
  BuildContext context,
  String val,
  SubscriptionPlan plan,
  Profile profile,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: context.appColors.cardBackground,
        child: Container(
          padding: EdgeInsets.all(28.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: context.appColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  FontAwesomeIcons.triangleExclamation,
                  color: Colors.orangeAccent,
                  size: 40.r,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                (profile.maxCatalogServices! < plan.maxCatalogServices!)
                    ? "Upgrade Your Subscription"
                    : "Downgrade Your Subscription?",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.primaryTextColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                (profile.maxCatalogServices! < plan.maxCatalogServices!)
                    ? "This will void your previous subscription without refund. Are you sure you want to proceed?"
                    : "You can download once your subscription cycle ends",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.appColors.secondaryTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          side: BorderSide(
                            color: context.appColors.glassBorder,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: context.appColors.primaryTextColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  (profile.maxCatalogServices! < plan.maxCatalogServices!)
                      ? Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              context.read<SubscriptionBloc>().add(
                                MakeSubscriptionEvent(
                                  planId: plan.id!,
                                  context: context,
                                ),
                              );
                            },
                            child: Text(
                              "Proceed",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _subscriptionMade(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: context.appColors.cardBackground,
        child: Container(
          padding: EdgeInsets.all(28.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: context.appColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  FontAwesomeIcons.check,
                  color: Colors.green,
                  size: 40.r,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Subscription successful",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.primaryTextColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                "You can select services. Will you like to update your profile now?",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.appColors.secondaryTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          side: BorderSide(
                            color: context.appColors.glassBorder,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        "Later",
                        style: TextStyle(
                          color: context.appColors.primaryTextColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.push("/edit-profile");
                      },
                      child: Text(
                        "Yes, Proceed",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _cancelSubscription(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        backgroundColor: context.appColors.cardBackground,
        child: Container(
          padding: EdgeInsets.all(28.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: context.appColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  FontAwesomeIcons.triangleExclamation,
                  color: Colors.orangeAccent,
                  size: 40.r,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                "Cancel Subscription",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: context.appColors.primaryTextColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                "Cancelling your subscription will let you loss access to premium benefits. Do you want to proceed?",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.appColors.secondaryTextColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          side: BorderSide(
                            color: context.appColors.glassBorder,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        "Later",
                        style: TextStyle(
                          color: context.appColors.primaryTextColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<SubscriptionBloc>().add(
                          DeleteUserSubscriptionEvent(),
                        );
                      },
                      child: Text(
                        "Yes, Proceed",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
