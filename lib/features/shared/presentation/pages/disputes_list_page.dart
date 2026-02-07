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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(150)
        : const Color(0xFF1E1E2E).withAlpha(150);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'My Disputes',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            if (DashboardState.isProvider) {
              context.read<ProviderBloc>().add(ProviderBackPressedEvent());
            } else {
              context.read<SeekerBloc>().add(SeekerBackPressedEvent());
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(50)
                  : Colors.black.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 18,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Get.toNamed('/create-dispute');
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withAlpha(100)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, color: Colors.orange, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'New',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: GradientBackground(
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
                      isDark,
                      textColor,
                      secondaryTextColor,
                    );
            }

            if (SuccessGetMyDisputesState.disputes.isNotEmpty) {
              return Column(
                children: [
                  _buildDisputesList(
                    SuccessGetMyDisputesState.disputes,
                    isDark,
                    textColor,
                    secondaryTextColor,
                  ),
                ],
              );
            }

            return _buildEmptyState(textColor, secondaryTextColor);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color secondaryTextColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: SolidContainer(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withAlpha(50)),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Disputes',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t raised any disputes yet',
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryTextColor, fontSize: 14),
              ),
              const SizedBox(height: 24),
              SolidButton(
                label: 'Raise a Dispute',
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
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
      itemCount: disputes.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final dispute = disputes[index];
        final statusColor = _getStatusColor(dispute.status);

        return Container(
          margin: EdgeInsets.only(bottom: 16, top: (index == 0) ? 70 : 0),
          child: GestureDetector(
            onTap: () => Get.toNamed('/dispute-details', arguments: dispute),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SolidContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: statusColor.withAlpha(40),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                dispute.status ?? 'OPEN',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: secondaryTextColor.withAlpha(80),
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dispute.reason,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
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
                          color: secondaryTextColor.withAlpha(120),
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
                            color: secondaryTextColor.withAlpha(120),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.orange.withAlpha(200),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'OPEN':
        return Colors.orange;
      case 'UNDER_REVIEW':
        return Colors.blue;
      case 'RESOLVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
