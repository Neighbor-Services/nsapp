import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/core/core.dart';


class ProviderListItem extends StatelessWidget {
  final Profile profile;
  final VoidCallback onTap;

  const ProviderListItem({
    super.key,
    required this.profile,
    required this.onTap,
  });

  String _getServiceName(String? service) {
    // Basic helper to handle null/empty services
    return service ?? "Service Provider";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(
            200,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child:
                  (profile.profilePictureUrl != null &&
                      profile.profilePictureUrl != "" &&
                      profile.profilePictureUrl != "picture")
                  ? CachedNetworkImage(
                      imageUrl: profile.profilePictureUrl!,
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(width: 80.w, height: 80.h, color: Colors.grey[200]),
                      errorWidget: (context, url, error) => Image.asset(
                        logo2Assets,
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      logo2Assets,
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    text: profile.firstName ?? "Unknown",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: appBlackColor,
                  ),
                  SizedBox(height: 4.h),
                  CustomTextWidget(
                    text: _getServiceName(profile.service),
                    color: appGreyColor,
                    fontSize: 12.sp,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.star, color: context.appColors.secondaryColor, size: 16.r),
                      SizedBox(width: 4.w),
                      CustomTextWidget(
                        text: (double.tryParse(profile.rating ?? "0") ?? 0.0)
                            .toStringAsFixed(1),
                        color: appBlackColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      const Spacer(),
                      if (profile.address != null)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.locationDot,
                                size: 14.r,
                                color: appGreyColor,
                              ),
                              SizedBox(width: 2.w),
                              Flexible(
                                child: Text(
                                  profile.address!,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: appGreyColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
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
}



