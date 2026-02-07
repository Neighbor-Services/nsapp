import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/widgets/seeker_bottom_navigation_bar_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import '../../../messages/presentation/bloc/message_bloc.dart';

class SeekerDashboardPage extends StatefulWidget {
  const SeekerDashboardPage({super.key});

  @override
  State<SeekerDashboardPage> createState() => _SeekerDashboardPageState();
}

class _SeekerDashboardPageState extends State<SeekerDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Fetch initial counts for badges
    context.read<SharedBloc>().add(GetMyNotificationsEvent());
    context.read<MessageBloc>().add(GetMyMessagesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SeekerBloc, SeekerState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: PopScope(
            canPop: (SeekerVisitedPagesState.pages.isEmpty),
            onPopInvokedWithResult: (pop, oo) {
              context.read<SeekerBloc>().add(SeekerBackPressedEvent());
            },
            child: NavigatorSeekerState.widget,
          ),
          bottomNavigationBar: SeekerBottomNavigationBarWidget(),
        );
      },
    );
  }
}
