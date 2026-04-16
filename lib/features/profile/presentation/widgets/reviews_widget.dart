import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/review.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/core/core.dart';

class ReviewsWidget extends StatefulWidget {
  const ReviewsWidget({super.key});

  @override
  State<ReviewsWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends State<ReviewsWidget> {
  @override
  void initState() {
    context.read<ProfileBloc>().add(
      GetReviewsEvent(user: PortfolioUserState.userId),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is SuccessAddReviewState) {
          context.read<ProfileBloc>().add(
            GetReviewsEvent(user: PortfolioUserState.userId),
          );
          Get.snackbar(
            "Success",
            "Review sent",
            colorText: Colors.white,
            backgroundColor: context.appColors.successColor.withAlpha(150),
          );
        }
        if (state is FailureAddReviewState) {
          Get.snackbar(
            "Error",
            "An error occurred",
            colorText: Colors.white,
            backgroundColor: context.appColors.errorColor.withAlpha(150),
          );
        }
        if (state is PortfolioUserState) {
          context.read<ProfileBloc>().add(
            GetReviewsEvent(user: PortfolioUserState.userId),
          );
          setState(() {});
        }
      },
      builder: (context, state) {
        return LoadingView(
          isLoading: (state is LoadingProfileState),
          child: Stack(
            children: [
              FutureBuilder<List<ReviewData>>(
                future: SuccessGetReviewStreamState.reviews,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LoadingWidget();
                  }
                  if (snapshot.data!.isEmpty) {
                    return EmptyWidget(
                      message: "No reviews yet. Be the first to write one!",
                      height: 300.h,
                    );
                  }

                  final reviews = snapshot.data!;
                  return ListView.builder(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 10.h,
                      bottom: 100.h,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        child: SolidContainer(
                          padding: EdgeInsets.all(20.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: context.appColors.glassBorder,
                                        width: 1.5.r,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 22.r,
                                      backgroundColor: Colors.white.withAlpha(
                                        20,
                                      ),
                                      backgroundImage:
                                          (review
                                                  .from
                                                  ?.profilePictureUrl
                                                  ?.isNotEmpty ??
                                              false)
                                          ? NetworkImage(
                                              review.from!.profilePictureUrl!,
                                            )
                                          : const AssetImage(logoAssets)
                                                as ImageProvider,
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
                                              (review.from?.firstName ??
                                              "Anonymous").toUpperCase(),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14.sp,
                                          color: context.appColors.primaryTextColor,
                                          letterSpacing: 0.5,
                                        ),
                                        SizedBox(height: 4.h),
                                        CustomTextWidget(
                                          text: DateFormat("MMMM dd, yyyy")
                                              .format(
                                                review.review?.createdAt ??
                                                    DateTime.now(),
                                              ),
                                          fontSize: 12.sp,
                                          color: context.appColors.secondaryTextColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (review.review?.rating != null)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.appColors.cardBackground,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                           Icon(
                                            FontAwesomeIcons.star,
                                            color: context.appColors.secondaryColor,
                                            size: 16.r,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            review.review!.rating!
                                                .toStringAsFixed(1),
                                            style: TextStyle(
                                              color: context.appColors.secondaryColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12.sp,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16.r),
                                decoration: BoxDecoration(
                                  color: context.appColors.cardBackground,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: context.appColors.glassBorder,
                                  ),
                                ),
                                child: CustomTextWidget(
                                  text: review.review?.comment ?? "",
                                  fontSize: 15.sp,
                                  color: context.appColors.primaryTextColor,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

