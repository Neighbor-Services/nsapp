import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/widgets/provider_button_navigation_bar_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/notification/notification_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';

import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';

import '../bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_home_page.dart';
import 'package:nsapp/features/shared/presentation/pages/notifications_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_accepted_request_page.dart';
import 'package:nsapp/features/messages/presentation/pages/my_messages_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_appointment_calendar_page.dart';
class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage> {
  int _currentTab = 1;

  final List<Widget> _pages = const [
    SizedBox.shrink(), // 0: Unused
    ProviderHomePage(key: PageStorageKey('provider_home')), // 1: Home
    NotificationsPage(key: PageStorageKey('provider_notifications')), // 2: Notifications
    ProviderAcceptedRequestPage(key: PageStorageKey('provider_accepted')), // 3: Accepted Requests
    MyMessagesPage(key: PageStorageKey('provider_messages')), // 4: Chat
    ProviderAppointmentCalendarPage(key: PageStorageKey('provider_calendar')), // 5: Calendar
  ];

  @override
  void initState() {
    _currentTab = context.read<ProviderBloc>().currentTab;
    context.read<CommonBloc>().add(GetServicesEvent());
    context.read<NotificationBloc>().add(GetMyNotificationsEvent());
    context.read<MessageBloc>().add(GetMyMessagesEvent());
    super.initState();
    
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is SuccessGetProfileState) {
      if (Helpers.isProvider(profileState.profile.userType)) {
        context.read<SettingsBloc>().add(ToggleDashboardEvent(isProvider: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProviderBloc, ProviderState>(
      listener: (context, state) {
        if (state is ProviderTabChangedState) {
          setState(() {
            _currentTab = state.tabIndex;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: IndexedStack(
            index: _currentTab,
            children: _pages,
          ),
          bottomNavigationBar: const ProviderButtonNavigationBarWidget(),
        );
      },
    );
  }
}


