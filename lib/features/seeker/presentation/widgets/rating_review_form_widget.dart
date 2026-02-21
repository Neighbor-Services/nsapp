// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/models/review.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';

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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: (Theme.of(context).brightness == Brightness.dark)
              ? const Color(0xFF1E1E2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (Theme.of(context).brightness == Brightness.dark)
                ? Colors.white.withAlpha(20)
                : Colors.black.withAlpha(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (Theme.of(context).brightness == Brightness.dark)
                      ? Colors.white.withAlpha(20)
                      : Colors.black.withAlpha(20),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              CustomTextWidget(
                text: "Rate your experience",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: (Theme.of(context).brightness == Brightness.dark)
                    ? Colors.white
                    : Colors.black87,
              ),
              const SizedBox(height: 8),
              CustomTextWidget(
                text: "How was your service with ${providerProfile.firstName}?",
                fontSize: 14,
                color: (Theme.of(context).brightness == Brightness.dark)
                    ? Colors.white70
                    : Colors.black54,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              StarRating(
                rating: _currentRating,
                size: 48,
                color: appOrangeColor1,
                borderColor: (Theme.of(context).brightness == Brightness.dark)
                    ? Colors.white54
                    : Colors.black26,
                emptyIcon: Icons.star_border_rounded,
                filledIcon: Icons.star_rounded,
                onRatingChanged: (rating) {
                  setState(() {
                    _currentRating = rating;
                  });
                },
              ),
              const SizedBox(height: 32),

              SolidTextField(
                controller: _reviewController,
                hintText: "Write your review here...",
                isMultiLine: true,
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color:
                                (Theme.of(context).brightness ==
                                    Brightness.dark)
                                ? Colors.white.withAlpha(10)
                                : Colors.black.withAlpha(10),
                          ),
                        ),
                      ),
                      child: CustomTextWidget(
                        text: "Cancel",
                        color: (Theme.of(context).brightness == Brightness.dark)
                            ? Colors.white70
                            : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appOrangeColor1,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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
        backgroundColor: Colors.red.withAlpha(80),
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
        backgroundColor: Colors.red.withAlpha(80),
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
      backgroundColor: Colors.green.withAlpha(80),
      colorText: Colors.white,
    );
  }
}
