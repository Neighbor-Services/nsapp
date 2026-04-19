import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/core/core.dart';

class DisputesListPage extends StatefulWidget {
  const DisputesListPage({super.key});

  @override
  State<DisputesListPage> createState() => _DisputesListPageState();
}

class _DisputesListPageState extends State<DisputesListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SharedBloc>().add(GetMyDisputesEvent()); // Uncommented
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.hintTextColor;

    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(12.r),
              child: SizedBox(
                height: 60.h,
                width: size(context).width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        margin: EdgeInsets.all(8.r),
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
                          size: 18.r,
                        ),
                      ),
                    ),
                    Text(
                      'MY DISPUTES',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        letterSpacing: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/create-dispute');
                      },
                      child: Container(
                        margin: EdgeInsets.all(8.r),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.primaryColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            FaIcon(FontAwesomeIcons.plus,
                                color: Colors.white, size: 18.r),
                            SizedBox(width: 4.w),
                            Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SharedBloc, SharedState>(
                builder: (context, state) {
                  if (state is SharedLoadingState) {
                    return const Center(child: LoadingWidget());
                  }

                  if (state is SuccessGetMyDisputesState) {
                    final disputes = SuccessGetMyDisputesState.disputes;
                    return disputes.isEmpty
                        ? _buildEmptyState(textColor, secondaryTextColor)
                        : _buildDisputesList(
                            disputes,

                            textColor,
                            secondaryTextColor,
                          );
                  }

                  if (SuccessGetMyDisputesState.disputes.isNotEmpty) {
                    return _buildDisputesList(
                      SuccessGetMyDisputesState.disputes,

                      textColor,
                      secondaryTextColor,
                    );
                  }

                  return _buildEmptyState(textColor, secondaryTextColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color secondaryTextColor) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: SolidContainer(
          padding: EdgeInsets.all(40.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: context.appColors.warningColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: context.appColors.warningColor.withAlpha(50),
                  ),
                ),
                child: Icon(
                  FontAwesomeIcons.gavel,
                  color: context.appColors.warningColor,
                  size: 40.r,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'NO DISPUTES',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'YOU HAVEN\'T RAISED ANY DISPUTES YET',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 24.h),
              SolidButton(
                label: 'RAISE A DISPUTE',
                allCaps: true,
                onPressed: () {
                  Get.toNamed('/create-dispute');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisputesList(
    List<Dispute> disputes,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      itemCount: disputes.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final dispute = disputes[index];

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: GestureDetector(
            onTap: () => Get.toNamed('/dispute-details', arguments: dispute),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SolidContainer(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.primaryColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color:
                                  context.appColors.primaryColor.withAlpha(40),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: BoxDecoration(
                                  color: context.appColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                (dispute.status ?? 'OPEN').toUpperCase(),
                                style: TextStyle(
                                  color: context.appColors.primaryColor,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          FontAwesomeIcons.chevronRight,
                          color: secondaryTextColor,
                          size: 14.r,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      dispute.reason.toUpperCase(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      dispute.description,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.clock,
                          color: secondaryTextColor,
                          size: 14.r,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          dispute.createdAt != null
                              ? DateFormat.yMMMd().format(
                                  DateTime.parse(dispute.createdAt!),
                                )
                              : 'Recent',
                          style: TextStyle(
                            color: context.appColors.hintTextColor,
                            fontSize: 12.sp,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'VIEW DETAILS',
                          style: TextStyle(
                            color: context.appColors.warningColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}



