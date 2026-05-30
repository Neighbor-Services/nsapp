
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_state.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/subscribe_dialog_widget.dart';
import 'package:nsapp/core/core.dart';
import 'package:go_router/go_router.dart';

class ProviderAllServicesPage extends StatefulWidget {
  const ProviderAllServicesPage({super.key});

  @override
  State<ProviderAllServicesPage> createState() => _ProviderAllServicesPageState();
}

class _ProviderAllServicesPageState extends State<ProviderAllServicesPage> {
  bool _isSubscriptionValid = false;

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(CheckUserSubscriptionEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) {
              if (state is ValidUserSubscriptionState) {
                setState(() => _isSubscriptionValid = state.isValid);
              }
            },
          ),
        ],
        child: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          context.pop();
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: context.appColors.cardBackground,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: context.appColors.glassBorder,
                              width: 1.5.r,
                            ),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.chevronLeft,
                            color: context.appColors.primaryTextColor,
                            size: 20.r,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SERVICE CATALOG",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: context.appColors.primaryTextColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "BROWSE ALL AVAILABLE SERVICE CATEGORIES",
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                                color: context.appColors.secondaryTextColor.withAlpha(150),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Services Grid
                Expanded(
                  child: BlocBuilder<CommonBloc, CommonState>(
                    builder: (context, state) {
                      final services = (state is SuccessGetServicesState) 
                          ? state.services 
                          : (context.read<CommonBloc>().state is SuccessGetServicesState 
                              ? (context.read<CommonBloc>().state as SuccessGetServicesState).services 
                              : []);

                      if (services.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.list,
                                size: 64.r,
                                color: Colors.white.withAlpha(50),
                              ),
                              SizedBox(height: 16.h),
                              const Text(
                                "No services available",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<CommonBloc>().add(GetServicesEvent());
                          context.read<ProfileBloc>().add(GetProfileStreamEvent());
                          context.read<ProfileBloc>().add(GetProfileEvent());
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isLargeScreen ? 3 : 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return _buildServiceCard(context, service, index);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, dynamic service, int index) {
    final icons = [
      FontAwesomeIcons.wrench,
      FontAwesomeIcons.broom,
      FontAwesomeIcons.plug,
      FontAwesomeIcons.wrench,
      FontAwesomeIcons.truck,
      FontAwesomeIcons.toolbox,
    ];
    final icon = icons[index % icons.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (_isSubscriptionValid) {
            context.push('/requests-by-service', extra: {
              'serviceId': service.id ?? '',
              'serviceName': service.name ?? 'Service',
            });
          } else {
            showDialog(
              context: context,
              builder: (context) => const SubscribeDialogWidget(),
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: context.appColors.glassBorder,
              width: 1.5.r,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10.r,
                bottom: -10.r,
                child: FaIcon(icon, size: 70.r, color: context.appColors.glassBorder),
              ),
              Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FaIcon(icon, color: context.appColors.primaryColor, size: 24.r),
                    Text(
                      (service.name ?? "Service").toUpperCase(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.primaryTextColor,
                        height: 1.2,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


