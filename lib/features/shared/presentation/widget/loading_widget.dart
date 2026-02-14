import 'package:flutter/material.dart';
import 'package:nsapp/core/constants/dimension.dart';
import 'package:nsapp/core/constants/string_constants.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size(context).width,
      height: size(context).height - 330,
      decoration: BoxDecoration(),
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(controller),
            child: Image.asset(logo2Assets, width: 100),
          ),
        ),
      ),
    );
  }
}
