import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/review.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/seeker/presentation/widgets/rating_review_form_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/core/core.dart';


class ReviewsWidget extends StatefulWidget {
  const ReviewsWidget({super.key});

  @override
  State<ReviewsWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends State<ReviewsWidget> {
  TextEditingController reviewTextController = TextEditingController();

  init() async {
    context.read<ProfileBloc>().add(
      GetReviewsEvent(user: PortfolioUserState.userId),
    );
  }

  @override
  void initState() {
    context.read<ProfileBloc>().add(
      GetReviewsEvent(user: PortfolioUserState.userId),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is SuccessAddReviewState) {
            context.read<ProfileBloc>().add(
              GetReviewsEvent(user: PortfolioUserState.userId),
            );
            Get.snackbar("Success", "Review sent");
          }
          if (state is FailureAddReviewState) {
            context.read<ProfileBloc>().add(
              GetReviewsEvent(user: PortfolioUserState.userId),
            );
            Get.snackbar("Warning", "An error occurred");
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is LoadingProfileState),
            child: GradientBackground(
              child: SizedBox(
                height: size(context).height,
                width: size(context).width,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            height: size(context).height - 180,
                            padding: EdgeInsets.only(bottom: 80),
                            child: FutureBuilder<List<ReviewData>>(
                              future: SuccessGetReviewStreamState.reviews,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.isNotEmpty) {
                                    return ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: snapshot.data!.length,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        ReviewData reviewData =
                                            snapshot.data![index];
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 6,
                                            horizontal: 4,
                                          ),
                                          child: SolidContainer(
                                            padding: EdgeInsets.all(16),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white
                                                              .withAlpha(50),
                                                          width: 2,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withAlpha(30),
                                                            blurRadius: 5,
                                                          ),
                                                        ],
                                                      ),
                                                      child: CircleAvatar(
                                                        radius: 20,
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        backgroundImage:
                                                            (reviewData
                                                                    .from!
                                                                    .profilePictureUrl !=
                                                                "")
                                                            ? NetworkImage(
                                                                reviewData
                                                                    .from!
                                                                    .profilePictureUrl!,
                                                              )
                                                            : AssetImage(
                                                                    logoAssets,
                                                                  )
                                                                  as ImageProvider,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomTextWidget(
                                                            text: reviewData
                                                                .from!
                                                                .firstName!,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                          CustomTextWidget(
                                                            text:
                                                                DateFormat(
                                                                  "MMM dd, yyyy",
                                                                ).format(
                                                                  reviewData
                                                                      .review!
                                                                      .createdAt!,
                                                                ),
                                                            fontSize: 12,
                                                            color: Colors.white
                                                                .withAlpha(120),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    // Display Rating
                                                    if (reviewData
                                                            .review!
                                                            .rating !=
                                                        null)
                                                      StarRating(
                                                        rating: reviewData
                                                            .review!
                                                            .rating!
                                                            .toDouble(),
                                                        color: context.appColors.secondaryColor,
                                                        borderColor:
                                                            Colors.white54,
                                                        size: 14,
                                                        allowHalfRating: false,
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 12),
                                                Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(
                                                    12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withAlpha(10),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: CustomTextWidget(
                                                    text:
                                                        reviewData
                                                            .review!
                                                            .comment ??
                                                        '',
                                                    fontSize: 15,
                                                    color: Colors.white
                                                        .withAlpha(220),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    return EmptyWidget(
                                      message: "There is no any review yet!",
                                      height: size(context).height - 350,
                                    );
                                  }
                                } else {
                                  return const LoadingWidget();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (PortfolioUserState.userId !=
                        SuccessGetProfileState.profile.user!.id)
                      Positioned(
                        bottom: 30,
                        right: 20,
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            Get.dialog(
                              const RatingReviewFormWidget(),
                              barrierColor: Colors.black.withValues(alpha: 80),
                            );
                          },
                          backgroundColor: context.appColors.secondaryColor,
                          icon: const Icon(
                            FontAwesomeIcons.penToSquare,
                            color: Colors.white,
                          ),
                          label: const CustomTextWidget(
                            text: "Write a Review",
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

