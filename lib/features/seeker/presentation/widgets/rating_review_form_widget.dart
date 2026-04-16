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
  Widget build(BuildContext context) {
    final providerProfile = ProviderToReviewState.profile;

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
                fontWeight: FontWeight.bold,
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
                onRatingChanged: (rating) {
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
              ),
              SizedBox(height: 32.h),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                          side: BorderSide(
                            color:
                                context.appColors.glassBorder,
                          ),
                        ),
                      ),
                      child: CustomTextWidget(
                        text: "Cancel",
                        color: context.appColors.secondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.secondaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: const CustomTextWidget(
                        text: "Submit Review",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
  }

  void _submitReview() {
    if (_reviewController.text.trim().isEmpty) {
      Get.snackbar(
        "Review Required",
        "Please write a short review to share your experience.",
        backgroundColor: context.appColors.errorColor.withAlpha(80),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final providerProfile = ProviderToReviewState.profile;
    final providerId =
        ProviderToReviewState.providerUserId ??
        providerProfile.user?.id ??
        providerProfile.id;

    if (providerId == null || providerId.isEmpty) {
      Get.snackbar(
        "Error",
        "Unable to submit review. Provider information is incomplete.",
        backgroundColor: context.appColors.errorColor.withAlpha(80),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final review = Review(
      rating: _currentRating.toInt(),
      comment: _reviewController.text.trim(),
      provider: providerId,
    );

    context.read<ProfileBloc>().add(AddReviewEvent(review: review));
    Navigator.pop(context);
    Get.snackbar(
      "Thank You!",
      "Your review has been submitted successfully.",
      backgroundColor: context.appColors.successColor.withAlpha(80),
      colorText: Colors.white,
    );
  }
}


