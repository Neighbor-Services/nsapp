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
      padding: EdgeInsets.only(
        bottom: 12.h,
        top: 4.h,
        left: 8.w,
        right: 40.w,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                  bottomLeft: Radius.circular(6.r),
                ),
                border: Border.all(color: borderColor, width: 1.r),
               
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
                      borderRadius: BorderRadius.circular(18.r),
                      child: CachedNetworkImage(
                        imageUrl: finalUrl,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Container(
                              width: double.infinity,
                              height: 250.h,
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
                          height: 150.h,
                          width: double.infinity,
                          color: errorWidgetColor,
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40.r,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (withText)
                    Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 12.h, 8.w, 4.h),
                      child: SelectableText(
                        message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15.sp,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.h, left: 4.w),
              child: Text(
                DateFormat("HH:mm").format(dateTime.toLocal()),
                style: TextStyle(
                  color: timestampColor,
                  fontSize: 10.sp,
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
