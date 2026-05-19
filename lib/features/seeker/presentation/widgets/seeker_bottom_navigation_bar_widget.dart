import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/notification/notification_bloc.dart';
// Removed UI imports since BLoC no longer stores Widgets

class SeekerBottomNavigationBarWidget extends StatelessWidget {
  const SeekerBottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final shadowColor = context.appColors.glassBorder;

    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, messageState) {
        return BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, notificationState) {
            return BlocConsumer<SeekerBloc, SeekerState>(
              listener: (context, state) {},
              builder: (context, snapshot) {
                return SizedBox(
                  height: 95.h,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 70.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          border: Border(top: BorderSide(color: borderColor, width: 1)),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor,
                              blurRadius: 15.r,
                              offset: Offset(0, -4.h), // Top shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildNavIcon(
                                context: context,
                                icon: FontAwesomeIcons.house,
                                isActive: context.read<SeekerBloc>().currentTab == 1,
                                label: "Home",
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.read<SeekerBloc>().add(
                                    ChangeSeekerTabEvent(tabIndex: 1),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: _buildNavIcon(
                                context: context,
                                icon: FontAwesomeIcons.bell,
                                isActive: context.read<SeekerBloc>().currentTab == 2,
                                badgeCount: (notificationState is SuccessGetMyNotificationsState) ? notificationState.unreadCount : 0,
                                label: "Notifications",
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.read<SeekerBloc>().add(
                                    ChangeSeekerTabEvent(tabIndex: 2),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 70.w), // Space for center FAB
                            Expanded(
                              child: _buildNavIcon(
                                context: context,
                                icon: FontAwesomeIcons.comment,
                                isActive: context.read<SeekerBloc>().currentTab == 4,
                                label: "Chat",
                                badgeCount: (messageState is SuccessGetMyMessagesState) ? messageState.unreadMessageCount : 0,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.read<SeekerBloc>().add(
                                    ChangeSeekerTabEvent(tabIndex: 4),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: _buildNavIcon(
                                context: context,
                                icon: FontAwesomeIcons.heart,
                                label: "Favorites",
                                isActive: context.read<SeekerBloc>().currentTab == 5,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.read<SeekerBloc>().add(
                                    ChangeSeekerTabEvent(tabIndex: 5),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: _buildCenterButton(context),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNavIcon({
    required BuildContext context,
    required IconData icon,
    required bool isActive,
    required String label,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final inactiveColor = context.appColors.hintTextColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Badge(
          isLabelVisible: badgeCount > 0,
          label: Text(
            badgeCount.toString(),
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
          ),
          backgroundColor: context.appColors.errorColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26.r,
                color: isActive ? context.appColors.primaryColor : inactiveColor,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? context.appColors.primaryTextColor : inactiveColor,
                  fontSize: 9.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = context.appColors.primaryColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.read<SeekerBloc>().add(
          ChangeSeekerTabEvent(tabIndex: 3),
        );
      },
      child: Container(
        width: 68.r,
        height: 68.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? primary : context.appColors.primaryBackground,
          border: !isDark
              ? Border.all(color: primary.withAlpha(100), width: 1.5.r)
              : null,
          boxShadow: [
            BoxShadow(
              color: primary.withAlpha(isDark ? 80 : 30),
              blurRadius: 15.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.add_rounded,
            size: 38.r,
            color: isDark ? Colors.white : primary,
          ),
        ),
      ),
    );
  }
}


