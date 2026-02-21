import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/constants/app_colors.dart';
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
          final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
          final secondaryTextColor = isDark
              ? Colors.white.withAlpha(160)
              : const Color(0xFF1E1E2E).withAlpha(160);
          final buttonColor = isDark
              ? Colors.white.withAlpha(20)
              : Colors.black.withAlpha(10);
          final borderColor = isDark
              ? Colors.white.withAlpha(40)
              : Colors.black.withAlpha(20);

          return LoadingView(
            isLoading: (state is LoadingProfileState),
            child: SizedBox.expand(
              child: GradientBackground(
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
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
                              const SizedBox(height: 32),
                              _buildFormSection(),
                              const SizedBox(height: 24),
                              _buildPortfolioImagesSection(
                                context,
                                isDark,
                                textColor,
                              ),
                              const SizedBox(height: 48),
                              _buildSaveButton(context),
                              const SizedBox(height: 100),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 32),
        CustomTextWidget(
          text: "Professional Portfolio",
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: textColor,
          letterSpacing: -1,
        ),
        const SizedBox(height: 8),
        CustomTextWidget(
          text:
              "Tell the world about your business and showcase your best work.",
          fontSize: 15,
          color: secondaryTextColor,
          height: 1.5,
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return SolidContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomTextWidget(
            text: "BUSINESS DETAILS",
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: appOrangeColor1,
            letterSpacing: 1.5,
          ),
          const SizedBox(height: 24),
          SolidTextField(
            controller: companyNameController,
            hintText: "What's your business or company name?",
            label: "Company / Business Name",
            prefixIcon: Icons.business_rounded,
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Company name is required" : null,
          ),
          const SizedBox(height: 20),
          SolidTextField(
            controller: addressController,
            hintText: "Where is your business located?",
            label: "Company Address",
            prefixIcon: Icons.location_on_rounded,
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Address is required" : null,
          ),
          const SizedBox(height: 20),
          SolidTextField(
            controller: specificationController,
            hintText: "e.g. House Cleaning, Web Development",
            label: "Specialization",
            prefixIcon: Icons.stars_rounded,
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Specialization is required" : null,
          ),
          const SizedBox(height: 20),
          SolidTextField(
            controller: experienceController,
            hintText: "Years of Experience (e.g. 5)",
            label: "Experience (Years)",
            prefixIcon: Icons.timeline_rounded,
            keyboardType: TextInputType.number,
            validator: (val) =>
                (val?.isEmpty ?? true) ? "Experience is required" : null,
          ),
          const SizedBox(height: 20),
          SolidTextField(
            controller: skillsController,
            hintText: "e.g. Cleaning, Repair, Cooking (comma separated)",
            label: "Skills",
            prefixIcon: Icons.handyman_rounded,
          ),
          const SizedBox(height: 20),
          SolidTextField(
            controller: languagesController,
            hintText: "e.g. English, Spanish, French (comma separated)",
            label: "Languages",
            prefixIcon: Icons.translate_rounded,
          ),
          const SizedBox(height: 20),
          SolidTextField(
            controller: educationController,
            hintText: "e.g. BSc in Computer Science, Certified Plumber",
            label: "Education / Certification",
            prefixIcon: Icons.school_rounded,
          ),
          const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomTextWidget(
                text: "SHOWCASE IMAGES",
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: appOrangeColor1,
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
          const SizedBox(height: 16),
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
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.black.withAlpha(5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(20)
                            : Colors.black.withAlpha(10),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: isDark
                              ? Colors.white.withAlpha(60)
                              : Colors.black.withAlpha(40),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap to upload work samples",
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withAlpha(100)
                                : Colors.black.withAlpha(60),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: selectedImages.length,
                  separatorBuilder: (c, i) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(selectedImages[index].path),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
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
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: appOrangeColor1.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 5),
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
          backgroundColor: appOrangeColor1,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: const Text(
          "Publish Portfolio",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
