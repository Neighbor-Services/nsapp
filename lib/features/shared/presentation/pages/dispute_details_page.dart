import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

class DisputeDetailsPage extends StatelessWidget {
  const DisputeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Dispute dispute = Get.arguments as Dispute;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(150)
        : const Color(0xFF1E1E2E).withAlpha(150);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Dispute Details',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
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
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              SolidContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _getStatusColor(dispute.status).withAlpha(30),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStatusColor(dispute.status).withAlpha(50),
                        ),
                      ),
                      child: Icon(
                        Icons.gavel_rounded,
                        color: _getStatusColor(dispute.status),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dispute.reason,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(dispute.status).withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(dispute.status).withAlpha(50),
                        ),
                      ),
                      child: Text(
                        dispute.status ?? 'OPEN',
                        style: TextStyle(
                          color: _getStatusColor(dispute.status),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Information Section
              _buildSection(
                title: 'Information',
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.calendar_today_rounded,
                      'Date Raised',
                      dispute.createdAt != null
                          ? DateFormat.yMMMMd().add_jm().format(
                              DateTime.parse(dispute.createdAt!),
                            )
                          : 'N/A',
                      isDark,
                      textColor,
                      secondaryTextColor,
                    ),
                    Divider(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withAlpha(20),
                      height: 24,
                    ),
                    _buildInfoRow(
                      Icons.assignment_rounded,
                      'Appointment ID',
                      dispute.appointment ?? 'Global / General',
                      isDark,
                      textColor,
                      secondaryTextColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Description Section
              _buildSection(
                title: 'Description',
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                child: Text(
                  dispute.description,
                  style: TextStyle(
                    color: textColor.withAlpha(200),
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),

              if (dispute.resolutionNotes != null &&
                  dispute.resolutionNotes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                // Resolution Section
                _buildSection(
                  title: 'Resolution Details',
                  color: Colors.green,
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  child: Text(
                    dispute.resolutionNotes!,
                    style: TextStyle(
                      color: textColor.withAlpha(200),
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required Color textColor,
    required Color secondaryTextColor,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color != null ? color.withAlpha(150) : secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SolidContainer(
          padding: const EdgeInsets.all(20),
          backgroundColor: color?.withAlpha(20),
          borderColor: color?.withAlpha(40),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white12 : Colors.black.withAlpha(5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: textColor, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: secondaryTextColor, fontSize: 12),
              ),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
