import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/subscribe_dialog_widget.dart';
import 'package:nsapp/features/provider/presentation/pages/requests_by_service_page.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/core/core.dart';

class ProviderAllServicesPage extends StatelessWidget {
  const ProviderAllServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: GradientBackground(
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
                        context.read<ProviderBloc>().add(
                          ProviderBackPressedEvent(),
                        );
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
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
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
                              fontWeight: FontWeight.w900,
                              color: context.appColors.primaryTextColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "BROWSE ALL AVAILABLE SERVICE CATEGORIES",
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w900,
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
                child: BlocBuilder<SharedBloc, SharedState>(
                  builder: (context, state) {
                    final services = SuccessGetServicesState.services;

                    if (services.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
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

                    return GridView.builder(
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, dynamic service, int index) {
   

    final icons = [
      Icons.build_rounded,
      Icons.cleaning_services_rounded,
      Icons.electrical_services_rounded,
      Icons.plumbing_rounded,
      Icons.local_shipping_rounded,
      Icons.home_repair_service_rounded,
    ];
    final icon = icons[index % icons.length];

    return GestureDetector(
      onTap: () {
        if (ValidUserSubscriptionState.isValid) {
          context.read<ProviderBloc>().add(
            NavigateProviderEvent(
              page: 1,
              widget: RequestsByServicePage(
                serviceId: service.id ?? '',
                serviceName: service.name ?? 'Service',
              ),
            ),
          );
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
              child: Icon(icon, size: 70.r, color: context.appColors.glassBorder),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: context.appColors.primaryColor, size: 24.r),
                  Text(
                    (service.name ?? "Service").toUpperCase(),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
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
    );
  }
}
