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
          const SnackBar(
            content: Text('Please select a user to dispute against'),
            backgroundColor: Colors.red,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(150)
        : const Color(0xFF1E1E2E).withAlpha(150);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Raise Dispute',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(50)
                  : Colors.black.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
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
                const SnackBar(
                  content: Text('Dispute raised successfully.'),
                  backgroundColor: Colors.green,
                ),
              );
              context.read<SharedBloc>().add(GetMyDisputesEvent());
              Navigator.pop(context);
            } else if (state is FailureCreateDisputeState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to raise dispute. Please try again.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    SolidContainer(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.orange.withAlpha(30),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.orange.withAlpha(50),
                              ),
                            ),
                            child: const Icon(
                              Icons.gavel_rounded,
                              color: Colors.orange,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Raise a Dispute',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Report an issue with a user',
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

                    // User Selection Section
                    SolidContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Who are you disputing against?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor.withAlpha(200),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              _showUserSelectionDialog(
                                isDark,
                                textColor,
                                secondaryTextColor,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withAlpha(10)
                                    : Colors.black.withAlpha(5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withAlpha(30)
                                      : Colors.black.withAlpha(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline_rounded,
                                    color: secondaryTextColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedUserName ?? 'Select a user',
                                      style: TextStyle(
                                        color: _selectedUserName != null
                                            ? textColor
                                            : textColor.withAlpha(100),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: secondaryTextColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Section
                    SolidContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispute Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor.withAlpha(200),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SolidTextField(
                            controller: _reasonController,
                            hintText: 'Reason for dispute',
                            prefixIcon: Icons.warning_amber_rounded,
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
                            hintText: 'Describe the issue in detail',
                            prefixIcon: Icons.description_outlined,
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
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.blue.withAlpha(200),
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
                      label: 'Submit Dispute',
                      isLoading: state is SharedLoadingState,
                      onPressed: _submitDispute,
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

  void _showUserSelectionDialog(
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? const Color(0xFF1E1E2E).withAlpha(240)
            : Colors.white.withAlpha(245),
        title: Text(
          'Select User',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
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
                      Icons.chat_bubble_outline_rounded,
                      size: 48,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No conversations found',
                      style: TextStyle(color: secondaryTextColor, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a conversation first',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor.withAlpha(150),
                        fontSize: 12,
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
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.black.withAlpha(5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(30)
                            : Colors.black.withAlpha(10),
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
                            const SnackBar(
                              content: Text(
                                'Cannot select this user (missing user ID)',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        Navigator.pop(dialogContext);
                      },
                      leading: CircleAvatar(
                        backgroundColor: isDark
                            ? Colors.white10
                            : Colors.black12,
                        backgroundImage:
                            (user?.profilePictureUrl != null &&
                                user!.profilePictureUrl!.isNotEmpty)
                            ? NetworkImage(user.profilePictureUrl!)
                            : null,
                        child:
                            (user?.profilePictureUrl == null ||
                                user!.profilePictureUrl!.isEmpty)
                            ? Icon(Icons.person, color: secondaryTextColor)
                            : null,
                      ),
                      title: Text(
                        user?.firstName ?? 'Unknown User',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: user?.service != null
                          ? Text(
                              user!.service!,
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: secondaryTextColor,
                        size: 16,
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
