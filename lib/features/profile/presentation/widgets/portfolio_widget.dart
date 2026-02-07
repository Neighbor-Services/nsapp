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
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      padding: const EdgeInsets.only(bottom: 40),
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
                                        (Theme.of(context).brightness ==
                                            Brightness.dark)
                                        ? Colors.white
                                        : Colors.black87,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  CustomTextWidget(
                                    text: "PORTFOLIO",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color:
                                        (Theme.of(context).brightness ==
                                            Brightness.dark)
                                        ? Colors.white
                                        : Colors.black87,
                                    letterSpacing: 0.5,
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
                                            (Theme.of(context).brightness ==
                                                Brightness.dark)
                                            ? Colors.white.withAlpha(30)
                                            : Colors.black.withAlpha(10),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(40),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SolidContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(20)
                      : Colors.orange.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: appOrangeColor1, size: 20),
              ),
              const SizedBox(width: 12),
              CustomTextWidget(
                text: title,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: isDark ? Colors.white.withAlpha(150) : Colors.black54,
                letterSpacing: 1.2,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: isDark ? Colors.white12 : Colors.black12,
              height: 1,
            ),
          ),
          CustomTextWidget(
            text: content.toUpperCase(),
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ],
      ),
    );
  }
}
