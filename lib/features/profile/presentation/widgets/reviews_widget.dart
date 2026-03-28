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
                    return const EmptyWidget(
                      message: "No reviews yet. Be the first to write one!",
                      height: 300,
                    );
                  }

                  final reviews = snapshot.data!;
                  return ListView.builder(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 10,
                      bottom: 100,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        child: SolidContainer(
                          padding: EdgeInsets.all(20),
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
                                        width: 1.5,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 22,
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
                                  const SizedBox(width: 16),
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
                                          fontSize: 14,
                                          color: context.appColors.primaryTextColor,
                                          letterSpacing: 0.5,
                                        ),
                                        const SizedBox(height: 4),
                                        CustomTextWidget(
                                          text: DateFormat("MMMM dd, yyyy")
                                              .format(
                                                review.review?.createdAt ??
                                                    DateTime.now(),
                                              ),
                                          fontSize: 12,
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
                                            Icons.star_rounded,
                                            color: context.appColors.secondaryColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            review.review!.rating!
                                                .toStringAsFixed(1),
                                            style: TextStyle(
                                              color: context.appColors.secondaryColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: context.appColors.cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: context.appColors.glassBorder,
                                  ),
                                ),
                                child: CustomTextWidget(
                                  text: review.review?.comment ?? "",
                                  fontSize: 15,
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
