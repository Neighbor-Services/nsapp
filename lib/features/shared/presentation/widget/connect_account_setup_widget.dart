import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';

class ConnectAccountSetupWidget extends StatelessWidget {
  const ConnectAccountSetupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white.withAlpha(200) : Colors.black54;
    final infoBgColor = isDark
        ? Colors.blue.withAlpha(20)
        : Colors.blue.withAlpha(10);
    final infoBorderColor = isDark
        ? Colors.blue.withAlpha(50)
        : Colors.blue.withAlpha(30);

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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: infoBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: infoBorderColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "You'll be redirected to a secure page to complete setup.",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withAlpha(180)
                        : Colors.black.withAlpha(150),
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
