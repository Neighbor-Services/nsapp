import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/widgets/provider_button_navigation_bar_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_home_page.dart';

import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';

import '../bloc/provider_bloc.dart';

class ProviderDashboardPage extends StatefulWidget {
  const ProviderDashboardPage({super.key});

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage> {
  Widget _currentWidget = const ProviderHomePage();
  final bool _canPop = true;

  @override
  void initState() {
    context.read<SharedBloc>().add(GetServicesEvent());
    context.read<SharedBloc>().add(GetMyNotificationsEvent());
    context.read<MessageBloc>().add(GetMyMessagesEvent());
    super.initState();
    
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is SuccessGetProfileState) {
      if (Helpers.isProvider(profileState.profile.userType)) {
        context.read<SharedBloc>().add(SharedBlocReloadEvent("provider"));
        context.read<SharedBloc>().add(ToggleDashboardEvent(isProvider: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProviderBloc, ProviderState>(
      listener: (context, state) {
        if (state is NavigatorProviderState) {
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
            canPop: _canPop,
            onPopInvokedWithResult: (pop, os) {
              if (!pop) {
                context.read<ProviderBloc>().add(ProviderBackPressedEvent());
              }
            },
            child: _currentWidget,
          ),
          bottomNavigationBar: const ProviderButtonNavigationBarWidget(),
        );
      },
    );
  }
}


