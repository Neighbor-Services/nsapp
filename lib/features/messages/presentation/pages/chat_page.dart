import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/core/models/chat.dart';
import 'package:nsapp/core/models/profile.dart';
import '../widgets/chat_input_field.dart';
import 'package:nsapp/core/core.dart';

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
  
  Profile _receiver = Profile();
  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isOnline = false;
  bool _isLoadingOlder = false;
  String? _currentSenderId;

  @override
  void initState() {
    super.initState();
    
    _scrollController.addListener(_onScroll);

    // Get initial receiver from Bloc state
    final messageState = context.read<MessageBloc>().state;
    if (messageState is MessageReceiverState) {
      _receiver = messageState.profile;
    }

    final receiverId = _receiver.user?.id;
    final profileState = context.read<ProfileBloc>().state;
    String? senderId;
    if (profileState is SuccessGetProfileState) {
      _currentSenderId = profileState.profile.user?.id;
    }

    if (receiverId != null) {
      context.read<MessageBloc>().add(GetMessagesEvent(receiver: receiverId));
      if (_currentSenderId != null) {
        context.read<MessageBloc>().add(
          ConnectWebSocketEvent(sender: _currentSenderId!, receiver: receiverId),
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

  void _onScroll() {
    if (_scrollController.position.pixels <= _scrollController.position.minScrollExtent + 100 &&
        !_isLoadingOlder &&
        _messages.isNotEmpty) {
      final firstMsg = _messages.first.message;
      if (firstMsg != null && firstMsg.createdAt != null) {
        setState(() => _isLoadingOlder = true);
        context.read<MessageBloc>().add(GetMessagesEvent(
              receiver: _receiver.user?.id ?? "",
              before: firstMsg.createdAt!.toUtc().toIso8601String(),
            ));
      }
    }
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
    return BlocConsumer<MessageBloc, MessageState>(
      listener: (context, state) {
        if (state is SuccessGetMessageState) {
          final wasLoadingOlder = _isLoadingOlder;
          setState(() {
            _messages = state.messages;
            _isLoadingOlder = false;
          });
          if (!wasLoadingOlder) {
            _scrollToBottom();
          }
        } else if (state is SuccessSendMessageState) {
          _scrollToBottom();
        } else if (state is FailureGetMessageState) {
          setState(() => _isLoadingOlder = false);
        } else if (state is MessageImageState) {
          if (state.image != null) {
            _handleSendImage(state.image!);
          }
        } else if (state is MessageReceiverState) {
          setState(() => _receiver = state.profile);
        } else if (state is ChatStatusState) {
          setState(() {
            _isTyping = state.isTyping;
            _isOnline = state.isOnline;
          });
        }
      },
      builder: (context, state) {
        return GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildHeader(BuildContext context) {
    final bgColor = context.appColors.cardBackground;
    final textColor = context.appColors.primaryTextColor;
    final subtitleColor = context.appColors.secondaryTextColor;
    final iconColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;

    return ScaleTransition(
      scale: _headerAnimation,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                final settingsState = context.read<SettingsBloc>().state;
                if (settingsState.isProvider) {
                  Get.back();
                } else {
                  Get.back();
                }
              },
              icon: const FaIcon(FontAwesomeIcons.chevronLeft),
              color: iconColor,
              iconSize: 20.r,
            ),
            _buildAvatar(_receiver),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _receiver.firstName ?? 'User',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: BoxDecoration(
                          color: _isOnline
                              ? context.appColors.successColor
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _isTyping
                            ? "Typing..."
                            : (_isOnline ? "Online" : "Offline"),
                        style: TextStyle(color: subtitleColor, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Profile receiver) {
    return Container(
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.appColors.secondaryColor.withAlpha(100), width: 2.r),
      ),
      child: CircleAvatar(
        radius: 20.r,
        backgroundColor: Colors.grey.withAlpha(30),
        backgroundImage:
            (receiver.profilePictureUrl != null &&
                receiver.profilePictureUrl != "" &&
                receiver.profilePictureUrl != "picture")
            ? NetworkImage(receiver.profilePictureUrl!)
            : const AssetImage(logo2Assets) as ImageProvider,
      ),
    );
  }

  Widget _buildChatArea(BuildContext context, MessageState state) {
    final emptyTextColor = context.appColors.glassBorder;
    final iconColor = context.appColors.glassBorder;

    if (state is LoadingMessageState && _messages.isEmpty) {
      return const LoadingWidget();
    }
    
    if (state is FailureGetMessageState && _messages.isEmpty) {
      return Center(
        child: Text(
          state.message,
          style: TextStyle(color: emptyTextColor),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.comment,
              size: 64.r,
              color: iconColor,
            ),
            SizedBox(height: 16.h),
            Text(
              "Start a conversation",
              style: TextStyle(color: emptyTextColor, fontSize: 16.sp),
            ),
          ],
        ),
      );
    }

    final profileState = context.read<ProfileBloc>().state;
    String? myId;
    if (profileState is SuccessGetProfileState) {
      myId = profileState.profile.user?.id;
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final chatMessage = _messages[index];
        final isMe = chatMessage.message?.sender == myId;
        return _buildMessageItem(chatMessage, isMe);
      },
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final bgColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final shadowColor = context.appColors.glassBorder;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10.r,
              offset: Offset(0, -4.h),
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
    final String contentTxt = message.message ?? "";
    final String mediaUrl = message.mediaUrl ?? "";
    final DateTime createdAt = message.createdAt ?? DateTime.now();
    final String msgId = message.id ?? "";

    if (isMe) {
      return FadeInRight(
        duration: const Duration(milliseconds: 400),
        child: _buildSenderMessage(withImage, withImageAndText, contentTxt, mediaUrl, createdAt, msgId, message, chatMessage),
      );
    } else {
      return FadeInLeft(
        duration: const Duration(milliseconds: 400),
        child: _buildReceiverMessage(withImage, withImageAndText, contentTxt, mediaUrl, createdAt, msgId, chatMessage, message),
      );
    }
  }

  void _showMessageOptions(Message message) {
    final sheetColor = context.appColors.cardBackground;
    final textColor = context.appColors.primaryTextColor;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.appColors.glassBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            _buildListTile(
              icon: FontAwesomeIcons.copy,
              title: "Copy Text",
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.message ?? ""));
                Get.back();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Message copied to clipboard")),
                );
              },
              color: textColor,
            ),
            if (message.sender == _currentSenderId) ...[
              _buildListTile(
                icon: FontAwesomeIcons.penToSquare,
                title: "Edit Message",
                onTap: () {
                  Get.back();
                  _showEditDialog(message);
                },
                color: textColor,
              ),
              _buildListTile(
                icon: FontAwesomeIcons.trash,
                title: "Delete Message",
                onTap: () {
                  Get.back();
                  _showDeleteConfirmation(message);
                },
                color: Colors.redAccent,
              ),
            ],
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Message message) {
    Get.dialog(
      AlertDialog(
        backgroundColor: context.appColors.cardBackground,
        title: Text("Delete Message", style: TextStyle(color: context.appColors.primaryTextColor)),
        content: Text("Are you sure you want to delete this message? This action cannot be undone.", 
          style: TextStyle(color: context.appColors.secondaryTextColor)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: context.appColors.hintTextColor)),
          ),
          TextButton(
            onPressed: () {
              context.read<MessageBloc>().add(DeleteMessageEvent(message: message));
              Get.back();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Message message) {
    final controller = TextEditingController(text: message.message);
    Get.dialog(
      AlertDialog(
        backgroundColor: context.appColors.cardBackground,
        title: Text("Edit Message", style: TextStyle(color: context.appColors.primaryTextColor)),
        content: TextField(
          controller: controller,
          maxLines: null,
          style: TextStyle(color: context.appColors.primaryTextColor),
          decoration: InputDecoration(
            hintText: "Enter new message...",
            hintStyle: TextStyle(color: context.appColors.hintTextColor),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.appColors.glassBorder)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.appColors.primaryColor)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel", style: TextStyle(color: context.appColors.hintTextColor)),
          ),
          TextButton(
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty && newText != message.message) {
                final updatedMessage = message.copyWith(message: newText);
                context.read<MessageBloc>().add(UpdateMessageEvent(message: updatedMessage));
              }
              Get.back();
            },
            child: Text("Update", style: TextStyle(color: context.appColors.primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap, required Color color}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20.r),
      title: Text(title, style: TextStyle(color: color, fontSize: 16.sp, fontWeight: FontWeight.w400)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }

  Widget _buildSenderMessage(bool withImage, bool withImageAndText, String contentTxt, String mediaUrl, DateTime createdAt, String msgId, Message message, ChatMessage chatMessage) {
    if (withImage) {
      return SenderChatImageWidget(
        withText: withImageAndText,
        message: contentTxt,
        imageUrl: mediaUrl,
        dateTime: createdAt,
        isDelivered: message.isDelivered ?? false,
        isSeen: message.read ?? false,
        onLongPressed: () => _showMessageOptions(message),
      );
    } else if (message.isCalender ?? false) {
      return SenderAppointmentChatWidget(
        chatID: msgId,
        startTime: message.calenderDate ?? DateTime.now(),
        appointmentDate: message.calenderDate ?? DateTime.now(),
        message: contentTxt,
        from: chatMessage.sender?.user?.id ?? message.sender ?? "",
        isDelivered: message.isDelivered ?? false,
        isSeen: message.read ?? false,
        onLongPressed: () => _showMessageOptions(message),
        seekerId: _receiver.user?.id ?? "",
      );
    } else {
      return SenderChatTextWidget(
        message: contentTxt,
        dateTime: createdAt,
        isDelivered: message.isDelivered ?? false,
        isSeen: message.read ?? false,
        onLongPressed: () => _showMessageOptions(message),
      );
    }
  }

  Widget _buildReceiverMessage(bool withImage, bool withImageAndText, String contentTxt, String mediaUrl, DateTime createdAt, String msgId, ChatMessage chatMessage, Message message) {
    if (withImage) {
      return ReceiverChatImageWidget(
        withText: withImageAndText,
        message: contentTxt,
        imageUrl: mediaUrl,
        dateTime: createdAt,
      );
    } else if (message.isCalender ?? false) {
      return ReceiverAppointmentChatWidget(
        chatID: msgId,
        startTime: message.calenderDate ?? DateTime.now(),
        appointmentDate: message.calenderDate ?? DateTime.now(),
        message: contentTxt,
        from: chatMessage.receiver?.user?.id ?? message.sender ?? "",
      );
    } else {
      return ReceiverChatTextWidget(
        message: contentTxt, 
        dateTime: createdAt,
        onLongPressed: () {
          Clipboard.setData(ClipboardData(text: contentTxt));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Message copied to clipboard")),
          );
        },
      );
    }
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final receiverId = _receiver.user?.id;
      final profileState = context.read<ProfileBloc>().state;
      String? senderId;
      if (profileState is SuccessGetProfileState) {
        senderId = profileState.profile.user?.id;
      }

      if (receiverId != null && senderId != null) {
        context.read<MessageBloc>().add(
          ChatEvent(
            message: Message(
              chatRoomId: Helpers.createChatRoom(
                sender: senderId,
                receiver: receiverId,
              ),
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
    final sheetColor = context.appColors.cardBackground;
    final textColor = context.appColors.primaryTextColor;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Send Image",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(FontAwesomeIcons.camera, "Camera", () {
                  Get.back();
                  context.read<MessageBloc>().add(
                    ChooseMessageImageFromCameraEvent(),
                  );
                }, isDark),
                _buildOptionButton(FontAwesomeIcons.images, "Gallery", () {
                  Get.back();
                  context.read<MessageBloc>().add(
                    ChooseMessageImageFromGalleyEvent(),
                  );
                }, isDark),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _handleSendImage(XFile imageFile) async {
    final receiverId = _receiver.user?.id;
    final profileState = context.read<ProfileBloc>().state;
    String? senderId;
    if (profileState is SuccessGetProfileState) {
      senderId = profileState.profile.user?.id;
    }

    if (receiverId != null && senderId != null) {
      try {
        final bytes = await imageFile.readAsBytes();
        final base64Image = base64Encode(bytes);
        final fileName = imageFile.name;

        context.read<MessageBloc>().add(
          ChatEvent(
            message: Message(
              chatRoomId: Helpers.createChatRoom(
                sender: senderId,
                receiver: receiverId,
              ),
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
    final bgColor = context.appColors.glassBorder;
    final iconColor = context.appColors.primaryTextColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 30.r),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(color: iconColor, fontWeight: FontWeight.w400, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  void _handleScheduleAppointment() {
    final sheetColor = context.appColors.cardBackground;
    final textColor = context.appColors.primaryTextColor;

    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: sheetColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Schedule Appointment",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 24.h),
                _buildPickerRow(
                  FontAwesomeIcons.calendar,
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
                ),
                SizedBox(height: 16.h),
                _buildPickerRow(
                  FontAwesomeIcons.clock,
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
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _submitAppointment(selectedDate, startTime);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.secondaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      "Send Appointment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
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
  ) {
    final bgColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.appColors.secondaryColor, size: 24.r),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor.withAlpha(150),
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            FaIcon(FontAwesomeIcons.chevronRight, color: textColor.withAlpha(100)),
          ],
        ),
      ),
    );
  }

  void _submitAppointment(
    DateTime date,
    TimeOfDay startTime,
  ) {
    final receiverId = _receiver.user?.id;
    final profileState = context.read<ProfileBloc>().state;
    String? senderId;
    if (profileState is SuccessGetProfileState) {
      senderId = profileState.profile.user?.id;
    }

    if (receiverId != null && senderId != null) {
      final start = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );

      context.read<MessageBloc>().add(
        ChatEvent(
          message: Message(
            chatRoomId: Helpers.createChatRoom(
              sender: senderId,
              receiver: receiverId,
            ),
            message: "Suggested Appointment",
            sender: senderId,
            receiver: receiverId,
            createdAt: DateTime.now(),
            withImage: false,
            isCalender: true,
            calenderDate: start,
          ),
        ),
      );
    }
  }
}


