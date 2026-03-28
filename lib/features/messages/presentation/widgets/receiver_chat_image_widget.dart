import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/core/constants/urls.dart';

class ReceiverChatImageWidget extends StatelessWidget {
  final String message;
  final DateTime dateTime;
  final bool withText;
  final String imageUrl;

  const ReceiverChatImageWidget({
    super.key,
    required this.message,
    required this.dateTime,
    required this.withText,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    String finalUrl = imageUrl;
    if (finalUrl.startsWith('/')) {
      finalUrl = "$domaineUrl$finalUrl";
    } else if (finalUrl.startsWith('http://') &&
        domaineUrl.startsWith('https://')) {
      finalUrl = finalUrl.replaceFirst('http://', 'https://');
    }

    final bubbleColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;
    final timestampColor = context.appColors.secondaryTextColor;
    final placeholderColor = context.appColors.hintTextColor;
    final errorWidgetColor = context.appColors.hintTextColor;
    final iconColor = context.appColors.primaryTextColor;
    final progressColor = context.appColors.primaryTextColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 12, top: 4, left: 8, right: 40),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(6),
                ),
                border: Border.all(color: borderColor, width: 1),
               
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<SharedBloc>().add(
                        SetViewImageEvent(url: finalUrl),
                      );
                      Get.toNamed("/image");
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl: finalUrl,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Container(
                              width: double.infinity,
                              height: 250,
                              decoration: BoxDecoration(
                                color: placeholderColor,
                                image: DecorationImage(
                                  image: AssetImage(logo2Assets),
                                  fit: BoxFit.cover,
                                  opacity: 0.1,
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                  color: progressColor,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        errorWidget: (context, url, error) => Container(
                          height: 150,
                          width: double.infinity,
                          color: errorWidgetColor,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (withText)
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 12, 8, 4),
                      child: SelectableText(
                        message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text(
                DateFormat("HH:mm").format(dateTime.toLocal()),
                style: TextStyle(
                  color: timestampColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
