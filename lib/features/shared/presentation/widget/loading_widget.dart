import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  final int count;
  const LoadingWidget({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.appColors.secondaryColor.withAlpha(30),
      highlightColor: context.appColors.secondaryColor.withAlpha(60),
      child: Container(
        padding: EdgeInsets.all(16.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(count, (index) => Padding(
            padding: EdgeInsets.only(bottom: index == count - 1 ? 0 : 16.h),
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
                    mainAxisSize: MainAxisSize.min,
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


