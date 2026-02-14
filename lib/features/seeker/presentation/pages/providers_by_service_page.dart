import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/profile/presentation/pages/about_page.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

class ProvidersByServicePage extends StatefulWidget {
  final String serviceId;
  final String serviceName;

  const ProvidersByServicePage({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<ProvidersByServicePage> createState() => _ProvidersByServicePageState();
}

class _ProvidersByServicePageState extends State<ProvidersByServicePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  Future<void> _fetchProviders() async {
    setState(() => _isLoading = true);

    // Use the existing search logic with category name filter
    context.read<SeekerBloc>().add(
      SearchProviderEvent(serviceName: widget.serviceName),
    );

    // Listen for state changes
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(150)
        : const Color(0xFF1E1E2E).withAlpha(150);
    final backBtnColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<SeekerBloc>().add(
                          SeekerBackPressedEvent(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: backBtnColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(40)
                                : Colors.black.withAlpha(20),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: textColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.serviceName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Available Providers",
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Providers List
              Expanded(
                child: BlocBuilder<SeekerBloc, SeekerState>(
                  builder: (context, state) {
                    if (state is LoadingSeekerState || _isLoading) {
                      return const Center(child: LoadingWidget());
                    }

                    if (state is SuccessSearchProviderState) {
                      return FutureBuilder<List<Profile>>(
                        future: SuccessSearchProviderState.providers,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: LoadingWidget());
                          }

                          final providers = snapshot.data ?? [];

                          if (providers.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 80,
                                    color: secondaryTextColor.withAlpha(60),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No providers found",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Try searching for a different service",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: secondaryTextColor.withAlpha(100),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: providers.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final profile = providers[index];
                              return _buildProviderCard(context, profile);
                            },
                          );
                        },
                      );
                    }

                    return Center(
                      child: Text(
                        "Start searching for providers",
                        style: TextStyle(
                          fontSize: 16,
                          color: secondaryTextColor,
                        ),
                      ),
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

  Widget _buildProviderCard(BuildContext context, Profile profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(180)
        : const Color(0xFF1E1E2E).withAlpha(150);

    return GestureDetector(
      onTap: () {
        context.read<SeekerBloc>().add(
          SetProviderToReviewEvent(
            provider: profile,
            providerUserId: profile.user!.id!,
          ),
        );
        context.read<ProfileBloc>().add(
          AboutUserEvent(userID: profile.user!.id!),
        );
        context.read<SeekerBloc>().add(
          NavigateSeekerEvent(page: 1, widget: AboutPage()),
        );
      },
      child: SolidContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile Picture
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  (profile.profilePictureUrl != null &&
                      profile.profilePictureUrl!.isNotEmpty)
                  ? Image.network(
                      profile.profilePictureUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) {
                        return Image.asset(
                          logo2Assets,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset(
                      logo2Assets,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 16),
            // Provider Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          profile.firstName ?? "Provider",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (profile.isIdentityVerified == true) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.blue,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getServiceName(profile.service ?? ""),
                    style: TextStyle(color: secondaryTextColor, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: appOrangeColor1, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        double.parse(
                          profile.rating ?? "0.0",
                        ).toStringAsFixed(1),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.location_on,
                        color: secondaryTextColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.city ?? "N/A",
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? Colors.white.withAlpha(100) : Colors.black12,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
