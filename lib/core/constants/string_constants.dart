import 'package:flutter_dotenv/flutter_dotenv.dart';

const String logoAssets = 'assets/images/logo.png';
const String logo2Assets = 'assets/images/logo2.png';
const String googleLogo = 'assets/icons/google_icon.png';
const String providerJobLogo = 'assets/icons/job_provider_icon_1.png';
const String seekerDoctorLogo = "assets/images/job_seeker_1.png";
const String emptyLogo = "assets/images/empty.png";
const String seekerProviderLogo = "assets/images/job_provider_1.png";
const String resetPasswordLogo = "assets/icons/forget_password_icon.png";
const String placesUrl = "";

const String stripeCustomerUrl = "https://api.stripe.com/v1/customers";
const String stripePaymentIntentUrl =
    "https://api.stripe.com/v1/payment_intents";
final String stripePublishableKey = dotenv.env["STRIPE_PUBLISHABLE_KEY"]!;
final String stripeSecretKey = dotenv.env["STRIPE_SECRET_KEY"]!;
const String stripeCurrency = "USD";
final Map<String, String> headers = {
  'Authorization': 'Bearer $stripeSecretKey',
  'Content-Type': 'application/x-www-form-urlencoded',
};
final String mapAPIKey = dotenv.env["GOOGLE_MAP_API"]!;
const String placesAutoCompleteUrl =
    "https://places.googleapis.com/v1/places:autocomplete";

const String placeDetailsUrl = "https://places.googleapis.com/v1/places";

const String userTypeProvider = "PROVIDER";
const String userTypeSeeker = "SEEKER";
