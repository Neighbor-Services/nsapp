import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white70
        : const Color(0xFF64748B);
    final cardBgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "My Wallet",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
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
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(20) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.black.withAlpha(10),
              ),
              boxShadow: isDark
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
              color: textColor,
              size: 16,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<SharedBloc>().add(GetMyWalletEvent()),
            icon: Icon(Icons.refresh_rounded, color: textColor),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            borderRadius: BorderRadius.circular(30),
                            color: cardBgColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(isDark ? 50 : 20),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withAlpha(20)
                                  : Colors.black.withAlpha(10),
                            ),
                          ),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              CustomTextWidget(
                                text: "Total Balance",
                                color: secondaryTextColor,
                                fontSize: 16,
                              ),
                              const SizedBox(height: 12),
                              Builder(
                                builder: (context) {
                                  final wallet = SuccessGetMyWalletState.wallet;
                                  final balance = wallet?.balance ?? 0;
                                  return Text(
                                    "${wallet?.currency ?? "\$"}${balance.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -1,
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
                            color: isDark
                                ? Colors.white.withAlpha(180)
                                : const Color(0xFF1E1E2E).withAlpha(180),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          CustomTextWidget(
                            text: "Recent Transactions",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
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
                                      color: isDark
                                          ? Colors.white.withAlpha(30)
                                          : Colors.black.withAlpha(10),
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextWidget(
                                      text: "No transactions yet",
                                      color: secondaryTextColor.withAlpha(100),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: transactions.length,
                              padding: const EdgeInsets.only(bottom: 20),
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                final isPayout = tx.transactionType == "PAYOUT";
                                final isCredit = tx.transactionType == "CREDIT";
                                final statusColor =
                                    tx.status?.toLowerCase() == "paid" ||
                                        tx.status?.toLowerCase() == "succeeded"
                                    ? Colors.green
                                    : (tx.status?.toLowerCase() == "pending"
                                          ? Colors.orange
                                          : Colors.red);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: SolidContainer(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color:
                                                (isCredit
                                                        ? Colors.green
                                                        : (isPayout
                                                              ? Colors.orange
                                                              : Colors.red))
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
                                                ? Colors.green
                                                : (isPayout
                                                      ? Colors.orange
                                                      : Colors.red),
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
                                                    tx.description ??
                                                    "Transaction",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: textColor,
                                              ),
                                              const SizedBox(height: 4),
                                              CustomTextWidget(
                                                text: tx.createdAt != null
                                                    ? DateFormat(
                                                        "MMM dd, yyyy • h:mm a",
                                                      ).format(tx.createdAt!)
                                                    : "Date Unknown",
                                                fontSize: 12,
                                                color: secondaryTextColor,
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
                                                    ? Colors.green
                                                    : (isPayout
                                                          ? Colors.orange
                                                          : Colors.red),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark
                ? Colors.white.withAlpha(20)
                : Colors.black.withAlpha(10),
          ),
        ),
        title: Text(
          "Withdraw Funds",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Enter the amount you wish to transfer to your bank account.",
              style: TextStyle(
                color: isDark
                    ? Colors.white.withAlpha(180)
                    : const Color(0xFF1E1E2E).withAlpha(180),
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
              "Cancel",
              style: TextStyle(
                color: isDark
                    ? Colors.white.withAlpha(150)
                    : const Color(0xFF1E1E2E).withAlpha(150),
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
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
                  backgroundColor: Colors.red,
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
              final isDark = isDarkTheme;
              final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
              return AlertDialog(
                backgroundColor: isDark
                    ? const Color(0xFF1E1E2E)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withAlpha(20)
                        : Colors.black.withAlpha(10),
                  ),
                ),
                title: Text(
                  "Stripe Connect Required",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  "You need to set up your Stripe Connect account first. Would you like to start onboarding?",
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withAlpha(180)
                        : const Color(0xFF1E1E2E).withAlpha(180),
                    fontSize: 14,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withAlpha(150)
                            : const Color(0xFF1E1E2E).withAlpha(150),
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
