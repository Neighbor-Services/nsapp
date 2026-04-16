import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/messages/presentation/pages/my_messages_page.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_accepted_request_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_appointment_calendar_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_home_page.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/pages/notifications_page.dart';

class ProviderButtonNavigationBarWidget extends StatelessWidget {
  const ProviderButtonNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;

    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, messageState) {
        return BlocBuilder<SharedBloc, SharedState>(
          builder: (context, sharedState) {
            return BlocConsumer<ProviderBloc, ProviderState>(
              listener: (context, state) {},
              builder: (context, state) {
                return Container(
                  height: 72.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border(
                      top: BorderSide(
                        color: borderColor,
                        width: 1.5.r,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavIcon(
                        context: context,
                        icon: FontAwesomeIcons.house,
                        label: 'Home',
                        isActive: NavigatorProviderState.page == 1,
                        onTap: () {
                          context.read<ProviderBloc>().add(
                            NavigateProviderEvent(
                              page: 1,
                              widget: ProviderHomePage(),
                            ),
                          );
                        },
                      ),
                      _buildNavIcon(
                        context: context,
                        icon: FontAwesomeIcons.bell,
                        label: 'Notifications',
                        isActive: NavigatorProviderState.page == 2,
                        badgeCount: SuccessGetMyNotificationsState.unreadCount,
                        onTap: () {
                          context.read<ProviderBloc>().add(
                            NavigateProviderEvent(
                              page: 2,
                              widget: NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      _buildCenterButton(context),
                      _buildNavIcon(
                        context: context,
                        icon: FontAwesomeIcons.comment,
                        label: 'Chat',
                        isActive: NavigatorProviderState.page == 4,
                        badgeCount:
                            SuccessGetMyMessagesState.unreadMessageCount,
                        onTap: () {
                          context.read<ProviderBloc>().add(
                            NavigateProviderEvent(
                              page: 4,
                              widget: MyMessagesPage(),
                            ),
                          );
                        },
                      ),
                      _buildNavIcon(
                        context: context,
                        icon: FontAwesomeIcons.calendar,
                        label: 'Appointments',
                        isActive: NavigatorProviderState.page == 5,
                        onTap: () {
                          context.read<ProviderBloc>().add(
                            NavigateProviderEvent(
                              page: 5,
                              widget: ProviderAppointmentCalendarPage(),
                            ),
                          );
                        },
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
    required String label,
    required bool isActive,
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
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
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
                Text(label, style: TextStyle(color: isActive ? context.appColors.primaryTextColor : inactiveColor, fontSize: 9.sp)),
             
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ProviderBloc>().add(
          NavigateProviderEvent(page: 3, widget: ProviderAcceptedRequestPage()),
        );
      },
      child: Container(
        width: 52.r,
        height: 52.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.appColors.primaryColor,
          border: Border.all(
            color: Colors.white24,
            width: 2.r,
          ),
          boxShadow: [
            BoxShadow(
              color: context.appColors.primaryColor.withAlpha(80),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            FontAwesomeIcons.briefcase,
            size: 26.r,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}


