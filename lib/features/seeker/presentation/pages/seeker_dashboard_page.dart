import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/widgets/seeker_bottom_navigation_bar_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/notification/notification_bloc.dart';
import '../../../messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_home_page.dart';
import 'package:nsapp/features/shared/presentation/pages/notifications_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_new_request_page.dart';
import 'package:nsapp/features/messages/presentation/pages/my_messages_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_favorite_page.dart';

class SeekerDashboardPage extends StatefulWidget {
  const SeekerDashboardPage({super.key});

  @override
  State<SeekerDashboardPage> createState() => _SeekerDashboardPageState();
}

class _SeekerDashboardPageState extends State<SeekerDashboardPage> {
  int _currentTab = 1;

  final List<Widget> _pages = const [
    SizedBox.shrink(), // 0: Unused
    SeekerHomePage(), // 1: Home
    NotificationsPage(), // 2: Notifications
    SeekerNewRequestPage(), // 3: FAB/New Request
    MyMessagesPage(), // 4: Chat
    SeekerFavoritePage(), // 5: Favorites
  ];

  @override
  void initState() {
    super.initState();
    _currentTab = context.read<SeekerBloc>().currentTab;
    // Fetch initial counts for badges
    context.read<NotificationBloc>().add(GetMyNotificationsEvent());
    context.read<MessageBloc>().add(GetMyMessagesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SeekerBloc, SeekerState>(
      listener: (context, state) {
        if (state is SeekerTabChangedState) {
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
          bottomNavigationBar: SeekerBottomNavigationBarWidget(),
        );
      },
    );
  }
}


