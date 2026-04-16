// ignore_for_file: unused_local_variable

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
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
  bool isLoading = false;
  String selectedInterval = 'month'; // 'month' or 'year'

  @override
  void initState() {
    super.initState();
    context.read<SharedBloc>().add(CheckUserSubscriptionEvent());
    context.read<SharedBloc>().add(GetSubscriptionPlansEvent());

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
      body: BlocConsumer<SharedBloc, SharedState>(
        listener: (context, state) {
          if (state is SuccessDeleteUserSubscriptionState) {
            context.read<SharedBloc>().add(CheckUserSubscriptionEvent());
            customAlert(context, AlertType.success, "Subscription Canceled");
          }
          if (state is FailureDeleteUserSubscriptionState) {
            customAlert(
              context,
              AlertType.error,
              "Unable to cancel subscription",
            );
          }
          if (state is ValidUserSubscriptionState) {
            setState(() {
              isLoading = false;
            });
            if (!ValidUserSubscriptionState.isValid) {
              context.read<SharedBloc>().add(GetSubscriptionPlansEvent());
            }
          }
          if (state is SuccessMakeSubscriptionState) {
            context.read<SharedBloc>().add(CheckUserSubscriptionEvent());
            customAlert(context, AlertType.success, "Subscription Made");
          }
          if (state is FailureMakeSubscriptionState) {
            customAlert(
              context,
              AlertType.error,
              "Unable to make subscription",
            );
          }
        },
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = context.appColors.primaryTextColor;
          final secondaryTextColor = context.appColors.secondaryTextColor;
          final buttonColor = context.appColors.primaryColor.withAlpha(30);
          final borderColor = context.appColors.glassBorder;

          return LoadingView(
            isLoading: (state is SharedLoadingState),
            child: GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 800.w),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
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
                                onTap: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    context.read<ProviderBloc>().add(
                                      ProviderBackPressedEvent(),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: context.appColors.cardBackground,
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.chevronLeft,
                                    color: textColor,
                                    size: 20.r,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),

                            ValidUserSubscriptionState.isValid
                                ? _buildActiveSubscription(
                                    context,
                                    isDark,
                                    textColor,
                                    secondaryTextColor,
                                  )
                                : _buildSubscriptionPlans(
                                    context,
                                    isLargeScreen,
                                    isDark,
                                    textColor,
                                    secondaryTextColor,
                                    buttonColor,
                                    borderColor,
                                  ),
                          ],
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
        SizedBox(height: 60.h),
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            color: context.appColors.primaryColor,
            shape: BoxShape.circle,
           
          ),
          child: FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 60.r),
        ),
        SizedBox(height: 40.h),
        Text(
          "YOU'RE SUBSCRIBED!",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          "Enjoy unlimited access to your premium benefits",
          style: TextStyle(
            fontSize: 14.sp, 
            color: context.appColors.secondaryTextColor,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 60.h),

        SolidContainer(
          padding: EdgeInsets.all(32.r),
          child: Column(
            children: [
              Icon(
                FontAwesomeIcons.sliders, 
                size: 40.r, 
                color: context.appColors.primaryColor,
              ),
              SizedBox(height: 20.h),
              Text(
                "MANAGE SUBSCRIPTION",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 0.5,
                ),
              ),
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
                    context.read<SharedBloc>().add(
                      DeleteUserSubscriptionEvent(),
                    );
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
                      fontWeight: FontWeight.w900,
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
  ) {
    return BlocBuilder<SharedBloc, SharedState>(
      builder: (context, state) {
        if (state is SuccessGetSubscriptionPlansState ||
            SuccessGetSubscriptionPlansState.plans.isNotEmpty) {
          final allPlans = List<SubscriptionPlan>.from(
            SuccessGetSubscriptionPlansState.plans,
          );

          final plans =
              allPlans
                  .where((plan) => plan.interval == selectedInterval)
                  .toList()
                ..sort(
                  (a, b) =>
                      (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
                );

          return Column(
            children: [
              Icon(
                FontAwesomeIcons.crown,
                size: 60.r,
                color: secondaryTextColor.withAlpha(220),
              ),
              SizedBox(height: 16.h),
              Text(
                "CHOOSE YOUR PLAN",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Unlock premium features and grow your business",
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
              SizedBox(height: 40.h),
            ],
          );
        }

        if (state is FailureGetSubscriptionPlansState) {
          return _buildFailureView(textColor, secondaryTextColor);
        }

        return _buildLoadingView(textColor);
      },
    );
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
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlans(Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        Icon(
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
    IconData tierIcon;

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

    String commissionText = "20% platform fee";
    String priorityText = "Standard visibility";

    if (plan.tier == 'SILVER') {
      commissionText = "15% platform fee";
      priorityText = "1.1x visibility boost";
    } else if (plan.tier == 'GOLD') {
      commissionText = "10% platform fee";
      priorityText = "1.2x visibility boost";
    } else if (plan.tier == 'PLATINUM') {
      commissionText = "5% platform fee";
      priorityText = "1.5x matching boost";
    }

    return GestureDetector(
      onTap: () async {
        if (plan.id != null) {
          context.read<SharedBloc>().add(
            MakeSubscriptionEvent(planId: plan.id!, context: context),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: context.appColors.glassBorder,
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
              child: Icon(
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
                fontWeight: FontWeight.w900,
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
                  "\$${plan.price?.toInt() ?? 0}",
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                Text(
                  "/${plan.interval == 'year' ? 'YR' : 'MO'}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            _buildBenefitItem(
              commissionText,
              FontAwesomeIcons.wallet,
              false,
              textColor,
              secondaryTextColor,
            ),
            _buildBenefitItem(
              priorityText,
              FontAwesomeIcons.arrowTrendUp,
              false,
              textColor,
              secondaryTextColor,
            ),

            Divider(
              color: context.appColors.glassBorder,
              height: 32.h,
            ),

            ...features.map(
              (feature) => _buildFeatureItem(
                feature,
                false,
                secondaryTextColor,
              ),
            ),

            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              height: 54.h,
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(30),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: context.appColors.glassBorder,
                ),
              ),
              child: Center(
                child: Text(
                  "CHOOSE ${plan.tier?.toUpperCase() ?? 'PLAN'}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: context.appColors.primaryColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    String text,
    IconData icon,
    bool isHighlighted,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.r,
            color: secondaryTextColor,
          ),
          SizedBox(width: 8.w),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
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
          Icon(
            FontAwesomeIcons.circleCheck,
            size: 16.r,
            color: isHighlighted
                ? Colors.white70
                : secondaryTextColor,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: 11.sp, 
                color: secondaryTextColor,
                fontWeight: FontWeight.w700,
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
        FaIcon(FontAwesomeIcons.circleExclamation, size: 60.r, color: secondaryTextColor),
        SizedBox(height: 16.h),
        Text(
          "Failed to Load Plans",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
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
            context.read<SharedBloc>().add(GetSubscriptionPlansEvent());
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


