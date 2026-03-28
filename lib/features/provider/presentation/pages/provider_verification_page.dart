import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import '../../../../core/helpers/helpers.dart';
import 'package:nsapp/core/core.dart';

class ProviderVerificationPage extends StatefulWidget {
  const ProviderVerificationPage({super.key});

  @override
  State<ProviderVerificationPage> createState() =>
      _ProviderVerificationPageState();
}

class _ProviderVerificationPageState extends State<ProviderVerificationPage> {
  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isFront) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(image.path);
        } else {
          _backImage = File(image.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.appColors.glassBorder,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.appColors.primaryTextColor,
              size: 18,
            ),
          ),
        ),
        title: Text(
          "IDENTITY VERIFICATION",
          style: TextStyle(
            color: context.appColors.primaryTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "VERIFY YOUR ACCOUNT",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: context.appColors.primaryTextColor,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "UPLOAD A GOVERNMENT-ISSUED ID OR BUSINESS LICENSE TO RECEIVE YOUR VERIFICATION BADGE AND BUILD TRUST WITH SEEKERS.",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: context.appColors.secondaryTextColor,
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 40),
                _buildUploadSection(
                  title: "ID Front / License",
                  image: _frontImage,
                  onTap: () => _pickImage(true),
                ),
                const SizedBox(height: 24),
                _buildUploadSection(
                  title: "ID Back (Optional)",
                  image: _backImage,
                  onTap: () => _pickImage(false),
                ),
                const SizedBox(height: 60),
                SolidButton(
                  label: "SUBMIT FOR REVIEW",
                  onPressed: _frontImage == null
                      ? null
                      : () {
                          customAlert(
                            context,
                            AlertType.success,
                            "Documents submitted for review",
                          );
                          Get.back();
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadSection({
    required String title,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: context.appColors.primaryTextColor,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: SolidContainer(
            width: size(context).width,
            height: 180,
            padding: EdgeInsets.zero,
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        color: context.appColors.primaryTextColor,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Tap to upload",
                        style: TextStyle(
                          color: context.appColors.primaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
