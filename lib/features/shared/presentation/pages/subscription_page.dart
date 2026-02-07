import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/core/models/subscription_plan.dart';
import 'package:get/get.dart';

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
          final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
          final secondaryTextColor = isDark
              ? Colors.white.withAlpha(180)
              : const Color(0xFF1E1E2E).withAlpha(180);
          final buttonColor = isDark
              ? Colors.white.withAlpha(20)
              : Colors.black.withAlpha(5);
          final borderColor = isDark
              ? Colors.white.withAlpha(40)
              : Colors.black.withAlpha(10);

          return LoadingView(
            isLoading: (state is SharedLoadingState),
            child: GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 32 : 20,
                        vertical: 24,
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
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: buttonColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: textColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

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
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[400]!, Colors.green[600]!],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withAlpha(100),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 32),
        Text(
          "You're Subscribed!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Enjoy unlimited access to your premium benefits",
          style: TextStyle(fontSize: 16, color: secondaryTextColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        SolidContainer(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Icon(Icons.settings_rounded, size: 40, color: secondaryTextColor),
              const SizedBox(height: 16),
              Text(
                "Manage Subscription",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Cancel anytime with no hidden fees",
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<SharedBloc>().add(
                      DeleteUserSubscriptionEvent(),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[300],
                    side: BorderSide(color: Colors.red[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Cancel Subscription",
                    style: TextStyle(fontWeight: FontWeight.w600),
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
                Icons.workspace_premium_rounded,
                size: 60,
                color: secondaryTextColor.withAlpha(220),
              ),
              const SizedBox(height: 16),
              Text(
                "Choose Your Plan",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Unlock premium features and grow your business",
                style: TextStyle(fontSize: 16, color: secondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              _buildIntervalToggle(
                isDark,
                textColor,
                secondaryTextColor,
                buttonColor,
                borderColor,
              ),

              const SizedBox(height: 40),

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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
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
                                padding: const EdgeInsets.only(bottom: 20),
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
              const SizedBox(height: 40),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(16),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white : const Color(0xFF1E1E2E))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? Colors.black : Colors.white)
                : secondaryTextColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlans(Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        Icon(
          Icons.sentiment_dissatisfied_rounded,
          size: 48,
          color: secondaryTextColor,
        ),
        const SizedBox(height: 16),
        Text(
          "No plans found for this interval",
          style: TextStyle(color: textColor, fontSize: 18),
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
        primaryColor = const Color(0xFF673AB7);
        gradientColors = [const Color(0xFF673AB7), const Color(0xFF9575CD)];
        tierIcon = Icons.auto_awesome_rounded;
        break;
      case 'GOLD':
        primaryColor = const Color(0xFFFFB300);
        gradientColors = [const Color(0xFFFFB300), const Color(0xFFFFD54F)];
        tierIcon = Icons.workspace_premium_rounded;
        break;
      case 'SILVER':
        primaryColor = const Color(0xFF78909C);
        gradientColors = [const Color(0xFF78909C), const Color(0xFFB0BEC5)];
        tierIcon = Icons.shield_rounded;
        break;
      default:
        primaryColor = const Color(0xFFFF6B35);
        gradientColors = [const Color(0xFFFF6B35), const Color(0xFFFF8E53)];
        tierIcon = Icons.star_rounded;
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPopular
                ? gradientColors
                : [
                    isDark
                        ? Colors.white.withAlpha(20)
                        : Colors.black.withAlpha(5),
                    isDark
                        ? Colors.white.withAlpha(10)
                        : Colors.black.withAlpha(0),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: isPopular
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(40)
                      : Colors.black.withAlpha(10),
                ),
          boxShadow: isPopular
              ? [
                  BoxShadow(
                    color: primaryColor.withAlpha(80),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  tierIcon,
                  color: isPopular ? Colors.white : primaryColor,
                  size: 28,
                ),
                if (isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "BEST VALUE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              plan.name ?? "Plan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isPopular ? Colors.white : textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "\$${plan.price?.toInt() ?? 0}",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: isPopular ? Colors.white : textColor,
                  ),
                ),
                Text(
                  "/${plan.interval == 'year' ? 'year' : 'mo'}",
                  style: TextStyle(
                    fontSize: 14,
                    color: isPopular
                        ? Colors.white.withAlpha(180)
                        : secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildBenefitItem(
              commissionText,
              Icons.account_balance_wallet_rounded,
              isPopular,
              isPopular ? Colors.white : textColor,
              isPopular ? Colors.white.withAlpha(220) : secondaryTextColor,
            ),
            _buildBenefitItem(
              priorityText,
              Icons.trending_up_rounded,
              isPopular,
              isPopular ? Colors.white : textColor,
              isPopular ? Colors.white.withAlpha(220) : secondaryTextColor,
            ),

            Divider(
              color: isPopular
                  ? Colors.white24
                  : (isDark ? Colors.white24 : Colors.black12),
              height: 32,
            ),

            ...features.map(
              (feature) => _buildFeatureItem(
                feature,
                isPopular,
                isPopular ? Colors.white.withAlpha(220) : secondaryTextColor,
              ),
            ),

            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: isPopular
                    ? Colors.white
                    : (isDark
                          ? Colors.white.withAlpha(30)
                          : Colors.black.withAlpha(5)),
                borderRadius: BorderRadius.circular(14),
                border: isPopular
                    ? null
                    : Border.all(
                        color: isDark ? Colors.white38 : Colors.black12,
                      ),
              ),
              child: Center(
                child: Text(
                  "Choose ${plan.tier?.capitalizeFirst ?? 'Plan'}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPopular
                        ? primaryColor
                        : (isDark ? Colors.white : const Color(0xFF1E1E2E)),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isHighlighted ? Colors.white : textColor.withAlpha(180),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isHighlighted ? Colors.white : textColor,
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: isHighlighted
                ? Colors.white70
                : secondaryTextColor.withAlpha(120),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: secondaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureView(Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        Icon(Icons.error_outline_rounded, size: 60, color: secondaryTextColor),
        const SizedBox(height: 16),
        Text(
          "Failed to Load Plans",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please check your connection and try again",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: secondaryTextColor),
        ),
        const SizedBox(height: 24),
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
        const SizedBox(height: 40),
        CircularProgressIndicator(color: textColor),
        const SizedBox(height: 20),
        Text("Fetching great deals...", style: TextStyle(color: textColor)),
      ],
    );
  }
}
