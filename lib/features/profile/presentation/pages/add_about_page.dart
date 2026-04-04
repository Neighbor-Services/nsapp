import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/models/about.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_home_page.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/core.dart';

class AddAboutPage extends StatefulWidget {
  const AddAboutPage({super.key});

  @override
  State<AddAboutPage> createState() => _AddAboutPageState();
}

class _AddAboutPageState extends State<AddAboutPage> {
  TextEditingController companyNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController specificationController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController skillsController =
      TextEditingController(); // Comma separated
  TextEditingController educationController = TextEditingController();
  TextEditingController languagesController =
      TextEditingController(); // Comma separated
  GlobalKey<FormState> key = GlobalKey<FormState>();
  String countryCode = "";
  bool isSet = false;
  String aboutID = "";

  @override
  void initState() {
    final userId = SuccessGetProfileState.profile.user?.id;
    if (userId != null) {
      context.read<ProfileBloc>().add(GetAboutEvent(user: userId));
    }
    context.read<SharedBloc>().add(GetServicesEvent());
    // Clear images from previous session
    ImagesProfileState.images = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is SuccessAddAboutState) {
            final userId = SuccessGetProfileState.profile.user?.id;
            if (userId != null) {
              context.read<ProfileBloc>().add(GetAboutEvent(user: userId));
            }
            customAlert(
              context,
              AlertType.success,
              "Portfolio Created Successfully",
            );
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                context.read<ProviderBloc>().add(
                  NavigateProviderEvent(page: 1, widget: ProviderHomePage()),
                );
              }
            });
          } else if (state is FailureAddAboutState) {
            customAlert(context, AlertType.error, "Failed To Create Portfolio");
          } else if (state is SuccessGetAboutStreamState) {
            SuccessGetAboutStreamState.about?.then((aboutData) {
              if (aboutData.user != null) {
                isSet = true;
                aboutID = aboutData.about?.id ?? "";
              }
              companyNameController.text = aboutData.about?.name ?? "";
              addressController.text = aboutData.about?.address ?? "";
              specificationController.text =
                  aboutData.about?.specification ?? "";
              descriptionController.text = aboutData.about?.description ?? "";
              experienceController.text =
                  (aboutData.about?.experienceYears ?? 0).toString();
              skillsController.text = (aboutData.about?.skills ?? []).join(
                ", ",
              );
              educationController.text = aboutData.about?.education ?? "";
              languagesController.text = (aboutData.about?.languages ?? [])
                  .join(", ");
            });
          }
        },
        builder: (context, state) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = context.appColors.primaryTextColor;
          final secondaryTextColor = context.appColors.glassBorder;
          final buttonColor = context.appColors.glassBorder;
          final borderColor = context.appColors.glassBorder;

          return LoadingView(
            isLoading: (state is LoadingProfileState),
            child: SizedBox.expand(
              child: GradientBackground(
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 10.h,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 600.w),
                        child: Form(
                          key: key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(
                                context,
                                textColor,
                                secondaryTextColor,
                                buttonColor,
                                borderColor,
                              ),
                              SizedBox(height: 32.h),
                              _buildFormSection(),
                              SizedBox(height: 24.h),
                              _buildPortfolioImagesSection(
                                context,
                                isDark,
                                textColor,
                              ),
                              SizedBox(height: 48.h),
                              _buildSaveButton(context),
                              SizedBox(height: 100.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color textColor,
    Color secondaryTextColor,
    Color buttonColor,
    Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () =>
              context.read<ProviderBloc>().add(ProviderBackPressedEvent()),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderColor),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 20.r,
            ),
          ),
        ),
        SizedBox(height: 32.h),
        CustomTextWidget(
          text: "PROFESSIONAL PORTFOLIO",
          fontWeight: FontWeight.w900,
          fontSize: 22.sp,
          color: textColor,
          letterSpacing: 1.5,
        ),
        SizedBox(height: 8.h),
        CustomTextWidget(
          text:
              "TELL THE WORLD ABOUT YOUR BUSINESS AND SHOWCASE YOUR BEST WORK.",
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          color: secondaryTextColor,
          letterSpacing: 1.0,
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return SolidContainer(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           CustomTextWidget(
            text: "BUSINESS DETAILS",
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: context.appColors.secondaryColor,
            letterSpacing: 1.5,
          ),
          SizedBox(height: 24.h),
          SolidTextField(
            controller: companyNameController,
            hintText: "What's your business or company name?",
            label: "Company / Business Name",
            prefixIcon: Icons.business_rounded,
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Company name is required" : null,
          ),
          SizedBox(height: 20.h),
          SolidTextField(
            controller: addressController,
            hintText: "Where is your business located?",
            label: "Company Address",
            prefixIcon: Icons.location_on_rounded,
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Address is required" : null,
          ),
          SizedBox(height: 20.h),
          SolidTextField(
            controller: specificationController,
            hintText: "e.g. House Cleaning, Web Development",
            label: "Specialization",
            prefixIcon: Icons.stars_rounded,
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Specialization is required" : null,
          ),
          SizedBox(height: 20.h),
          SolidTextField(
            controller: experienceController,
            hintText: "Years of Experience (e.g. 5)",
            label: "Experience (Years)",
            prefixIcon: Icons.timeline_rounded,
            keyboardType: TextInputType.number,
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Experience is required" : null,
          ),
          SizedBox(height: 20.h),
          SolidTextField(
            controller: skillsController,
            hintText: "e.g. Cleaning, Repair, Cooking (comma separated)",
            label: "Skills",
            prefixIcon: Icons.handyman_rounded,
          ),
          SizedBox(height: 20.h),
          SolidTextField(
            controller: languagesController,
            hintText: "e.g. English, Spanish, French (comma separated)",
            label: "Languages",
            prefixIcon: Icons.translate_rounded,
          ),
          SizedBox(height: 20.h),
          SolidTextField(
            controller: educationController,
            hintText: "e.g. BSc in Computer Science, Certified Plumber",
            label: "Education / Certification",
            prefixIcon: Icons.school_rounded,
          ),
          SizedBox(height: 20.h),
          SolidTextField(
            controller: descriptionController,
            hintText: "Describe your experience and what you offer...",
            label: "Detailed Description",
            prefixIcon: Icons.notes_rounded,
            isMultiLine: true,
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Description is required" : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioImagesSection(
    BuildContext context,
    bool isDark,
    Color textColor,
  ) {
    return SolidContainer(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               CustomTextWidget(
                text: "SHOWCASE IMAGES",
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: context.appColors.secondaryColor,
                letterSpacing: 1.5,
              ),
              IconButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(
                    SelectImagesFromGalleryEvent(),
                  );
                },
                icon: Icon(Icons.add_photo_alternate_rounded, color: textColor),
                tooltip: "Add Images",
              ),
            ],
          ),
          SizedBox(height: 16.h),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final selectedImages = ImagesProfileState.images;
              if (selectedImages == null || selectedImages.isEmpty) {
                return GestureDetector(
                  onTap: () {
                    context.read<ProfileBloc>().add(
                      SelectImagesFromGalleryEvent(),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: context.appColors.cardBackground,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: context.appColors.glassBorder,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: context.appColors.secondaryTextColor,
                          size: 32.r,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Tap to upload work samples",
                          style: TextStyle(
                            color: context.appColors.secondaryTextColor,
                            fontSize: 13.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 120.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: selectedImages.length,
                  separatorBuilder: (c, i) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.file(
                            File(selectedImages[index].path),
                            width: 120.w,
                            height: 120.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14.r,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: context.appColors.secondaryColor.withAlpha(60),
            blurRadius: 20.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (key.currentState!.validate()) {
            if (isSet && aboutID != "") {
              context.read<ProfileBloc>().add(
                DeleteAboutUserEvent(id: aboutID),
              );
            }
            context.read<ProfileBloc>().add(
              AddAboutEvent(
                about: About(
                  name: companyNameController.text,
                  address: addressController.text,
                  specification: specificationController.text,
                  countryCode: countryCode,
                  description: descriptionController.text,
                  experienceYears: int.tryParse(experienceController.text) ?? 0,
                  skills: skillsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                  education: educationController.text,
                  languages: languagesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.appColors.secondaryColor,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 0,
        ),
        child: Text(
          "PUBLISH PORTFOLIO",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
