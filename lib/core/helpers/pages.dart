import 'package:get/get.dart';
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
import 'package:nsapp/features/shared/presentation/pages/biometric_page.dart';
import 'package:nsapp/features/shared/presentation/pages/create_dispute_page_new.dart';
import 'package:nsapp/features/shared/presentation/pages/home_page.dart';
import 'package:nsapp/features/shared/presentation/pages/image_view_page.dart';
import 'package:nsapp/features/shared/presentation/pages/map_direction_page.dart';
import 'package:nsapp/features/shared/presentation/pages/map_location_page.dart';
import 'package:nsapp/features/shared/presentation/pages/settings_page.dart';
import 'package:nsapp/features/shared/presentation/pages/setup_webview_page.dart';
import 'package:nsapp/features/shared/presentation/pages/splash_screen_page.dart';
import 'package:nsapp/features/wallet/presentation/pages/wallet_page.dart';
import 'package:nsapp/features/shared/presentation/pages/disputes_list_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_details_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_appointment_list_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/pages/dispute_details_page.dart';

List<GetPage<dynamic>> pages = [
  GetPage(name: '/', page: () => SplashScreenPage()),
  GetPage(name: '/otp', page: () => OtpVerificationPage()),
  GetPage(name: '/login', page: () => LoginAuthPage()),
  GetPage(name: '/register', page: () => RegisterAuthPage()),
  GetPage(name: '/add-profile', page: () => AddProfileAuthPage()),
  GetPage(name: '/home', page: () => HomePage()),
  GetPage(name: '/reset-password', page: () => ResetPasswordPage()),
  GetPage(name: '/profile', page: () => ProfilePage()),
  GetPage(name: '/edit-profile', page: () => EditProfilePage()),
  GetPage(name: '/edit-portfolio', page: () => AddAboutPage()),
  GetPage(name: '/map-location', page: () => MapLocationPage()),
  GetPage(name: "/map-direction", page: () => MapDirectionPage()),
  GetPage(
    name: '/image',
    page: () => ImageViewPage(),
    transition: Transition.rightToLeft,
  ),
  GetPage(name: '/biometric', page: () => BiometricPage()),
  GetPage(name: '/settings', page: () => SettingsPage()),
  GetPage(name: '/change-password', page: () => ChangePasswordMainPage()),
  GetPage(name: '/stripe-account', page: () => SetupWebviewPage()),
  GetPage(name: '/forgot-password', page: () => ForgetPasswordPage()),
  GetPage(name: '/verify', page: () => VerifyEmailPage()),
  GetPage(name: '/wallet', page: () => WalletPage()),
  GetPage(name: '/dispute', page: () => const DisputesListPage()),
  GetPage(name: '/dispute-details', page: () => const DisputeDetailsPage()),
  GetPage(name: '/create-dispute', page: () => const CreateDisputePageNew()),
  GetPage(
    name: '/app/requests/:id',
    page: () => const SeekerRequestDetailsPage(),
  ),
  GetPage(
    name: '/app/provider/requests/:id',
    page: () => const ProviderRequestDetailPage(),
  ),
  GetPage(
    name: '/app/appointments',
    page: () => const ProviderAppointmentListPage(),
  ),
];
