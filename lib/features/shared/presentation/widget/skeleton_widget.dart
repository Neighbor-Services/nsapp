import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nsapp/core/core.dart';

class SkeletonWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.appColors.glassBorder.withAlpha(120),
      highlightColor: context.appColors.glassBorder.withAlpha(150),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;
  const ListSkeletonLoader({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      padding: EdgeInsets.all(16.r),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            children: [
              SkeletonWidget(width: 50.r, height: 50.r, borderRadius: 25.r),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonWidget(width: 150.w, height: 16.h),
                    SizedBox(height: 8.h),
                    SkeletonWidget(width: 100.w, height: 12.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CardSkeletonLoader extends StatelessWidget {
  const CardSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonWidget(width: double.infinity, height: 200.h, borderRadius: 16.r),
          SizedBox(height: 16.h),
          SkeletonWidget(width: 200.w, height: 24.h),
          SizedBox(height: 8.h),
          SkeletonWidget(width: 150.w, height: 16.h),
        ],
      ),
    );
  }
}

class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SkeletonWidget(width: 120.r, height: 120.r, borderRadius: 60.r),
            SizedBox(height: 24.h),
            SkeletonWidget(width: 200.w, height: 28.h),
            SizedBox(height: 12.h),
            SkeletonWidget(width: 150.w, height: 16.h),
            SizedBox(height: 32.h),
            Column(
              children: List.generate(4, (index) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: SkeletonWidget(width: double.infinity, height: 80.h, borderRadius: 16.r),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class HorizontalSkeletonLoader extends StatelessWidget {
  final double height;
  final double itemWidth;
  
  const HorizontalSkeletonLoader({
    super.key, 
    this.height = 200.0,
    this.itemWidth = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: SkeletonWidget(
              width: itemWidth.w,
              height: height.h,
              borderRadius: 16.r,
            ),
          );
        },
      ),
    );
  }
}


