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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                      padding: EdgeInsets.only(bottom: 40.h),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        if (aboutData.about != null) ...[
                          _buildInfoSection(
                            icon: Icons.location_on_rounded,
                            title: "COMPANY ADDRESS",
                            content: aboutData.about?.address ?? "Not Set",
                          ),
                          SizedBox(height: 16.h),
                          _buildInfoSection(
                            icon: Icons.business_center_rounded,
                            title: "COMPANY SPECIFICATION",
                            content:
                                aboutData.about?.specification ?? "Not Set",
                          ),
                          SizedBox(height: 16.h),
                          _buildInfoSection(
                            icon: Icons.description_rounded,
                            title: "COMPANY DESCRIPTION",
                            content: aboutData.about?.description ?? "Not Set",
                          ),
                          SizedBox(height: 32.h),
                          if (aboutData.about?.experienceYears != null &&
                              (aboutData.about?.experienceYears ?? 0) > 0) ...[
                            _buildInfoSection(
                              icon: Icons.timeline_rounded,
                              title: "EXPERIENCE",
                              content:
                                  "${aboutData.about!.experienceYears} Years",
                            ),
                            SizedBox(height: 16.h),
                          ],
                          if (aboutData.about?.education != null &&
                              aboutData.about!.education!.isNotEmpty) ...[
                            _buildInfoSection(
                              icon: Icons.school_rounded,
                              title: "EDUCATION",
                              content: aboutData.about?.education ?? "",
                            ),
                            SizedBox(height: 16.h),
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
                            SizedBox(height: 16.h),
                          ],
                          if (aboutData.about?.languages != null &&
                              aboutData.about!.languages!.isNotEmpty) ...[
                            _buildInfoSection(
                              icon: Icons.translate_rounded,
                              title: "LANGUAGES",
                              content: (aboutData.about!.languages as List)
                                  .join(" • "),
                            ),
                            SizedBox(height: 32.h),
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
                                    size: 20.r,
                                  ),
                                  SizedBox(width: 12.w),
                                  CustomTextWidget(
                                    text: "PORTFOLIO",
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18.sp,
                                    color:
                                        context.appColors.primaryBackground,
                                    letterSpacing: 1.2,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              SizedBox(
                                height: 180.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: aboutData.about!.imageUrls!.length,
                                  separatorBuilder: (c, i) =>
                                      SizedBox(width: 12.w),
                                  itemBuilder: (c, i) => Container(
                                    width: 240.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color:
                                            context.appColors.glassBorder,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(40),
                                          blurRadius: 10.r,
                                          offset: Offset(0, 4.h),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.r),
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
                          EmptyWidget(
                            message: "No portfolio info available",
                            height: 150.0.h,
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
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: context.appColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: context.appColors.primaryColor,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.appColors.primaryTextColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.sp,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(
              height: 1.h,
              thickness: 0.5,
            ),
          ),
          Text(
            content.toUpperCase(),
            style: TextStyle(
              color: context.appColors.primaryTextColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
