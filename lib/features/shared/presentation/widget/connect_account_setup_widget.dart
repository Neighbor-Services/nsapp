import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/core/core.dart';

class ConnectAccountSetupWidget extends StatelessWidget {
  const ConnectAccountSetupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final subtitleColor = context.appColors.secondaryTextColor;
    final infoBgColor = context.appColors.glassBorder;
    final infoBorderColor = context.appColors.glassBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Payment Setup",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "To receive payments safely, you need to connect your payout account.",
          style: TextStyle(fontSize: 16, color: subtitleColor),
        ),
        const SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: infoBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: infoBorderColor),
          ),
          child: Row(
            children: [
               Icon(Icons.info_outline, color: context.appColors.infoColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "You'll be redirected to a secure page to complete setup.",
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.glassBorder,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SolidButton(
          label: "CONTINUE TO SETUP",
          onPressed: () {
            context.read<SharedBloc>().add(CreateConnectAccountEvent());
          },
        ),
      ],
    );
  }
}
