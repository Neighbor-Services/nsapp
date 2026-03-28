import 'package:flutter/material.dart';
import 'package:nsapp/core/models/performance_badge.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/core.dart';


class PerformanceBadgeWidget extends StatelessWidget {
  final PerformanceBadge badge;
  final double size;

  const PerformanceBadgeWidget({
    super.key,
    required this.badge,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        customAlert(
          context,
          AlertType.warning,
          "${badge.name ?? 'Achievement'}\n\n${badge.description ?? ''}",
        );
      },
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _getBadgeColor(context, badge.iconType).withAlpha(30),
          shape: BoxShape.circle,
          border: Border.all(
            color: _getBadgeColor(context, badge.iconType).withAlpha(80),
            width: 1,
          ),
        ),
        child: Icon(
          _getBadgeIcon(badge.iconType),
          color: _getBadgeColor(context, badge.iconType),
          size: size,
        ),
      ),
    );
  }

  IconData _getBadgeIcon(String? type) {
    switch (type) {
      case 'bolt':
        return Icons.bolt_rounded;
      case 'star':
        return Icons.stars_rounded;
      case 'shield':
        return Icons.verified_user_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }

  Color _getBadgeColor(BuildContext context, String? type) {
    switch (type) {
      case 'bolt':
        return Colors.yellowAccent;
      case 'star':
        return Colors.amber;
      case 'shield':
        return context.appColors.successColor;
      case 'workspace_premium':
        return Colors.cyanAccent;
      default:
        return Colors.white70;
    }
  }
}
