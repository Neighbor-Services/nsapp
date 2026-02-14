import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/request_accept.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/messages/presentation/pages/chat_page.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/subscribe_dialog_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import '../../../shared/presentation/bloc/shared_bloc.dart';
import '../../../shared/presentation/widget/loading_widget.dart';

class ProviderRequestDetailPage extends StatefulWidget {
  const ProviderRequestDetailPage({super.key});

  @override
  State<ProviderRequestDetailPage> createState() =>
      _ProviderRequestDetailPageState();
}

class _ProviderRequestDetailPageState extends State<ProviderRequestDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<ProviderBloc>().add(
      IsRequestAcceptedEvent(
        id: RequestDetailState.requestData.request?.id ?? "",
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final request = RequestDetailState.requestData.request;
    final user = RequestDetailState.requestData.user;

    if (request == null || user == null) {
      return const Scaffold(body: Center(child: Text("Request not found")));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: BlocConsumer<ProviderBloc, ProviderState>(
        listener: (context, state) {
          if (state is SuccessRequestAcceptState) {
            customAlert(context, AlertType.success, "Request Accepted");
            setState(() {});
            context.read<ProviderBloc>().add(
              IsRequestAcceptedEvent(id: request.id ?? ""),
            );
          }
          if (state is SuccessRequestCancelState) {
            customAlert(context, AlertType.success, "Request Canceled");
            setState(() {});
            context.read<ProviderBloc>().add(
              IsRequestAcceptedEvent(id: request.id ?? ""),
            );
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is LoadingProviderState),
            child: GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 32 : 16,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.read<ProviderBloc>().add(
                                      ProviderBackPressedEvent(),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withAlpha(25)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withAlpha(40)
                                            : Colors.black.withAlpha(10),
                                        width: 1,
                                      ),
                                      boxShadow: isDark
                                          ? null
                                          : [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  5,
                                                ),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Request Details",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    context.read<MessageBloc>().add(
                                      SetMessageReceiverEvent(profile: user),
                                    );
                                    context.read<ProviderBloc>().add(
                                      NavigateProviderEvent(
                                        page: 4,
                                        widget: const ChatPage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: appDeepBlueColor1.withAlpha(40),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: appDeepBlueColor1.withAlpha(80),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),

                            // Image Card
                            _buildImageCard(request, isDark),
                            const SizedBox(height: 24),

                            // User Info Card
                            _buildUserInfoCard(user, request, isDark),
                            const SizedBox(height: 20),

                            // Request Details Card
                            _buildRequestDetailsCard(request, isDark),
                            const SizedBox(height: 32),

                            // Action Button
                            _buildActionButton(context, request, isDark),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCard(dynamic request, bool isDark) {
    bool hasImage = request.withImage ?? false;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(30)
              : Colors.black.withAlpha(5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            SizedBox(
              height: 280,
              width: double.infinity,
              child: hasImage
                  ? GestureDetector(
                      onTap: () {
                        context.read<SharedBloc>().add(
                          SetViewImageEvent(url: request.imageUrl ?? ""),
                        );
                        Get.toNamed("/image");
                      },
                      child: Hero(
                        tag: 'request_image_${request.id}',
                        child: Image.network(
                          request.imageUrl ?? "",
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.white.withAlpha(10),
                              child: const Center(child: LoadingWidget()),
                            );
                          },
                          errorBuilder: (context, _, __) => Container(
                            color: Colors.white.withAlpha(10),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.white24,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Image.asset(logoAssets, fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withAlpha(180), Colors.transparent],
                  ),
                ),
              ),
            ),
            if (!hasImage)
              const Center(
                child: Text(
                  "NO IMAGE PROVIDED",
                  style: TextStyle(
                    color: Colors.white24,
                    letterSpacing: 2,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(dynamic user, dynamic request, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(20) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(30)
              : Colors.black.withAlpha(10),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(40), width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.black.withAlpha(5),
              backgroundImage:
                  (user.profilePictureUrl != null &&
                      user.profilePictureUrl != "")
                  ? NetworkImage(user.profilePictureUrl!)
                  : const AssetImage(logo2Assets) as ImageProvider,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user.firstName ?? "User",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    _buildStatusBadge(
                      request.status ??
                          (request.done == true ? "DONE" : "OPEN"),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orangeAccent.withAlpha(50),
                        ),
                      ),
                      child: Text(
                        request.service?.name ?? "Service",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat(
                        "MMM dd, yyyy",
                      ).format(request.createdAt ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withAlpha(120)
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetailsCard(dynamic request, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(15) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(25)
              : Colors.black.withAlpha(10),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Colors.blueAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "REQUEST SUMMARY",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark
                      ? Colors.white.withAlpha(160)
                      : Colors.black54.withAlpha(180),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            request.title ?? "Service Request",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            request.description ?? "",
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDark ? Colors.white.withAlpha(180) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    dynamic request,
    bool isDark,
  ) {
    final isAccepted = IsRequestAcceptedState.accepted;

    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isAccepted ? Colors.redAccent : appDeepBlueColor1)
                .withAlpha(isDark ? 80 : 30),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => isAccepted
            ? _cancelRequest(context, request)
            : _acceptRequest(context, request),
        style: ElevatedButton.styleFrom(
          backgroundColor: isAccepted ? Colors.redAccent : appDeepBlueColor1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAccepted ? Icons.close_rounded : Icons.check_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              isAccepted ? "Cancel Interest" : "Accept & Propose",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _acceptRequest(BuildContext context, dynamic request) {
    if (ValidUserSubscriptionState.isValid) {
      context.read<ProviderBloc>().add(
        RequestAcceptEvent(
          requestAccept: RequestAccept(
            serviceRequestId: request.id ?? "",
            uid: SuccessGetProfileState.profile.user?.id ?? "",
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => const SubscribeDialogWidget(),
      );
    }
  }

  void _cancelRequest(BuildContext context, dynamic request) {
    context.read<ProviderBloc>().add(
      CancelRequestAcceptEvent(
        requestAccept: RequestAccept(
          serviceRequestId: request.id ?? "",
          uid: SuccessGetProfileState.profile.user?.id ?? "",
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status.toUpperCase()) {
      case 'DONE':
        color = Colors.blueAccent;
        icon = Icons.verified_rounded;
        break;
      case 'IN_PROGRESS':
        color = Colors.orangeAccent;
        icon = Icons.timelapse_rounded;
        break;
      case 'CANCELLED':
        color = Colors.redAccent;
        icon = Icons.cancel_rounded;
        break;
      default:
        color = Colors.greenAccent;
        icon = Icons.new_releases_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
