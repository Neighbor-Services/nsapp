import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.appColors.secondaryColor.withAlpha(30),
      highlightColor: context.appColors.secondaryColor.withAlpha(60),
      child: Container(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: List.generate(3, (index) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Row(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 150.w,
                        height: 10.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}


