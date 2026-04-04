import 'package:flutter/material.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/core/core.dart';


class SettingsWidget extends StatelessWidget {
  final Widget action;
  final String name;

  const SettingsWidget({super.key, required this.action, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        color: Theme.of(context).cardColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(text: name, fontSize: 20.sp),
          action,
        ],
      ),
    );
  }
}
