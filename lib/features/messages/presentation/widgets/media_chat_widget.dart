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
          return Container(
            height: size(context).height * 0.50,
            width: size(context).width,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: SizedBox(
                    width: size(context).width,
                    height:
                        (size(context).height * 0.50) - 130, // Adjusted height
                    child: (MessageImageState.image != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(MessageImageState.image!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : SizedBox(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SolidTextField(
                    controller: messageController,
                    hintText: 'Type a message...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () async {
                        File image = File(MessageImageState.image!.path);
                        List<int> imageByte = await image.readAsBytes();
                        String decodeImage = base64Encode(imageByte);
                        Message message = Message(
                          image: decodeImage,
                          fileName: MessageImageState.image!.name,
                          chatRoomId: Helpers.createChatRoom(
                            sender: SuccessGetProfileState.profile.user!.id!,
                            receiver: MessageReceiverState.profile.user!.id!,
                          ),
                          withImage: true,
                          withImageAndText: messageController.text != "",
                          message: messageController.text.trim(),
                          sender: SuccessGetProfileState.profile.user!.id!,
                          receiver: MessageReceiverState.profile.user!.id!,
                          calenderDate: DateTime.now(),
                          calenderEndDate: DateTime.now(),
                          calenderStartDate: DateTime.now(),
                        );
                        context.read<MessageBloc>().add(
                          ChatEvent(message: message),
                        );
                        messageController.text = "";
                        Get.back();
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
