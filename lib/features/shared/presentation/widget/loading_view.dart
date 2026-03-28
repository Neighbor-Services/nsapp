import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';

class LoadingView extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const LoadingView({super.key, required this.child, required this.isLoading});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          Stack(
            children: [
              Container(
                width: size(context).width,
                height: size(context).height,
                color: Colors.black.withAlpha(40),
              ),
              Center(
                child: Container(
                  height: 140,
                  width: 140,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.appColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.appColors.glassBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: 1.0).animate(controller),
                        child: Image.asset(logo2Assets, width: 60),
                      ),
                      const SizedBox(height: 12),
                      CustomTextWidget(
                        text: "Processing",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.primaryTextColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
