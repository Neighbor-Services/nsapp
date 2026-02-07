import 'package:flutter/material.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';

import '../../../../core/constants/app_colors.dart';

class SettingsWidget extends StatelessWidget {
  final Widget action;
  final String name;

  const SettingsWidget({super.key, required this.action, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(color: appGreyColor, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [CustomTextWidget(text: name, fontSize: 20), action],
      ),
    );
  }
}
