import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/core.dart';

class SenderChatImageWidget extends StatelessWidget {
  final String message;
  final DateTime dateTime;
  final bool withText;
  final String imageUrl;
  final VoidCallback onLongPressed;

  const SenderChatImageWidget({
    super.key,
    required this.message,
    required this.dateTime,
    required this.withText,
    required this.imageUrl,
    required this.onLongPressed,
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

    final timestampColor = context.appColors.secondaryTextColor;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12.h,
        top: 4.h,
        right: 8.w,
        left: 40.w,
      ),
      child: Align(
        child: GestureDetector(
          onLongPress: onLongPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: context.appColors.cardBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(6.r),
                  ),
                  border: Border.all(
                    color: context.appColors.glassBorder,
                    width: 1.r,
                  ),
                 
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
                                height: 250.h,
                                decoration: BoxDecoration(
                                  color: context.appColors.cardBackground,
                                  image: DecorationImage(
                                    image: AssetImage(logo2Assets),
                                    fit: BoxFit.cover,
                                    opacity: 0.1,
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                    color: context.appColors.primaryColor,
                                    strokeWidth: 2.r,
                                  ),
                                ),
                              ),
                          errorWidget: (context, url, error) => Container(
                            height: 150.h,
                            width: double.infinity,
                            color: context.appColors.cardBackground,
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 40.r,
                              color: context.appColors.primaryTextColor,
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
                            color: context.appColors.primaryTextColor,
                            fontSize: 15.sp,
                            height: 1.4,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 4.w),
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
      ),
    );
  }
}
