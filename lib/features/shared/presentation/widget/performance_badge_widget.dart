import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: _getBadgeColor(context, badge.iconType).withAlpha(30),
          shape: BoxShape.circle,
          border: Border.all(
            color: _getBadgeColor(context, badge.iconType).withAlpha(80),
            width: 1.r,
          ),
        ),
        child: Icon(
          _getBadgeIcon(badge.iconType),
          color: _getBadgeColor(context, badge.iconType),
          size: size.r,
        ),
      ),
    );
  }

  IconData _getBadgeIcon(String? type) {
    switch (type) {
      case 'bolt':
        return FontAwesomeIcons.bolt;
      case 'star':
        return FontAwesomeIcons.star;
      case 'shield':
        return FontAwesomeIcons.userShield;
      case 'workspace_premium':
        return FontAwesomeIcons.crown;
      default:
        return FontAwesomeIcons.medal;
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

