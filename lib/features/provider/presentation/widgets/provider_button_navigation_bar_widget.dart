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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black.withAlpha(20);
    final shadowColor = isDark
        ? Colors.black.withAlpha(60)
        : Colors.black.withAlpha(20);

    return BlocBuilder<MessageBloc, MessageState>(
      builder: (context, messageState) {
        return BlocBuilder<SharedBloc, SharedState>(
          builder: (context, sharedState) {
            return BlocConsumer<ProviderBloc, ProviderState>(
              listener: (context, state) {},
              builder: (context, state) {
                return Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavIcon(
                        context: context,
                        icon: Icons.home_rounded,
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
                        icon: Icons.notifications_rounded,
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
                        icon: Icons.chat_bubble_rounded,
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
                        icon: Icons.calendar_month_rounded,
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
    required bool isActive,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark
        ? Colors.white.withAlpha(160)
        : Colors.black.withAlpha(100);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Badge(
          isLabelVisible: badgeCount > 0,
          label: Text(
            badgeCount.toString(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: isActive ? appDeepBlueColor1 : inactiveColor,
              ),
              if (isActive) ...[
                const SizedBox(height: 4),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: appDeepBlueColor1,
                    boxShadow: [
                      BoxShadow(
                        color: appDeepBlueColor1,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [appDeepBlueColor1, Color(0xFF4A90E2)],
          ),
          boxShadow: [
            BoxShadow(
              color: appDeepBlueColor1.withAlpha(100),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            providerJobLogo,
            width: 24,
            height: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
