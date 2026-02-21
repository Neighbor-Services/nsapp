import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/messages/presentation/widgets/receiver_appointment_chat_widget.dart';
import 'package:nsapp/features/messages/presentation/widgets/receiver_chat_image_widget.dart';
import 'package:nsapp/features/messages/presentation/widgets/receiver_chat_text_widget.dart';
import 'package:nsapp/features/messages/presentation/widgets/sender_appointment_chat_widget.dart';
import 'package:nsapp/features/messages/presentation/widgets/sender_chat_image_widget.dart';
import 'package:nsapp/features/messages/presentation/widgets/sender_chat_text_widget.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/core/constants/urls.dart';

import 'package:nsapp/features/shared/presentation/pages/call_page.dart';
import 'package:nsapp/core/services/consultation_service.dart';
import 'package:nsapp/core/models/chat.dart';
import '../widgets/chat_input_field.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _headerController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    final receiverId = MessageReceiverState.profile.user?.id;
    final senderId = SuccessGetProfileState.profile.user?.id;

    if (receiverId != null) {
      context.read<MessageBloc>().add(GetMessagesEvent(receiver: receiverId));
      if (senderId != null) {
        context.read<MessageBloc>().add(
          ConnectWebSocketEvent(sender: senderId, receiver: receiverId),
        );
      }
    }

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    );
    _headerController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receiver = MessageReceiverState.profile;

    return BlocConsumer<MessageBloc, MessageState>(
      listener: (context, state) {
        if (state is SuccessGetMessageState ||
            state is SuccessSendMessageState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        } else if (state is MessageImageState) {
          if (MessageImageState.image != null) {
            _handleSendImage(MessageImageState.image!);
          }
        }
      },
      builder: (context, state) {
        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, receiver),
                  Expanded(child: _buildChatArea(context, state)),
                  _buildInputArea(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, dynamic receiver) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white.withAlpha(150) : Colors.black54;
    final iconColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black.withAlpha(10);
    final shadowColor = isDark
        ? Colors.black.withAlpha(30)
        : Colors.grey.withAlpha(20);

    return ScaleTransition(
      scale: _headerAnimation,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                if (DashboardState.isProvider) {
                  context.read<ProviderBloc>().add(ProviderBackPressedEvent());
                } else {
                  context.read<SeekerBloc>().add(SeekerBackPressedEvent());
                }
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: iconColor,
              iconSize: 20,
            ),
            _buildAvatar(receiver),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${receiver.firstName} ${receiver.lastName}",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ChatStatusState.isOnline
                              ? Colors.greenAccent
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ChatStatusState.isTyping
                            ? "Typing..."
                            : (ChatStatusState.isOnline ? "Online" : "Offline"),
                        style: TextStyle(color: subtitleColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildHeaderActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(dynamic receiver) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: appOrangeColor1.withAlpha(100), width: 2),
      ),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.withAlpha(30),
        backgroundImage:
            (receiver.profilePictureUrl != null &&
                receiver.profilePictureUrl != "" &&
                receiver.profilePictureUrl != "picture")
            ? NetworkImage(receiver.profilePictureUrl)
            : const AssetImage(logo2Assets) as ImageProvider,
      ),
    );
  }

  Widget _buildHeaderActions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white.withAlpha(200) : Colors.black87;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          Icons.videocam_rounded,
          () => _handleCall(isVideo: true),
          iconColor,
        ),
        _buildIconButton(
          Icons.call_rounded,
          () => _handleCall(isVideo: false),
          iconColor,
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, Color color) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      color: color,
      iconSize: 22,
    );
  }

  Widget _buildChatArea(BuildContext context, MessageState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emptyTextColor = isDark
        ? Colors.white.withAlpha(100)
        : Colors.black54;
    final iconColor = isDark ? Colors.white.withAlpha(30) : Colors.black12;

    if (state is LoadingMessageState) {
      return const LoadingWidget();
    }
    if (state is FailureGetMessageState) {
      return Center(
        child: Text(
          "Failed to load messages",
          style: TextStyle(color: emptyTextColor),
        ),
      );
    }

    return FutureBuilder<List<ChatMessage>>(
      future: SuccessGetMessageState.messages,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LoadingWidget();
        final messages = snapshot.data!;

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 64,
                  color: iconColor,
                ),
                const SizedBox(height: 16),
                Text(
                  "Start a conversation",
                  style: TextStyle(color: emptyTextColor, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final chatMessage = messages[index];
            final isMe =
                chatMessage.message?.sender ==
                SuccessGetProfileState.profile.user?.id;
            return _buildMessageItem(chatMessage, isMe);
          },
        );
      },
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black.withAlpha(10);
    final shadowColor = isDark
        ? Colors.black.withAlpha(30)
        : Colors.grey.withAlpha(20);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ChatInputField(
          controller: _messageController,
          onSend: _handleSendMessage,
          onImagePick: _handleImagePick,
          onSchedule: _handleScheduleAppointment,
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage chatMessage, bool isMe) {
    final message = chatMessage.message;
    if (message == null) return const SizedBox.shrink();

    final bool withImage = message.withImage ?? false;
    final bool withImageAndText = message.withImageAndText ?? false;
    final bool isCalender = message.isCalender ?? false;
    final String contentTxt = message.message ?? "";
    final String mediaUrl = message.mediaUrl ?? "";
    final DateTime createdAt = message.createdAt ?? DateTime.now();
    final String msgId = message.id ?? "";

    if (isMe) {
      if (withImage) {
        return SenderChatImageWidget(
          withText: withImageAndText,
          message: contentTxt,
          imageUrl: mediaUrl,
          dateTime: createdAt,
          onLongPressed: () {},
        );
      } else if (isCalender) {
        return SenderAppointmentChatWidget(
          chatID: msgId,
          startTime: message.calenderStartDate ?? DateTime.now(),
          appointmentDate: message.calenderDate ?? DateTime.now(),
          endTime: message.calenderEndDate ?? DateTime.now(),
          message: contentTxt,
          from: chatMessage.sender?.user?.id ?? message.sender ?? "",
          onLongPressed: () {},
          seekerId: MessageReceiverState.profile.user?.id ?? "",
        );
      } else {
        return SenderChatTextWidget(
          message: contentTxt,
          dateTime: createdAt,
          onLongPressed: () {},
        );
      }
    } else {
      if (withImage) {
        return ReceiverChatImageWidget(
          withText: withImageAndText,
          message: contentTxt,
          imageUrl: mediaUrl,
          dateTime: createdAt,
        );
      } else if (isCalender) {
        return ReceiverAppointmentChatWidget(
          chatID: msgId,
          startTime: message.calenderStartDate ?? DateTime.now(),
          appointmentDate: message.calenderDate ?? DateTime.now(),
          endTime: message.calenderEndDate ?? DateTime.now(),
          message: contentTxt,
          from: chatMessage.receiver?.user?.id ?? message.sender ?? "",
        );
      } else {
        return ReceiverChatTextWidget(message: contentTxt, dateTime: createdAt);
      }
    }
  }

  Future<void> _handleCall({required bool isVideo}) async {
    final senderId = SuccessGetProfileState.profile.user?.id;
    final receiverId = MessageReceiverState.profile.user?.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final snackBarBg = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final snackBarText = isDark ? Colors.white : Colors.black87;

    if (senderId == null || receiverId == null) {
      customAlert(context, AlertType.error, "User information missing");
      return;
    }

    final channelName = Helpers.createChatRoom(
      sender: senderId,
      receiver: receiverId,
    );

    Get.snackbar(
      "Call Initiation",
      "Joining ${isVideo ? 'Video' : 'Audio'} Call...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: snackBarBg,
      colorText: snackBarText,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      mainButton: TextButton(
        onPressed: () => Get.back(),
        child: Text("Dismiss", style: TextStyle(color: snackBarText)),
      ),
    );

    final tokenData = await ConsultationService.getRTCToken(
      channelName: channelName,
    );

    if (tokenData != null && tokenData['token'] != null) {
      Get.to(
        () => CallPage(
          appId: tokenData['app_id'] ?? agoraAppId,
          token: tokenData['token'],
          channelName: channelName,
          uid: DashboardState.isProvider ? 1 : 0,
        ),
      );
    } else {
      customAlert(context, AlertType.error, "Could not initiate call");
    }
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final receiverId = MessageReceiverState.profile.user?.id;
      final senderId = SuccessGetProfileState.profile.user?.id;

      if (receiverId != null && senderId != null) {
        context.read<MessageBloc>().add(
          ChatEvent(
            message: Message(
              message: text,
              sender: senderId,
              receiver: receiverId,
              createdAt: DateTime.now(),
              withImage: false,
              isCalender: false,
            ),
          ),
        );
        _messageController.clear();
      }
    }
  }

  void _handleImagePick() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Send Image",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(Icons.camera_alt_rounded, "Camera", () {
                  Get.back();
                  context.read<MessageBloc>().add(
                    ChooseMessageImageFromCameraEvent(),
                  );
                }, isDark),
                _buildOptionButton(Icons.photo_library_rounded, "Gallery", () {
                  Get.back();
                  context.read<MessageBloc>().add(
                    ChooseMessageImageFromGalleyEvent(),
                  );
                }, isDark),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleSendImage(XFile imageFile) async {
    final receiverId = MessageReceiverState.profile.user?.id;
    final senderId = SuccessGetProfileState.profile.user?.id;

    if (receiverId != null && senderId != null) {
      // Clear the static image state after getting it
      MessageImageState.image = null;

      try {
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        final fileName = imageFile.name;

        context.read<MessageBloc>().add(
          ChatEvent(
            message: Message(
              message: "Sent an image",
              sender: senderId,
              receiver: receiverId,
              createdAt: DateTime.now(),
              withImage: true,
              image: base64Image,
              fileName: fileName,
            ),
          ),
        );
      } catch (e) {
        debugPrint("Error reading image: $e");
      }
    }
  }

  Widget _buildOptionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isDark,
  ) {
    final bgColor = isDark ? Colors.white10 : Colors.black.withAlpha(5);
    final iconColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: iconColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _handleScheduleAppointment() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: sheetColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Schedule Appointment",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPickerRow(
                  Icons.calendar_month_rounded,
                  "Date",
                  DateFormat("EEEE, MMM dd").format(selectedDate),
                  () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setSheetState(() => selectedDate = picked);
                    }
                  },
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildPickerRow(
                  Icons.access_time_rounded,
                  "Start Time",
                  startTime.format(context),
                  () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (picked != null) {
                      setSheetState(() => startTime = picked);
                    }
                  },
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildPickerRow(
                  Icons.access_time_filled_rounded,
                  "End Time",
                  endTime.format(context),
                  () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (picked != null) {
                      setSheetState(() => endTime = picked);
                    }
                  },
                  isDark,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _submitAppointment(selectedDate, startTime, endTime);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appOrangeColor1,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Send Appointment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPickerRow(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
    bool isDark,
  ) {
    final bgColor = isDark ? Colors.white10 : Colors.black.withAlpha(5);
    final textColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: appOrangeColor1, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor.withAlpha(150),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: textColor.withAlpha(100)),
          ],
        ),
      ),
    );
  }

  void _submitAppointment(
    DateTime date,
    TimeOfDay startTime,
    TimeOfDay endTime,
  ) {
    final receiverId = MessageReceiverState.profile.user?.id;
    final senderId = SuccessGetProfileState.profile.user?.id;

    if (receiverId != null && senderId != null) {
      final start = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );
      final end = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );

      context.read<MessageBloc>().add(
        ChatEvent(
          message: Message(
            message: "Suggested Appointment",
            sender: senderId,
            receiver: receiverId,
            createdAt: DateTime.now(),
            withImage: false,
            isCalender: true,
            calenderDate: date,
            calenderStartDate: start,
            calenderEndDate: end,
          ),
        ),
      );
    }
  }
}
