import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/about.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/profile/presentation/widgets/portfolio_gallery.dart';

class PortfolioWidget extends StatefulWidget {
  const PortfolioWidget({super.key});

  @override
  State<PortfolioWidget> createState() => _PortfolioWidgetState();
}

class _PortfolioWidgetState extends State<PortfolioWidget> {
  @override
  void initState() {
    // We reuse GetAboutEvent to fetch AboutData, but we also need the full Profile for PortfolioItems.
    // However, AboutData is legacy. Ideally, we should fetch Profile.
    // Yet, GetProfileEvent usually targets "me" or a specific User ID.
    // Let's rely on GetProfileUseCase logic in Bloc if possible, or trigger a fetch.

    // Check if we are viewing another user (Seeker viewing Provider)
    // Trigger generic profile fetch for this user
    // But ProfileBloc's GetProfileEvent logic is:
    // if (SuccessGetProfileState.profile.user != null) fetch(user.id) else fetch(uid)
    // This is messy.

    // Let's use the GetAboutEvent as primary trigger for legacy data,
    // AND trigger a separate event if we can, or just fetch Profile manually here? No, stick to Bloc.

    // Actually, let's look at how about_page.dart is used.
    // It's likely used after navigating to a profile.

    context.read<ProfileBloc>().add(
      GetAboutEvent(user: PortfolioUserState.userId),
    );

    // We also need the profile for portfolio items.
    // There isn't a clean "GetOtherUserProfile" event in the current Bloc snippet.
    // But `GetSeekerProfile` helper exists.

    // Let's assume for now that `GetAboutEvent` is sufficient for the "About" tab text,
    // but for PortfolioGallery we need a Profile object.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          // We need to fetch the Profile to pass to PortfolioGallery.
          // Since ProfileBloc doesn't seem to hold "Other User Profile" state explicitly distinct from "My Profile"
          // (except maybe SuccessGetProfileState.profile which might be overwritten?),
          // this is risky if we are the provider viewing ourselves vs a seeker viewing us.

          // However, looking at `helpers.dart`: `getSeekerProfile(uid)`.
          // Let's use a FutureBuilder here to fetch the profile directly using the Helper
          // if we have a userID, to avoid messing with global Bloc state if it's meant for the "Me" profile.

          return FutureBuilder<Profile?>(
            future: (PortfolioUserState.userId.isNotEmpty)
                ? Helpers.getSeekerProfile(PortfolioUserState.userId)
                : Future.value(null), // Or get current profile?
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingWidget();
              }

              final profile = snapshot.data;

              return FutureBuilder<AboutData>(
                future: SuccessGetAboutStreamState.about,
                builder: (context, aboutSnapshot) {
                  // We display AboutData if available, plus PortfolioGallery if Profile is available.

                  if (!aboutSnapshot.hasData && profile == null) {
                    return const LoadingWidget();
                  }

                  final aboutData = aboutSnapshot.data ?? AboutData();

                  return ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      if (aboutData.about != null) ...[
                        SolidContainer(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: appWhiteColor),
                                  SizedBox(width: 8),
                                  CustomTextWidget(
                                    text: "COMPANY ADDRESS",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: appWhiteColor,
                                  ),
                                ],
                              ),
                              Divider(color: Colors.white24, height: 24),
                              CustomTextWidget(
                                text: (aboutData.about?.address ?? "Not Set")
                                    .toUpperCase(),
                                color: Colors.white.withAlpha(200),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        SolidContainer(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.work, color: appWhiteColor),
                                  SizedBox(width: 8),
                                  CustomTextWidget(
                                    text: "COMPANY SPECIFICATION",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: appWhiteColor,
                                  ),
                                ],
                              ),
                              Divider(color: Colors.white24, height: 24),
                              CustomTextWidget(
                                text:
                                    (aboutData.about?.specification ??
                                            "Not Set")
                                        .toUpperCase(),
                                color: Colors.white.withAlpha(200),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        SolidContainer(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.description, color: appWhiteColor),
                                  SizedBox(width: 8),
                                  CustomTextWidget(
                                    text: "COMPANY DESCRIPTION",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: appWhiteColor,
                                  ),
                                ],
                              ),
                              Divider(color: Colors.white24, height: 24),
                              CustomTextWidget(
                                text:
                                    (aboutData.about?.description ?? "Not Set")
                                        .toUpperCase(),
                                color: Colors.white.withAlpha(200),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                      ],

                      // NEW: Portfolio Gallery
                      if (profile != null)
                        PortfolioGallery(
                          profile: profile,
                          isProvider: false, // Viewer mode
                        )
                      else if (aboutData.about?.imageUrls != null &&
                          aboutData.about!.imageUrls!.isNotEmpty)
                        // Fallback to legacy images if Profile fetch failed but legacy data exists
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextWidget(
                              text: "PORTFOLIO (Legacy)",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: appWhiteColor,
                            ),
                            SizedBox(height: 12),
                            // ... (Legacy Image Row code reserved or simplified) ...
                            SizedBox(
                              height: 160,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: aboutData.about!.imageUrls!.length,
                                separatorBuilder: (c, i) => SizedBox(width: 10),
                                itemBuilder: (c, i) => ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    aboutData.about!.imageUrls![i],
                                    height: 160,
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                      if (profile == null &&
                          (aboutData.about?.imageUrls == null ||
                              aboutData.about!.imageUrls!.isEmpty))
                        EmptyWidget(
                          message: "No portfolio info available",
                          height: 100,
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
