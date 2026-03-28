import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/core/core.dart';

class DisputesListPage extends StatefulWidget {
  const DisputesListPage({super.key});

  @override
  State<DisputesListPage> createState() => _DisputesListPageState();
}

class _DisputesListPageState extends State<DisputesListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SharedBloc>().add(GetMyDisputesEvent()); // Uncommented
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.hintTextColor;

    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                height: 60,
                width: size(context).width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (DashboardState.isProvider) {
                          context.read<ProviderBloc>().add(
                            ProviderBackPressedEvent(),
                          );
                        } else {
                          context.read<SeekerBloc>().add(
                            SeekerBackPressedEvent(),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.appColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.appColors.glassBorder,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: textColor,
                          size: 18,
                        ),
                      ),
                    ),
                    Text(
                      'MY DISPUTES',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/create-dispute');
                      },
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                         
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SharedBloc, SharedState>(
                builder: (context, state) {
                  if (state is SharedLoadingState) {
                    return const Center(child: LoadingWidget());
                  }

                  if (state is SuccessGetMyDisputesState) {
                    final disputes = SuccessGetMyDisputesState.disputes;
                    return disputes.isEmpty
                        ? _buildEmptyState(textColor, secondaryTextColor)
                        : _buildDisputesList(
                            disputes,

                            textColor,
                            secondaryTextColor,
                          );
                  }

                  if (SuccessGetMyDisputesState.disputes.isNotEmpty) {
                    return _buildDisputesList(
                      SuccessGetMyDisputesState.disputes,

                      textColor,
                      secondaryTextColor,
                    );
                  }

                  return _buildEmptyState(textColor, secondaryTextColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color secondaryTextColor) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: SolidContainer(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: context.appColors.warningColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.appColors.warningColor.withAlpha(50),
                  ),
                ),
                child: Icon(
                  Icons.gavel_rounded,
                  color: context.appColors.warningColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'NO DISPUTES',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'YOU HAVEN\'T RAISED ANY DISPUTES YET',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),
              SolidButton(
                label: 'RAISE A DISPUTE',
                allCaps: true,
                onPressed: () {
                  Get.toNamed('/create-dispute');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisputesList(
    List<Dispute> disputes,

    Color textColor,
    Color secondaryTextColor,
  ) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
      itemCount: disputes.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final dispute = disputes[index];

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () => Get.toNamed('/dispute-details', arguments: dispute),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SolidContainer(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.primaryColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: context.appColors.primaryColor.withAlpha(40),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: context.appColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (dispute.status ?? 'OPEN').toUpperCase(),
                                style: TextStyle(
                                  color: context.appColors.primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                       
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: secondaryTextColor,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dispute.reason.toUpperCase(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dispute.description,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: secondaryTextColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dispute.createdAt != null
                              ? DateFormat.yMMMd().format(
                                  DateTime.parse(dispute.createdAt!),
                                )
                              : 'Recent',
                          style: TextStyle(
                            color: context.appColors.hintTextColor,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'VIEW DETAILS',
                          style: TextStyle(
                            color: context.appColors.warningColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}
