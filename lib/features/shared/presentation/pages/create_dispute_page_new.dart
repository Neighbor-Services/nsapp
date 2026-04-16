import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/core/models/chat.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/core/core.dart';

class CreateDisputePageNew extends StatefulWidget {
  const CreateDisputePageNew({super.key});

  @override
  State<CreateDisputePageNew> createState() => _CreateDisputePageNewState();
}

class _CreateDisputePageNewState extends State<CreateDisputePageNew> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedUserId;
  String? _selectedUserName;

  @override
  void initState() {
    super.initState();
    // Fetch conversations to populate user selection
    context.read<MessageBloc>().add(GetMyMessagesEvent());
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _submitDispute() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text('Please select a user to dispute against'),
            backgroundColor: context.appColors.errorColor,
          ),
        );
        return;
      }

      final dispute = Dispute(
        defendant: _selectedUserId,
        reason: _reasonController.text,
        description: _descriptionController.text,
      );

      context.read<SharedBloc>().add(CreateDisputeEvent(dispute: dispute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.secondaryTextColor;

    return Scaffold(
      
      body: SafeArea(
        child: GradientBackground(
          child: BlocConsumer<SharedBloc, SharedState>(
            listener: (context, state) {
              if (state is SuccessCreateDisputeState) {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text('Dispute raised successfully.'),
                    backgroundColor: context.appColors.successColor,
                  ),
                );
                context.read<SharedBloc>().add(GetMyDisputesEvent());
                Navigator.pop(context);
              } else if (state is FailureCreateDisputeState) {
                ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                    content: Text('Failed to raise dispute. Please try again.'),
                    backgroundColor: context.appColors.errorColor,
                  ),
                );
              }
            },
            builder: (context, state) {
              return ListView(
                
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            margin: EdgeInsets.all(8.r),
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: context.appColors.glassBorder,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              FontAwesomeIcons.chevronLeft,
                              color: textColor,
                              size: 18.r,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          'Raise Dispute'.toUpperCase(),
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          SolidContainer(
                            padding: EdgeInsets.all(20.r),
                            child: Row(
                              children: [
                                Container(
                                  width: 56.w,
                                  height: 56.h,
                                  decoration: BoxDecoration(
                                    color: context.appColors.primaryColor
                                        .withAlpha(30),
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: context.appColors.primaryColor
                                          .withAlpha(50),
                                    ),
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.gavel,
                                    color: context.appColors.primaryColor,
                                    size: 28.r,
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Raise a Dispute',
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Report an issue with a user',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                  
                          // User Selection Section
                          SolidContainer(
                            padding: EdgeInsets.all(20.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Who are you disputing against?',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withAlpha(200),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                GestureDetector(
                                  onTap: () {
                                    _showUserSelectionDialog(
                                        textColor, secondaryTextColor);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16.r),
                                    decoration: BoxDecoration(
                                      color: context.appColors.glassBorder,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: context.appColors.glassBorder,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.user,
                                          color: secondaryTextColor,
                                          size: 20.r,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            _selectedUserName ??
                                                'Select a user',
                                            style: TextStyle(
                                              color: _selectedUserName != null
                                                  ? textColor
                                                  : textColor.withAlpha(100),
                                              fontSize: 15.sp,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          FontAwesomeIcons.chevronRight,
                                          color: secondaryTextColor,
                                          size: 16.r,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                  
                          // Form Section
                          SolidContainer(
                            padding: EdgeInsets.all(20.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dispute Details',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textColor.withAlpha(200),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                SolidTextField(
                                  controller: _reasonController,
                                  hintText: 'Reason for dispute',
                                  prefixIcon: FontAwesomeIcons.triangleExclamation,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a reason';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                SolidTextField(
                                  controller: _descriptionController,
                                  hintText: 'Describe the issue in detail',
                                  // prefixIcon: FontAwesomeIcons.fileLines,
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
                          SizedBox(height: 24.h),
                  
                          // Info Card
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: context.appColors.warningColor.withAlpha(40),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: context.appColors.warningColor.withAlpha(100),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.circleInfo,
                                  color: context.appColors.warningColor.withAlpha(200),
                                  size: 24.r,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'Our team will review your dispute within 24-48 hours',
                                    style: TextStyle(
                                      color: context.appColors.warningColor,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                  
                          // Submit Button
                          SolidButton(
                            label: 'Submit Dispute',
                            isLoading: state is SharedLoadingState,
                            onPressed: _submitDispute,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showUserSelectionDialog(
    Color textColor,
    Color secondaryTextColor,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.appColors.cardBackground,
        title: Text(
          'Select User',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400.h,
          child: FutureBuilder<List<Chat>>(
            future: SuccessGetMyMessagesState.myMessages,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingWidget());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.comment,
                      size: 48.r,
                      color: secondaryTextColor,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No conversations found',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Start a conversation first',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor.withAlpha(150),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                );
              }

              final conversations = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final chat = conversations[index];
                  final user = chat.other;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: context.appColors.cardBackground,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: context.appColors.glassBorder,
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedUserId = user?.user?.id;
                          _selectedUserName = user?.firstName ?? 'Unknown User';
                        });
                        if (_selectedUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Cannot select this user (missing user ID)',
                              ),
                              backgroundColor: context.appColors.errorColor,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(dialogContext);
                      },
                      leading: CircleAvatar(
                        backgroundColor: context.appColors.glassBorder,
                        backgroundImage: (user?.profilePictureUrl != null &&
                                user!.profilePictureUrl!.isNotEmpty)
                            ? NetworkImage(user.profilePictureUrl!)
                            : null,
                        child: (user?.profilePictureUrl == null ||
                                user!.profilePictureUrl!.isEmpty)
                            ? FaIcon(FontAwesomeIcons.user, color: secondaryTextColor)
                            : null,
                      ),
                      title: Text(
                        user?.firstName ?? 'Unknown User',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                      subtitle: user?.service != null
                          ? Text(
                              user!.service!,
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 12.sp,
                              ),
                            )
                          : null,
                      trailing: Icon(
                        FontAwesomeIcons.chevronRight,
                        color: secondaryTextColor,
                        size: 16.r,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: secondaryTextColor)),
          ),
        ],
      ),
    );
  }
}


