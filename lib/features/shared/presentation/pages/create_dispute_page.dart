import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/core/core.dart';

class CreateDisputePage extends StatefulWidget {
  final String appointmentId;
  final String providerName;
  final String? defendantId;

  const CreateDisputePage({
    super.key,
    required this.appointmentId,
    required this.providerName,
    this.defendantId,
  });

  @override
  State<CreateDisputePage> createState() => _CreateDisputePageState();
}

class _CreateDisputePageState extends State<CreateDisputePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitDispute() {
    if (_formKey.currentState!.validate()) {
      final dispute = Dispute(
        appointment: widget.appointmentId,
        defendant: widget.defendantId,
        reason: _reasonController.text,
        description: _descriptionController.text,
      );

      context.read<SharedBloc>().add(CreateDisputeEvent(dispute: dispute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'RAISE DISPUTE',
          style: TextStyle(
            color: textColor, 
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.appColors.glassBorder),
            ),
            child: Icon(
              FontAwesomeIcons.chevronLeft,
              color: textColor,
              size: 18,
            ),
          ),
        ),
      ),
      body: GradientBackground(
        child: BlocConsumer<SharedBloc, SharedState>(
          listener: (context, state) {
            if (state is SuccessCreateDisputeState) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text('Dispute raised successfully.'),
                  backgroundColor: context.appColors.successColor,
                ),
              );
              Navigator.pop(context);
            } else if (state is FailureCreateDisputeState) {
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                  content: Text('Failed to raise dispute.'),
                  backgroundColor: context.appColors.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 100, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    SolidContainer(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: context.appColors.warningColor.withAlpha(30),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.appColors.warningColor.withAlpha(50),
                              ),
                            ),
                            child:  Icon(
                              FontAwesomeIcons.gavel,
                              color: context.appColors.warningColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'RAISE A DISPUTE',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.providerName.isNotEmpty
                                      ? 'Appointment with ${widget.providerName}'
                                      : 'General Dispute',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Section
                    SolidContainer(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DISPUTE DETAILS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SolidTextField(
                            controller: _reasonController,
                            label: 'REASON FOR DISPUTE',
                            hintText: 'Enter reason',
                            allCapsLabel: true,
                            prefixIcon: FontAwesomeIcons.triangleExclamation,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a reason';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          SolidTextField(
                            controller: _descriptionController,
                            label: 'DESCRIPTION',
                            hintText: 'Describe the issue in detail',
                            allCapsLabel: true,
                            prefixIcon: FontAwesomeIcons.fileLines,
                            isMultiLine: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please describe the issue';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Card
                    SolidContainer(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.circleInfo,
                            color: context.appColors.infoColor.withAlpha(200),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Our team will review your dispute within 24-48 hours',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SolidButton(
                      label: 'SUBMIT DISPUTE',
                      allCaps: true,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _submitDispute();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


