import 'package:go_router/go_router.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nsapp/core/helpers/helpers.dart';



import 'package:nsapp/features/shared/presentation/bloc/wallet/wallet_bloc.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:nsapp/core/core.dart';

import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';

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

    context.read<WalletBloc>().add(GetMyWalletEvent());

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

            fontWeight: FontWeight.w500,

            fontSize: 18.sp,

            letterSpacing: 1.2,

          ),

        ),

        centerTitle: true,

        backgroundColor: Colors.transparent,

        elevation: 0,

        leading: BlocBuilder<ProfileBloc, ProfileState>(

          builder: (context, state) {

            return GestureDetector(

              onTap: () {

                if (state is SuccessGetProfileState &&

                    Helpers.isProvider(state.profile.userType)) {

                  context.pop();

                } else {

                  context.pop();

                }

              },

              child: Container(

                margin: EdgeInsets.all(10.r),

                decoration: BoxDecoration(

                  color: context.appColors.iconContainerBackground,

                  borderRadius: BorderRadius.circular(12.r),

                  border: Border.all(

                    color: context.appColors.glassBorder,

                  ),

                  boxShadow: Theme.of(context).brightness == Brightness.dark

                      ? null

                      : [

                          BoxShadow(

                            color: Colors.black.withAlpha(10),

                            blurRadius: 10.r,

                            spreadRadius: 2.r,

                          ),

                        ],

                ),

                child: FaIcon(

                  FontAwesomeIcons.chevronLeft,

                  color: context.appColors.primaryTextColor,

                  size: 16.r,

                ),

              ),

            );

          },

        ),

        actions: [

          IconButton(

            onPressed: () => context.read<WalletBloc>().add(GetMyWalletEvent()),

            icon: FaIcon(FontAwesomeIcons.rotateRight, color: context.appColors.primaryTextColor),

          ),

        ],

      ),

      body: BlocListener<WalletBloc, WalletState>(

        listener: (context, state) async {

          if (state is SuccessGetStripeDashboardLinkState) {

            final url = state.dashboardUrl;

            if (url.isNotEmpty && context.mounted) {

              try {

                final uri = Uri.parse(url);

                if (await canLaunchUrl(uri)) {

                  await launchUrl(uri, mode: LaunchMode.externalApplication);

                }

              } catch (e) {

                if (context.mounted) {

                  DialogUtils.showCustomAlert(

                    context,

                    AlertType.error,

                    'Error: ${e.toString()}',

                  );

                }

              }

            }

          } else if (state is WalletFailure) {

            if (context.mounted) {

              showDialog(

                context: context,

                builder: (dialogContext) {

                  final textColor = context.appColors.primaryTextColor;

                  return AlertDialog(

                    backgroundColor: context.appColors.cardBackground,

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(24.r),

                      side: BorderSide(

                        color: context.appColors.glassBorder,

                      ),

                    ),

                    title: Text(

                      "STRIPE CONNECT REQUIRED",

                      style: TextStyle(

                        color: textColor,

                        fontWeight: FontWeight.w500,

                        fontSize: 18.sp,

                        letterSpacing: 1.2,

                      ),

                    ),

                    content: Text(

                      "You need to set up your Stripe Connect account first. Would you like to start onboarding?",

                      style: TextStyle(

                        color: context.appColors.secondaryTextColor,

                        fontSize: 14.sp,

                      ),

                    ),

                    actions: [

                      TextButton(

                        onPressed: () => context.pop(),

                        child: Text(

                          "Cancel",

                          style: TextStyle(

                            color: context.appColors.secondaryTextColor.withAlpha(150),

                          ),

                        ),

                      ),

                      SolidButton(

                        onPressed: () {

                          context.pop();

                          context.read<WalletBloc>().add(

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

            final accountLink = state.accountLink;

            if (accountLink.url.isNotEmpty && context.mounted) {

              launchUrl(

                Uri.parse(accountLink.url),

                mode: LaunchMode.externalApplication,

              );

            }

          }

        },

        child: BlocBuilder<WalletBloc, WalletState>(

          builder: (context, state) {

          return LoadingView(

            isLoading: state is WalletLoading,

            child: GradientBackground(

              child: SafeArea(

                child: Padding(

                  padding: EdgeInsets.symmetric(horizontal: 20.w),

                  child: Column(

                    children: [

                      SizedBox(height: 20.h),

                      TweenAnimationBuilder<double>(

                        tween: Tween(begin: 0, end: 1),

                        duration: const Duration(milliseconds: 800),

                        builder: (context, value, child) => Opacity(

                          opacity: value,

                          child: Transform.translate(

                            offset: Offset(0, 20.h * (1 - value)),

                            child: child,

                          ),

                        ),

                        child: Container(

                          width: double.infinity,

                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(12.r),

                            color: context.appColors.cardBackground,

                            gradient: context.appColors.primaryGradient,

                            border: Border.all(

                              color: context.appColors.glassBorder,

                            ),

                          ),

                          padding: EdgeInsets.all(32.r),

                          child: Column(

                            children: [

                              CustomTextWidget(

                                text: "TOTAL BALANCE",

                                color: context.appColors.secondaryTextColor,

                                fontSize: 15.sp,

                                fontWeight: FontWeight.w500,

                                letterSpacing: 1.2,

                              ),

                              SizedBox(height: 12.h),

                              Builder(

                                builder: (context) {

                                  final wallet = (state is SuccessGetMyWalletState) ? state.wallet : null;

                                  final balance = wallet?.balance ?? 0;

                                  return Text(

                                    "${wallet?.currency ?? "\$"} ${balance.toStringAsFixed(2)}",

                                    style: TextStyle(

                                      color: context.appColors.primaryColor,

                                      fontSize: 42.sp,

                                      fontWeight: FontWeight.w500,

                                      letterSpacing: -0.5,

                                    ),

                                  );

                                },

                              ),

                              SizedBox(height: 32.h),

                              Row(

                                children: [

                                  Expanded(

                                    child: SolidButton(

                                      label: "Withdraw",

                                      onPressed: () =>

                                          _showPayoutDialog(context),

                                    ),

                                  ),

                                  SizedBox(width: 16.w),

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

                      SizedBox(height: 40.h),

                      Row(

                        children: [

                          FaIcon(

                            FontAwesomeIcons.clockRotateLeft,

                            color: context.appColors.secondaryTextColor,

                            size: 20.r,

                          ),

                          SizedBox(width: 12.w),

                          CustomTextWidget(

                            text: "RECENT TRANSACTIONS",

                            fontSize: 14.sp,

                            fontWeight: FontWeight.w500,

                            color: context.appColors.primaryTextColor,

                            letterSpacing: 1.1,

                          ),

                        ],

                      ),

                      SizedBox(height: 20.h),

                      Expanded(

                        child: Builder(

                          builder: (context) {

                            final transactions = (state is SuccessGetMyWalletState) 

                                ? state.wallet?.transactions ?? [] 

                                : [];

                            if (transactions.isEmpty) {

                              return Center(

                                child: Column(

                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [

                                    FaIcon(

                                      FontAwesomeIcons.fileInvoice,

                                      size: 64.r,

                                      color: context.appColors.secondaryTextColor.withAlpha(30),

                                    ),

                                    SizedBox(height: 16.h),

                                    CustomTextWidget(

                                      text: "NO TRANSACTIONS YET",

                                      color: context.appColors.secondaryTextColor.withAlpha(100),

                                      fontSize: 12.sp,

                                      fontWeight: FontWeight.w500,

                                      letterSpacing: 1.0,

                                    ),

                                  ],

                                ),

                              );

                            }

                            return ListView.builder(

                              physics: const BouncingScrollPhysics(),

                              itemCount: transactions.length,

                              padding: EdgeInsets.only(bottom: 20.h),

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



                                return TweenAnimationBuilder<double>(

                                  tween: Tween(begin: 0.0, end: 1.0),

                                  duration: Duration(milliseconds: 400 + (index * 100)),

                                  curve: Curves.easeOut,

                                  builder: (context, value, child) {

                                    return Transform.translate(

                                      offset: Offset(0, 20 * (1 - value)),

                                      child: Opacity(opacity: value, child: child),

                                    );

                                  },

                                  child: Container(

                                    margin: EdgeInsets.only(bottom: 12.h),

                                  child: SolidContainer(

                                    padding: EdgeInsets.all(16.r),

                                    child: Row(

                                      children: [

                                        Container(

                                          padding: EdgeInsets.all(12.r),

                                          decoration: BoxDecoration(

                                            color:

                                                (isCredit

                                                        ? context.appColors.successColor

                                                        : (isPayout

                                                              ? context.appColors.warningColor

                                                              : context.appColors.errorColor))

                                                    .withAlpha(30),

                                            borderRadius: BorderRadius.circular(

                                              15.r,

                                            ),

                                          ),

                                          child: FaIcon(

                                            isCredit

                                                ? FontAwesomeIcons.arrowDown

                                                : FontAwesomeIcons.arrowUp,

                                            color: isCredit

                                                ? context.appColors.successColor

                                                : (isPayout

                                                      ? context.appColors.warningColor

                                                      : context.appColors.errorColor),

                                            size: 20.r,

                                          ),

                                        ),

                                        SizedBox(width: 16.w),

                                        Expanded(

                                          child: Column(

                                            crossAxisAlignment:

                                                CrossAxisAlignment.start,

                                            children: [

                                              CustomTextWidget(

                                                text:

                                                    (tx.description ?? "Transaction").toUpperCase(),

                                                fontWeight: FontWeight.w500,

                                                fontSize: 14.sp,

                                                color: context.appColors.primaryTextColor,

                                              ),

                                              SizedBox(height: 4.h),

                                              CustomTextWidget(

                                                text: tx.createdAt != null

                                                    ? DateFormat(

                                                        "MMM dd, yyyy â€¢ h:mm a",

                                                      ).format(tx.createdAt!)

                                                    : "Date Unknown",

                                                fontSize: 12.sp,

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

                                                fontWeight: FontWeight.w500,

                                                fontSize: 16.sp,

                                              ),

                                            ),

                                            SizedBox(height: 4.h),

                                            Container(

                                              padding:

                                                  EdgeInsets.symmetric(

                                                    horizontal: 8.w,

                                                    vertical: 2.h,

                                                  ),

                                              decoration: BoxDecoration(

                                                color: statusColor.withAlpha(

                                                  20,

                                                ),

                                                borderRadius:

                                                    BorderRadius.circular(8.r),

                                              ),

                                              child: CustomTextWidget(

                                                text:

                                                    tx.status?.toUpperCase() ??

                                                    "PENDING",

                                                fontSize: 10.sp,

                                                fontWeight: FontWeight.w500,

                                                color: statusColor,

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

          borderRadius: BorderRadius.circular(24.r),

          side: BorderSide(

            color: context.appColors.glassBorder,

          ),

        ),

        title: Text(

          "WITHDRAW FUNDS",

          style: TextStyle(

            color: textColor,

            fontWeight: FontWeight.w500,

            fontSize: 18.sp,

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

                fontSize: 14.sp,

              ),

            ),

            SizedBox(height: 24.h),

            SolidTextField(

              controller: amountController,

              hintText: "Amount (e.g. 50.00)",

              prefixIcon: FontAwesomeIcons.dollarSign,

              keyboardType: TextInputType.number,

            ),

          ],

        ),

        actions: [

          TextButton(

            onPressed: () => context.pop(),

            child: Text(

              "CANCEL",

              style: TextStyle(

                color: context.appColors.secondaryTextColor.withAlpha(150),

                fontWeight: FontWeight.w500,

                fontSize: 12.sp,

                letterSpacing: 1.0,

              ),

            ),

          ),

          SolidButton(

            onPressed: () {

              final amount = double.tryParse(amountController.text);

              if (amount != null && amount > 0) {

                context.read<WalletBloc>().add(

                  RequestPayoutEvent(amount: amount),

                );

                context.pop();

              }

            },

            label: "Confirm",

          ),

        ],

      ),

    );

  }



  void _openStripeDashboard(BuildContext context) async {

    context.read<WalletBloc>().add(GetStripeDashboardLinkEvent());

  }

}





