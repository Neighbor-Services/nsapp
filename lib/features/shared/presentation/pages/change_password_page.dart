import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/core/core.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController emailTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;

    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is SuccessResetPasswordAuthenticationState) {
            customAlert(
              context,
              AlertType.success,
              "Password change email is sent to ${emailTextController.text.trim()}",
            );
          }
          if (state is FailureResetPasswordAuthenticationState) {
            customAlert(
              context,
              AlertType.error,
              "Unable to send email to ${emailTextController.text.trim()}",
            );
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is LoadingAuthenticationState),
            child: GradientBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: context.appColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.appColors.glassBorder,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: textColor,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "CHANGE PASSWORD",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Image.asset(
                              resetPasswordLogo,
                              width: 200,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 32),

                            SolidContainer(
                              padding: EdgeInsets.all(24),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "RESET PASSWORD",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Please enter the email you registered your Neighbor Service account with to change your password",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: secondaryTextColor,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    SolidTextField(
                                      controller: emailTextController,
                                      hintText: "Enter your email",
                                      label: "Email Address",
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return "Email field is required";
                                        } else if (!val.isEmail) {
                                          return "Email is invalid";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 32),
                                    SolidButton(
                                      label: "CHANGE PASSWORD",
                                      allCaps: true,
                                      onPressed: () {
                                        if (emailTextController.text.trim() !=
                                            SuccessGetProfileState
                                                .profile
                                                .user!
                                                .email) {
                                          customAlert(
                                            context,
                                            AlertType.error,
                                            "Please use email you registered the account with",
                                          );
                                          return;
                                        }
                                        if (formKey.currentState!.validate()) {
                                          // Note: The original code had this commented out,
                                          // but I'm keeping the structure ready for when it's needed.
                                          /*
                                          context.read<AuthenticationBloc>().add(
                                            ResetPasswordAuthenticationEvent(
                                              password: emailTextController.text.trim(),
                                            ),
                                          );
                                          */
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
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
