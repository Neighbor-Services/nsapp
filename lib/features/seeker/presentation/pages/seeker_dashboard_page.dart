import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/widgets/seeker_bottom_navigation_bar_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/notification/notification_bloc.dart';
import '../../../messages/presentation/bloc/message_bloc.dart';

class SeekerDashboardPage extends StatefulWidget {
  const SeekerDashboardPage({super.key});

  @override
  State<SeekerDashboardPage> createState() => _SeekerDashboardPageState();
}

class _SeekerDashboardPageState extends State<SeekerDashboardPage> {
  late Widget _currentWidget;

  @override
  void initState() {
    super.initState();
    _currentWidget = context.read<SeekerBloc>().currentWidget;
    // Fetch initial counts for badges
    context.read<NotificationBloc>().add(GetMyNotificationsEvent());
    context.read<MessageBloc>().add(GetMyMessagesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SeekerBloc, SeekerState>(
      listener: (context, state) {
        if (state is NavigatorSeekerState) {
          setState(() {
            _currentWidget = state.widget;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: PopScope(
            canPop: false,
            onPopInvokedWithResult: (pop, oo) {
              context.read<SeekerBloc>().add(SeekerBackPressedEvent());
            },
            child: _currentWidget,
          ),
          bottomNavigationBar: SeekerBottomNavigationBarWidget(),
        );
      },
    );
  }
}


