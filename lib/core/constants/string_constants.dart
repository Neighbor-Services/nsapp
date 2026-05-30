import 'package:nsapp/core/config/app_config.dart';

const String logoAssets = 'assets/images/logo2.png';
const String logo2Assets = 'assets/images/logo.png';
const String person = 'assets/images/person.png';
const String googleLogo = 'assets/icons/google_icon.png';
const String providerJobLogo = 'assets/icons/job_provider_icon_1.png';
const String seekerDoctorLogo = "assets/images/job_seeker_1.png";
const String emptyLogo = "assets/images/empty.png";
const String seekerProviderLogo = "assets/images/job_provider_1.png";
const String resetPasswordLogo = "assets/icons/forget_password_icon.png";
const String placesUrl = "";


String get stripePublishableKey => AppConfig.instance.stripePublishableKey;
const String stripeCurrency = "USD";
String get mapAPIKey => AppConfig.instance.googleMapApiKey;
const String placesAutoCompleteUrl =
    "https://places.googleapis.com/v1/places:autocomplete";

const String placeDetailsUrl = "https://places.googleapis.com/v1/places";

const String userTypeProvider = "PROVIDER";
const String userTypeSeeker = "SEEKER";


