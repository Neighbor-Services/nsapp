import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/seeker/presentation/pages/providers_by_service_page.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/core/core.dart';

class SeekerAllServicesPage extends StatelessWidget {
  const SeekerAllServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final textColor = context.appColors.primaryTextColor;

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
                        context.read<SeekerBloc>().add(
                          SeekerBackPressedEvent(),
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
                          FontAwesomeIcons.chevronLeft,
                          color: textColor,
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
                            "SERVICE SELECTION",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "FIND THE BEST PROFESSIONALS",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: textColor.withAlpha(150),
                              letterSpacing: 1.0,
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
                              FontAwesomeIcons.magnifyingGlass,
                              size: 64.r,
                              color: textColor.withAlpha(50),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "No services found",
                              style: TextStyle(color: textColor.withAlpha(180)),
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
      FontAwesomeIcons.wrench,
      FontAwesomeIcons.broom,
      FontAwesomeIcons.plug,
      FontAwesomeIcons.wrench,
      FontAwesomeIcons.truck,
      FontAwesomeIcons.toolbox,
    ];

    final icon = icons[index % icons.length];

    return GestureDetector(
      onTap: () {
        context.read<SeekerBloc>().add(
          NavigateSeekerEvent(
            page: 1,
            widget: ProvidersByServicePage(
              serviceId: service.id ?? '',
              serviceName: service.name ?? 'Service',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: context.appColors.glassBorder,
            width: 1.5.r,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -5.r,
              bottom: -5.r,
              child: Icon(
                icon,
                size: 60.r,
                color: context.appColors.primaryColor.withAlpha(20),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: context.appColors.primaryColor,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20.r),
                  ),
                  Text(
                    (service.name ?? "Service").toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.primaryTextColor,
                      letterSpacing: 0.5,
                      height: 1.2,
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



