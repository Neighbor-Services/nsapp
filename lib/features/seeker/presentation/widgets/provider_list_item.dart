import 'package:flutter/material.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/core/core.dart';


class ProviderListItem extends StatelessWidget {
  final Profile profile;
  final VoidCallback onTap;

  const ProviderListItem({
    super.key,
    required this.profile,
    required this.onTap,
  });

  String _getServiceName(String? service) {
    // Basic helper to handle null/empty services
    return service ?? "Service Provider";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(
            200,
          ), // Semi-transparent for glass effect availability
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  (profile.profilePictureUrl != null &&
                      profile.profilePictureUrl != "" &&
                      profile.profilePictureUrl != "picture")
                  ? Image.network(
                      profile.profilePictureUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, _) => Image.asset(
                        logo2Assets, // Make sure string_constants is imported
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      logo2Assets,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    text: profile.firstName ?? "Unknown",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appBlackColor,
                  ),
                  const SizedBox(height: 4),
                  CustomTextWidget(
                    text: _getServiceName(profile.service),
                    color: appGreyColor,
                    fontSize: 12,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: context.appColors.secondaryColor, size: 16),
                      const SizedBox(width: 4),
                      CustomTextWidget(
                        text: (double.tryParse(profile.rating ?? "0") ?? 0.0)
                            .toStringAsFixed(1),
                        color: appBlackColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      const Spacer(),
                      if (profile.address != null)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: appGreyColor,
                              ),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  profile.address!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: appGreyColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
