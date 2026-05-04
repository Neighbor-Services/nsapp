import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';

class MediaChatWidget extends StatelessWidget {
  final TextEditingController messageController;
  const MediaChatWidget({super.key, required this.messageController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: BlocBuilder<MessageBloc, MessageState>(
        builder: (context, state) {
          final imageFile = state is MessageImageState ? state.image : null;
          
          return Container(
            height: size(context).height * 0.50,
            width: size(context).width,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: SizedBox(
                    width: size(context).width,
                    height:
                        (size(context).height * 0.50) - 130.h, // Adjusted height
                    child: (imageFile != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10.r),
                            child: Image.file(
                              File(imageFile.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: SolidTextField(
                    controller: messageController,
                    hintText: 'Type a message...',
                    suffixIcon: IconButton(
                      icon: FaIcon(FontAwesomeIcons.paperPlane, color: Colors.white, size: 20.r),
                      onPressed: () async {
                        if (imageFile == null) return;
                        
                        final profileState = context.read<ProfileBloc>().state;
                        // We need the receiver from the last known state or previous context
                        // In a real scenario, the Bloc should probably handle the send event 
                        // using its internal _targetUserId and _receiverProfile.
                        
                        String? senderId;
                        if (profileState is SuccessGetProfileState) {
                          senderId = profileState.profile.user?.id;
                        }

                        // For receiver, since we are in MediaChatWidget which is likely 
                        // triggered FROM ChatPage, we can't easily get the 'current chat partner' 
                        // from just a random state emission. 
                        // However, the MessageBloc should have it.
                        // I'll use the same pattern as AppointmentChatWidget.
                        
                        final msgBlocState = context.read<MessageBloc>().state;
                        String? receiverId;
                        if (msgBlocState is MessageReceiverState) {
                          receiverId = msgBlocState.profile.user?.id;
                        }

                        if (senderId != null && receiverId != null) {
                          File image = File(imageFile.path);
                          List<int> imageByte = await image.readAsBytes();
                          String decodeImage = base64Encode(imageByte);
                          Message message = Message(
                            image: decodeImage,
                            fileName: imageFile.name,
                            chatRoomId: Helpers.createChatRoom(
                              sender: senderId,
                              receiver: receiverId,
                            ),
                            withImage: true,
                            withImageAndText: messageController.text != "",
                            message: messageController.text.trim(),
                            sender: senderId,
                            receiver: receiverId,
                            calenderDate: DateTime.now(),
                          );
                          context.read<MessageBloc>().add(
                            ChatEvent(message: message),
                          );
                          messageController.text = "";
                          Get.back();
                        } else {
                          customAlert(context, AlertType.error, "User context lost. Please try again.");
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


