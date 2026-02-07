import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import '../../../../core/helpers/helpers.dart';

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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Identity Verification",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Verify Your Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Upload a government-issued ID or business license to receive your verification badge and build trust with seekers.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withAlpha(150),
                    height: 1.5,
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
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: SolidContainer(
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
                        color: Colors.white.withAlpha(150),
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Tap to upload",
                        style: TextStyle(
                          color: Colors.white.withAlpha(120),
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
