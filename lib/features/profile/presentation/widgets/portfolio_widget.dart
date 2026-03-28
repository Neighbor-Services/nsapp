import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/about.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/profile/presentation/widgets/portfolio_gallery.dart';
import 'package:nsapp/core/core.dart';

class PortfolioWidget extends StatefulWidget {
  const PortfolioWidget({super.key});

  @override
  State<PortfolioWidget> createState() => _PortfolioWidgetState();
}

class _PortfolioWidgetState extends State<PortfolioWidget> {
  @override
  void initState() {
    context.read<ProfileBloc>().add(
      GetAboutEvent(user: PortfolioUserState.userId),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is PortfolioUserState) {
          context.read<ProfileBloc>().add(
            GetAboutEvent(user: PortfolioUserState.userId),
          );
          setState(() {});
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return FutureBuilder<Profile?>(
              future: (PortfolioUserState.userId.isNotEmpty)
                  ? Helpers.getSeekerProfile(PortfolioUserState.userId)
                  : Future.value(null),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget();
                }

                final profile = snapshot.data;

                return FutureBuilder<AboutData>(
                  future: SuccessGetAboutStreamState.about,
                  builder: (context, aboutSnapshot) {
                    if (!aboutSnapshot.hasData && profile == null) {
                      return const LoadingWidget();
                    }

                    final aboutData = aboutSnapshot.data ?? AboutData();

                    return ListView(
                      padding: EdgeInsets.only(bottom: 40),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        if (aboutData.about != null) ...[
                          _buildInfoSection(
                            icon: Icons.location_on_rounded,
                            title: "COMPANY ADDRESS",
                            content: aboutData.about?.address ?? "Not Set",
                          ),
                          const SizedBox(height: 16),
                          _buildInfoSection(
                            icon: Icons.business_center_rounded,
                            title: "COMPANY SPECIFICATION",
                            content:
                                aboutData.about?.specification ?? "Not Set",
                          ),
                          const SizedBox(height: 16),
                          _buildInfoSection(
                            icon: Icons.description_rounded,
                            title: "COMPANY DESCRIPTION",
                            content: aboutData.about?.description ?? "Not Set",
                          ),
                          const SizedBox(height: 32),
                          if (aboutData.about?.experienceYears != null &&
                              (aboutData.about?.experienceYears ?? 0) > 0) ...[
                            _buildInfoSection(
                              icon: Icons.timeline_rounded,
                              title: "EXPERIENCE",
                              content:
                                  "${aboutData.about!.experienceYears} Years",
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (aboutData.about?.education != null &&
                              aboutData.about!.education!.isNotEmpty) ...[
                            _buildInfoSection(
                              icon: Icons.school_rounded,
                              title: "EDUCATION",
                              content: aboutData.about?.education ?? "",
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (aboutData.about?.skills != null &&
                              aboutData.about!.skills!.isNotEmpty) ...[
                            _buildInfoSection(
                              icon: Icons.handyman_rounded,
                              title: "SKILLS",
                              content: (aboutData.about!.skills as List).join(
                                " • ",
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (aboutData.about?.languages != null &&
                              aboutData.about!.languages!.isNotEmpty) ...[
                            _buildInfoSection(
                              icon: Icons.translate_rounded,
                              title: "LANGUAGES",
                              content: (aboutData.about!.languages as List)
                                  .join(" • "),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ],

                        // Portfolio Gallery Section
                        if (profile != null)
                          PortfolioGallery(profile: profile, isProvider: false)
                        else if (aboutData.about?.imageUrls != null &&
                            aboutData.about!.imageUrls!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.photo_library_rounded,
                                    color:
                                        context.appColors.primaryBackground,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  CustomTextWidget(
                                    text: "PORTFOLIO",
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color:
                                        context.appColors.primaryBackground,
                                    letterSpacing: 1.2,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 180,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: aboutData.about!.imageUrls!.length,
                                  separatorBuilder: (c, i) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (c, i) => Container(
                                    width: 240,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            context.appColors.glassBorder,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(40),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        aboutData.about!.imageUrls![i],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        if (profile == null &&
                            (aboutData.about?.imageUrls == null ||
                                aboutData.about!.imageUrls!.isEmpty))
                          const EmptyWidget(
                            message: "No portfolio info available",
                            height: 150.0,
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return SolidContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.appColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: context.appColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.appColors.primaryTextColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              thickness: 0.5,
            ),
          ),
          Text(
            content.toUpperCase(),
            style: TextStyle(
              color: context.appColors.primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
