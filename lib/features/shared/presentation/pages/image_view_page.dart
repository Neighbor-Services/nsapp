import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/constants/dimension.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/core/core.dart';

class ImageViewPage extends StatefulWidget {
  const ImageViewPage({super.key});

  @override
  State<ImageViewPage> createState() => _ImageViewPageState();
}

class _ImageViewPageState extends State<ImageViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<SharedBloc, SharedState>(
        builder: (context, state) {
          return Stack(
            children: [
              GradientBackground(
                // Consistent background
                child: SizedBox(
                  width: size(context).width,
                  height: size(context).height,
                  child: InteractiveViewer(
                    panEnabled: true,
                    boundaryMargin: EdgeInsets.all(20.r),
                    minScale: 0.5,
                    maxScale: 5,
                    child: CachedNetworkImage(
                      imageUrl: ViewImageState.url,
                      fit: BoxFit.contain,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                              color: Colors.white,
                            ),
                          ),
                      errorWidget: (context, url, error) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 100.r,
                            color: Colors.white.withAlpha(100),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            "Could not load image",
                            style: TextStyle(
                              color: Colors.white.withAlpha(150),
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Glass Close Button
              Positioned(
                top: 40.h,
                left: 20.w,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withAlpha(30)),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24.r,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
