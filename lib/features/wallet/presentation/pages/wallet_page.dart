import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SharedBloc>().add(GetMyWalletEvent());
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "MY WALLET",
          style: TextStyle(
            color: context.appColors.primaryTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (Helpers.isProvider(SuccessGetProfileState.profile.userType)) {
              context.read<ProviderBloc>().add(ProviderBackPressedEvent());
            } else {
              context.read<SeekerBloc>().add(SeekerBackPressedEvent());
            }
          },
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.appColors.iconContainerBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.appColors.glassBorder,
              ),
              boxShadow: Theme.of(context).brightness == Brightness.dark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.appColors.primaryTextColor,
              size: 16,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<SharedBloc>().add(GetMyWalletEvent()),
            icon: Icon(Icons.refresh_rounded, color: context.appColors.primaryTextColor),
          ),
        ],
      ),
      body: BlocBuilder<SharedBloc, SharedState>(
        builder: (context, state) {
          return LoadingView(
            isLoading: state is SharedLoadingState,
            child: GradientBackground(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: context.appColors.cardBackground,
                            gradient: context.appColors.primaryGradient,
                            border: Border.all(
                              color: context.appColors.glassBorder,
                            ),
                          ),
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              CustomTextWidget(
                                text: "TOTAL BALANCE",
                                color: context.appColors.secondaryTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                              const SizedBox(height: 12),
                              Builder(
                                builder: (context) {
                                  final wallet = SuccessGetMyWalletState.wallet;
                                  final balance = wallet?.balance ?? 0;
                                  return Text(
                                    "${wallet?.currency ?? "\$"} ${balance.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: context.appColors.primaryColor,
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                    child: SolidButton(
                                      label: "Withdraw",
                                      onPressed: () =>
                                          _showPayoutDialog(context),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: SolidButton(
                                      label: "Stripe",
                                      textColor: context.appColors.primaryColor,
                                      color: Colors.white,
                                      onPressed: () =>
                                          _openStripeDashboard(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            color: context.appColors.secondaryTextColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          CustomTextWidget(
                            text: "RECENT TRANSACTIONS",
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: context.appColors.primaryTextColor,
                            letterSpacing: 1.1,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final transactions =
                                SuccessGetMyWalletState.wallet?.transactions ??
                                [];
                            if (transactions.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_rounded,
                                      size: 64,
                                      color: context.appColors.secondaryTextColor.withAlpha(30),
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextWidget(
                                      text: "NO TRANSACTIONS YET",
                                      color: context.appColors.secondaryTextColor.withAlpha(100),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: transactions.length,
                              padding: EdgeInsets.only(bottom: 20),
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                final isPayout = tx.transactionType == "PAYOUT";
                                final isCredit = tx.transactionType == "CREDIT";
                                final statusColor =
                                    tx.status?.toLowerCase() == "paid" ||
                                        tx.status?.toLowerCase() == "succeeded"
                                    ? context.appColors.successColor
                                    : (tx.status?.toLowerCase() == "pending"
                                          ? context.appColors.warningColor
                                          : context.appColors.errorColor);

                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  child: SolidContainer(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color:
                                                (isCredit
                                                        ? context.appColors.successColor
                                                        : (isPayout
                                                              ? context.appColors.warningColor
                                                              : context.appColors.errorColor))
                                                    .withAlpha(30),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Icon(
                                            isCredit
                                                ? Icons.call_received_rounded
                                                : Icons.call_made_rounded,
                                            color: isCredit
                                                ? context.appColors.successColor
                                                : (isPayout
                                                      ? context.appColors.warningColor
                                                      : context.appColors.errorColor),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomTextWidget(
                                                text:
                                                    (tx.description ?? "Transaction").toUpperCase(),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 14,
                                                color: context.appColors.primaryTextColor,
                                              ),
                                              const SizedBox(height: 4),
                                              CustomTextWidget(
                                                text: tx.createdAt != null
                                                    ? DateFormat(
                                                        "MMM dd, yyyy • h:mm a",
                                                      ).format(tx.createdAt!)
                                                    : "Date Unknown",
                                                fontSize: 12,
                                                color: context.appColors.secondaryTextColor,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "${isCredit ? '+' : '-'}\$${tx.amount?.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                color: isCredit
                                                    ? context.appColors.successColor
                                                    : (isPayout
                                                          ? context.appColors.warningColor
                                                          : context.appColors.errorColor),
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: statusColor.withAlpha(
                                                  20,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: CustomTextWidget(
                                                text:
                                                    tx.status?.toUpperCase() ??
                                                    "PENDING",
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: statusColor,
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
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPayoutDialog(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: context.appColors.glassBorder,
          ),
        ),
        title: Text(
          "WITHDRAW FUNDS",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter the amount you wish to transfer to your bank account.",
              style: TextStyle(
                color: context.appColors.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SolidTextField(
              controller: amountController,
              hintText: "Amount (e.g. 50.00)",
              prefixIcon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "CANCEL",
              style: TextStyle(
                color: context.appColors.secondaryTextColor.withAlpha(150),
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
          SolidButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                context.read<SharedBloc>().add(
                  RequestPayoutEvent(amount: amount),
                );
                Navigator.pop(context);
              }
            },
            label: "Confirm",
          ),
        ],
      ),
    );
  }

  void _openStripeDashboard(BuildContext context) async {
    context.read<SharedBloc>().add(GetStripeDashboardLinkEvent());
    final subscription = context.read<SharedBloc>().stream.listen((
      state,
    ) async {
      if (state is SuccessGetStripeDashboardLinkState) {
        final url = SuccessGetStripeDashboardLinkState.dashboardUrl;
        if (url != null && context.mounted) {
          try {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${e.toString()}'),
                  backgroundColor: context.appColors.errorColor,
                ),
              );
            }
          }
        }
      } else if (state is FailureGetStripeDashboardLinkState) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (dialogContext) {
              final textColor = context.appColors.primaryTextColor;
              return AlertDialog(
                backgroundColor: context.appColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: context.appColors.glassBorder,
                  ),
                ),
                title: Text(
                  "STRIPE CONNECT REQUIRED",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
                content: Text(
                  "You need to set up your Stripe Connect account first. Would you like to start onboarding?",
                  style: TextStyle(
                    color: context.appColors.secondaryTextColor,
                    fontSize: 14,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: context.appColors.secondaryTextColor.withAlpha(150),
                      ),
                    ),
                  ),
                  SolidButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<SharedBloc>().add(
                        CreateConnectAccountEvent(),
                      );
                    },
                    label: "Start Onboarding",
                  ),
                ],
              );
            },
          );
        }
      } else if (state is SuccessConnectAccountState) {
        final accountLink = SuccessConnectAccountState.accountLink;
        if (accountLink != null && context.mounted) {
          launchUrl(
            Uri.parse(accountLink.url),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    });
    Future.delayed(const Duration(seconds: 5), () => subscription.cancel());
  }
}
