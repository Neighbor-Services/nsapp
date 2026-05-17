import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/features/authentications/presentation/pages/change_password_page.dart';
import 'package:nsapp/features/authentications/presentation/pages/forget_password_page.dart';
import 'package:nsapp/features/authentications/presentation/pages/login_auth_page.dart';
import 'package:nsapp/features/authentications/presentation/pages/otp_verification_page.dart';
import 'package:nsapp/features/authentications/presentation/pages/register_auth_page.dart';
import 'package:nsapp/features/authentications/presentation/pages/reset_password_page.dart';
import 'package:nsapp/features/authentications/presentation/pages/verify_email_page.dart';
import 'package:nsapp/features/profile/presentation/pages/add_about_page.dart';
import 'package:nsapp/features/profile/presentation/pages/add_profile_auth_page.dart';
import 'package:nsapp/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:nsapp/features/profile/presentation/pages/profile_page.dart';
import 'package:nsapp/features/profile/presentation/pages/pending_verification_page.dart';
import 'package:nsapp/features/provider/presentation/pages/requests_by_service_page.dart';
import 'package:nsapp/features/shared/presentation/pages/biometric_page.dart';
import 'package:nsapp/features/shared/presentation/pages/create_dispute_page_new.dart';
import 'package:nsapp/features/shared/presentation/pages/home_page.dart';
import 'package:nsapp/features/shared/presentation/pages/image_view_page.dart';
import 'package:nsapp/features/shared/presentation/pages/map_direction_page.dart';
import 'package:nsapp/features/shared/presentation/pages/map_location_page.dart';
import 'package:nsapp/features/shared/presentation/pages/settings_page.dart';
import 'package:nsapp/features/shared/presentation/pages/setup_webview_page.dart';
import 'package:nsapp/features/shared/presentation/pages/splash_screen_page.dart';
import 'package:nsapp/features/shared/presentation/pages/no_internet_page.dart';
import 'package:nsapp/features/wallet/presentation/pages/wallet_page.dart';
import 'package:nsapp/features/shared/presentation/pages/notifications_page.dart';
import 'package:nsapp/features/shared/presentation/pages/disputes_list_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_details_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_appointment_list_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/pages/dispute_details_page.dart';
import 'package:nsapp/features/shared/presentation/pages/legal_document_page.dart';
import 'package:nsapp/features/profile/presentation/pages/audit_log_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_appointment_list_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_appointment_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_page.dart';
import 'package:nsapp/features/shared/presentation/pages/report_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_all_services_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_provider_search_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/providers_by_service_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/ai_search_page.dart';
import 'package:nsapp/features/shared/presentation/pages/subscription_page.dart';
import 'package:nsapp/features/messages/presentation/pages/chat_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_live_tracking_page.dart';
import 'package:nsapp/features/shared/presentation/pages/dispute_center_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_accepted_request_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_active_tasks_page.dart';
import 'package:nsapp/features/profile/presentation/pages/about_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_verification_page.dart';
import 'package:nsapp/features/provider/presentation/pages/add_service_package_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_new_request_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_update_request_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_search_request_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_targeted_requests_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_more_requests_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => SplashScreenPage(),
    ),
    GoRoute(
      path: '/no-internet',
      builder: (context, state) => const NoInternetPage(),
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) => OtpVerificationPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginAuthPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegisterAuthPage(),
    ),
    GoRoute(
      path: '/add-profile',
      builder: (context, state) => AddProfileAuthPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => ResetPasswordPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfilePage(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => EditProfilePage(),
    ),
    GoRoute(
      path: '/edit-portfolio',
      builder: (context, state) => AddAboutPage(),
    ),
    GoRoute(
      path: '/pending-verification',
      builder: (context, state) => PendingVerificationPage(),
    ),
    GoRoute(
      path: '/map-location',
      builder: (context, state) => MapLocationPage(),
    ),
    GoRoute(
      path: '/map-direction',
      builder: (context, state) => MapDirectionPage(),
    ),
    GoRoute(
      path: '/image',
      builder: (context, state) => ImageViewPage(),
    ),
    GoRoute(
      path: '/biometric',
      builder: (context, state) => BiometricPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => SettingsPage(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => ChangePasswordMainPage(),
    ),
    GoRoute(
      path: '/stripe-account',
      builder: (context, state) {
        final url = state.extra as String?;
        return SetupWebviewPage(url: url);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => ForgetPasswordPage(),
    ),
    GoRoute(
      path: '/verify',
      builder: (context, state) => VerifyEmailPage(),
    ),
    GoRoute(
      path: '/wallet',
      builder: (context, state) => WalletPage(),
    ),
    GoRoute(
      path: '/dispute',
      builder: (context, state) => const DisputesListPage(),
    ),
    GoRoute(
      path: '/dispute-details',
      builder: (context, state) {
        final dispute = state.extra as Dispute;
        return DisputeDetailsPage(dispute: dispute);
      },
    ),
    GoRoute(
      path: '/create-dispute',
      builder: (context, state) => const CreateDisputePageNew(),
    ),
    GoRoute(
      path: '/app/requests/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        final requestData = state.extra as RequestData?;
        return SeekerRequestDetailsPage(
          requestId: id,
          requestData: requestData,
        );
      },
    ),
    GoRoute(
      path: '/app/provider/requests/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        final requestData = state.extra as RequestData?;
        return ProviderRequestDetailPage(
          requestId: id,
          requestData: requestData,
        );
      },
    ),
    GoRoute(
      path: '/app/appointments',
      builder: (context, state) => const ProviderAppointmentListPage(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(
      path: '/legal',
      builder: (context, state) {
        final docType = state.extra as String?;
        return LegalDocumentPage(docType: docType);
      },
    ),
    GoRoute(
      path: '/audit-logs',
      builder: (context, state) => const AuditLogPage(),
    ),
    GoRoute(
      path: '/seeker-requests',
      builder: (context, state) => const SeekerRequestPage(),
    ),
    GoRoute(
      path: '/seeker-appointments',
      builder: (context, state) => const SeekerAppointmentPage(),
    ),
    GoRoute(
      path: '/seeker-appointment-list',
      builder: (context, state) => const SeekerAppointmentListPage(),
    ),
    GoRoute(
      path: '/report',
      builder: (context, state) => const ReportPage(),
    ),
    GoRoute(
      path: '/all-services',
      builder: (context, state) => const SeekerAllServicesPage(),
    ),
    GoRoute(
      path: '/provider-search',
      builder: (context, state) => const SeekerProviderSearchPage(),
    ),
    GoRoute(
      path: '/providers-by-service',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return ProvidersByServicePage(
          serviceId: args['serviceId'] as String,
          serviceName: args['serviceName'] as String,
        );
      },
    ),
    GoRoute(
      path: '/requests-by-service',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return RequestsByServicePage(
          serviceId: args['serviceId'] as String,
          serviceName: args['serviceName'] as String,
        );
      },
    ),
    GoRoute(
      path: '/ai-search',
      builder: (context, state) => const AISearchPage(),
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) => const SubscriptionPage(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: '/live-tracking',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return SeekerLiveTrackingPage(
          appointmentId: args['appointmentId'],
          jobLocation: args['jobLocation'],
        );
      },
    ),
    GoRoute(
      path: '/dispute-center',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return DisputeCenterPage(
          appointment: args['appointment'],
          currentUser: args['currentUser'],
          otherUser: args['otherUser'],
        );
      },
    ),
    GoRoute(
      path: '/provider-jobs',
      builder: (context, state) => const ProviderAcceptedRequestPage(),
    ),
    GoRoute(
      path: '/provider-tasks',
      builder: (context, state) => const ProviderActiveTasksPage(),
    ),
    GoRoute(
      path: '/portfolio-view',
      builder: (context, state) {
        final profile = state.extra as Profile?;
        return AboutPage(profile: profile ?? Profile());
      },
    ),
    GoRoute(
      path: '/new-request',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return SeekerNewRequestPage(
          targetProviderId: args?['targetProviderId'],
          initialServiceId: args?['initialServiceId'],
          initialServiceName: args?['initialServiceName'],
        );
      },
    ),
    GoRoute(
      path: '/provider-verification',
      builder: (context, state) => const ProviderVerificationPage(),
    ),
    GoRoute(
      path: '/add-service-package',
      builder: (context, state) => const AddServicePackagePage(),
    ),
    GoRoute(
      path: '/edit-request',
      builder: (context, state) => const SeekerUpdateRequestPage(),
    ),
    GoRoute(
      path: '/provider-search-request',
      builder: (context, state) => const ProviderSearchRequestPage(),
    ),
    GoRoute(
      path: '/provider-targeted-requests',
      builder: (context, state) => const ProviderTargetedRequestsPage(),
    ),
    GoRoute(
      path: '/provider-more-requests',
      builder: (context, state) => const ProviderMoreRequestsPage(),
    ),
  ],
);
