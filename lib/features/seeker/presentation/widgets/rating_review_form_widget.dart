// ignore_for_file: use_build_context_synchronously

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/models/review.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/core/core.dart';

class RatingReviewFormWidget extends StatefulWidget {
  const RatingReviewFormWidget({super.key});

  @override
  State<RatingReviewFormWidget> createState() => _RatingReviewFormWidgetState();
}

class _RatingReviewFormWidgetState extends State<RatingReviewFormWidget> {
  double _currentRating = 5.0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerProfile = ProviderToReviewState.lastProfile;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is SuccessAddReviewState) {
          Navigator.pop(context);
          Get.snackbar(
            "Thank You!",
            "Your review has been submitted successfully.",
            backgroundColor: context.appColors.successColor.withAlpha(200),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(16.r),
            borderRadius: 12.r,
          );
        } else if (state is FailureAddReviewState) {
          Get.snackbar(
            "Submission Failed",
            state.message.isNotEmpty
                ? state.message
                : "Could not submit your review. Please try again.",
            backgroundColor: context.appColors.errorColor.withAlpha(200),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(16.r),
            borderRadius: 12.r,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is LoadingProfileState;

        return Center(
          child: Container(
            width: context.width * 0.9,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: context.appColors.glassBorder,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: context.appColors.glassBorder,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  CustomTextWidget(
                    text: "Rate your experience",
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: context.appColors.primaryTextColor,
                  ),
                  SizedBox(height: 8.h),
                  CustomTextWidget(
                    text: "How was your service with ${providerProfile.firstName}?",
                    fontSize: 14.sp,
                    color: context.appColors.secondaryTextColor,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),

                  StarRating(
                    rating: _currentRating,
                    size: 48.r,
                    color: context.appColors.secondaryColor,
                    borderColor: context.appColors.secondaryTextColor,
                    emptyIcon: FontAwesomeIcons.star,
                    filledIcon: FontAwesomeIcons.star,
                    onRatingChanged: isLoading
                        ? null
                        : (rating) {
                            setState(() {
                              _currentRating = rating;
                            });
                          },
                  ),
                  SizedBox(height: 32.h),

                  SolidTextField(
                    controller: _reviewController,
                    hintText: "Write your review here...",
                    isMultiLine: true,
                    readOnly: isLoading,
                  ),
                  SizedBox(height: 32.h),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                              side: BorderSide(
                                color: context.appColors.glassBorder,
                              ),
                            ),
                          ),
                          child: CustomTextWidget(
                            text: "Cancel",
                            color: context.appColors.secondaryTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.appColors.secondaryColor,
                            disabledBackgroundColor:
                                context.appColors.secondaryColor.withAlpha(120),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 20.r,
                                  height: 20.r,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const CustomTextWidget(
                                  text: "Submit Review",
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
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
  }

  void _submitReview() {
    if (_reviewController.text.trim().isEmpty) {
      Get.snackbar(
        "Review Required",
        "Please write a short review to share your experience.",
        backgroundColor: context.appColors.errorColor.withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.r),
        borderRadius: 12.r,
      );
      return;
    }

    final providerProfile = ProviderToReviewState.lastProfile;
    final providerId =
        ProviderToReviewState.lastProviderUserId ??
        providerProfile.user?.id ??
        providerProfile.id;

    if (providerId == null || providerId.isEmpty) {
      Get.snackbar(
        "Error",
        "Unable to submit review. Provider information is incomplete.",
        backgroundColor: context.appColors.errorColor.withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.all(16.r),
        borderRadius: 12.r,
      );
      return;
    }

    final review = Review(
      rating: _currentRating.toInt(),
      comment: _reviewController.text.trim(),
      provider: providerId,
    );

    // Dispatch event — BlocListener will handle closing the dialog on success/failure.
    context.read<ProfileBloc>().add(AddReviewEvent(review: review));
  }
}
