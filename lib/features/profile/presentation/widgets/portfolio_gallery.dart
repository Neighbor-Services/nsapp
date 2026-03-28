import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/portfolio_item.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/core/core.dart';

class PortfolioGallery extends StatelessWidget {
  final Profile profile;
  final bool isProvider;
  final VoidCallback? onAddImage;

  const PortfolioGallery({
    super.key,
    required this.profile,
    this.isProvider = false,
    this.onAddImage,
  });

  @override
  Widget build(BuildContext context) {
    List<PortfolioItem> items = profile.portfolioItems ?? [];
    final titleColor = context.appColors.primaryTextColor;
    final emptyIconColor = context.appColors.glassBorder;
    final emptyTextColor = context.appColors.secondaryTextColor;

    if (items.isEmpty && !isProvider) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.collections_rounded, color: titleColor, size: 20),
                const SizedBox(width: 12),
                CustomTextWidget(
                  text: "Portfolio",
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: titleColor,
                  letterSpacing: 0.5,
                ),
              ],
            ),
            if (isProvider)
              GestureDetector(
                onTap: onAddImage,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.secondaryColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.appColors.secondaryColor.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_a_photo_rounded,
                        color: context.appColors.secondaryColor,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Add",
                        style: TextStyle(
                          color: context.appColors.secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (items.isEmpty && isProvider)
          SolidContainer(
            padding: EdgeInsets.all(32),
            width: double.infinity,
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: emptyIconColor,
                  size: 48,
                ),
                const SizedBox(height: 16),
                CustomTextWidget(
                  text: "Add photos to showcase your work!",
                  color: emptyTextColor,
                  fontSize: 14,
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (c, i) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => _showItemDetails(context, item),
                  child: Container(
                    width: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(60),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: item.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.white.withAlpha(20),
                                highlightColor: Colors.white.withAlpha(40),
                                child: Container(
                                  color: Colors.white.withAlpha(20),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Dark Gradient Overlay at the bottom
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withAlpha(150),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        if (item.tags != null && item.tags!.isNotEmpty)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(100),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withAlpha(40),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                       Icon(
                                        Icons.auto_awesome,
                                        size: 12,
                                        color: context.appColors.infoColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        item.tags!.first.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (item.description != null)
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Text(
                              item.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showItemDetails(BuildContext context, PortfolioItem item) {
    final sheetBg = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final shadowColor = context.appColors.glassBorder;
    final handleColor = context.appColors.glassBorder;
    final descriptionColor = context.appColors.glassBorder;
    final descriptionBg = context.appColors.glassBorder;
    final descriptionBorder = context.appColors.glassBorder;
    final labelColor = context.appColors.secondaryTextColor;

    Get.bottomSheet(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: borderColor, width: 1.5)),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(150),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withAlpha(40),
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (item.tags != null && item.tags!.isNotEmpty) ...[
                   Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: context.appColors.infoColor,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      CustomTextWidget(
                        text: "AI ANALYSIS TAGS",
                        color: context.appColors.infoColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: item.tags!
                        .map(
                          (tag) => ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.infoColor.withAlpha(30),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: context.appColors.infoColor.withAlpha(80),
                                  ),
                                ),
                                child: Text(
                                  "#$tag".toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                ],
                if (item.description != null) ...[
                  Row(
                    children: [
                      Icon(Icons.notes_rounded, color: labelColor, size: 16),
                      const SizedBox(width: 8),
                      CustomTextWidget(
                        text: "AI DESCRIPTION",
                        color: labelColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: descriptionBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: descriptionBorder),
                    ),
                    child: Text(
                      item.description!,
                      style: TextStyle(
                        color: descriptionColor,
                        fontSize: 15,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      barrierColor: Colors.black.withAlpha(180),
    );
  }
}
