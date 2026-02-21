import 'package:flutter/material.dart';
import 'package:google_maps_directions/google_maps_directions.dart' as gmd;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/account_link.dart';
import 'package:nsapp/core/models/customer.dart';
import 'package:nsapp/core/models/favorite.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/request_distance.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:dio/dio.dart';
import '../models/subscription.dart';
import 'package:nsapp/features/shared/presentation/widget/searchable_service_selector.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/services/payment_service.dart';
import 'package:nsapp/core/services/dialog_utils.dart';
import 'package:nsapp/core/services/location_service.dart';
import 'package:nsapp/core/utils/media_utils.dart';
import 'package:nsapp/core/utils/date_utils_helper.dart';

export 'package:nsapp/core/services/payment_service.dart';
export 'package:nsapp/core/services/dialog_utils.dart';
export 'package:nsapp/core/services/location_service.dart';
export 'package:nsapp/core/utils/media_utils.dart';
export 'package:nsapp/core/utils/date_utils_helper.dart';

List<String> specialCharacters = [
  "\"",
  "'",
  "`",
  "@",
  "#",
  "\$",
  "&",
  "|",
  "^",
  "~",
  "!",
  "?",
  ":",
  ";",
  ",",
  ".",
  "=",
  "+",
  "-",
  "*",
  "/",
  "%",
  ">",
  "<",
  ">=",
  "<=",
  "==",
  "!=",
  "&&",
  "||",
  "++",
  "--",
  "<<",
  ">>",
  "??",
  "??=",
  "[",
  "]",
  "{",
  "}",
  "(",
  ")",
];

bool containSpecial(String name) {
  for (int i = 0; i < name.length; i++) {
    if (specialCharacters.contains(name[i])) return true;
  }
  return false;
}

String getServiceName(String id) {
  if (id.isEmpty) return id;
  for (var service in SuccessGetServicesState.services) {
    if (service.id == id) return service.name ?? id;
  }
  return id;
}

List<DropdownMenuItem<String>> servicesDropDown(List<Service> services) {
  List<DropdownMenuItem<String>> dropdowns = [];
  for (var service in services) {
    dropdowns.add(
      DropdownMenuItem(
        value: service.id ?? "",
        child: CustomTextWidget(text: service.name ?? ""),
      ),
    );
  }
  dropdowns.add(
    const DropdownMenuItem(
      value: "Others",
      child: CustomTextWidget(text: "Others"),
    ),
  );
  return dropdowns;
}

Future<void> showServiceSelector({
  required BuildContext context,
  required List<Service> services,
  String? selectedServiceId,
  required Function(String serviceId, String serviceName) onServiceSelected,
  VoidCallback? onOthersSelected,
}) async {
  final Map<String, Category> categoriesMap = {};
  for (var service in services) {
    if (service.categoryId != null &&
        !categoriesMap.containsKey(service.categoryId)) {
      categoriesMap[service.categoryId!] = Category(
        id: service.categoryId,
        name: service.categoryName ?? service.categoryId,
      );
    }
  }
  final List<Category> categories = categoriesMap.values.toList();
  await Get.bottomSheet(
    SearchableServiceSelector(
      services: services,
      categories: categories,
      selectedServiceId: selectedServiceId,
      onServiceSelected: onServiceSelected,
      onOthersSelected: onOthersSelected,
    ),
    isScrollControlled: true,
  );
}

servicesWidget(List<Service> services, BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return services.map((service) {
    if (services.indexOf(service) < 5) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isDark ? Colors.white.withAlpha(20) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withAlpha(10),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: CustomTextWidget(
          text: service.name ?? "",
          color: isDark ? Colors.white : Colors.black87,
        ),
      );
    } else {
      return const SizedBox();
    }
  }).toList();
}

allServicesWidget(List<Service> services, BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return services.map((service) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isDark ? const Color(0xFF2E2E3E) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withAlpha(10),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: CustomTextWidget(
        text: service.name ?? "",
        color: isDark ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }).toList();
}

class Helpers {
  static Future<gmd.DistanceValue> dis({
    required double lat,
    required double lng,
  }) async {
    return LocationService.getDistance(lat: lat, lng: lng);
  }

  static bool isMyFavorite(String userID) {
    for (Favorite user in SuccessGetMyFavoritesNoFutureState.profiles) {
      if (user.favoriteUser!.user!.id == userID) return true;
    }
    return false;
  }

  static Future<DateTime?> selectBirthDate(BuildContext context) async {
    return DateUtilsHelper.selectBirthDate(context);
  }

  static Future<void> selectImageFromGallery() async {
    return MediaUtils.selectImageFromGallery();
  }

  static Future<void> selectImagesFromGallery() async {
    return MediaUtils.selectImagesFromGallery();
  }

  static Future<void> selectImageFromCamera() async {
    return MediaUtils.selectImageFromCamera();
  }

  static Future<bool> getLocation() async {
    final success = await LocationService.getLocation();
    if (success) {
      locController.text = myAddress;
    }
    return success;
  }

  static Future<String> getAddressFromMap(LatLng loc) async {
    return LocationService.getAddressFromMap(loc);
  }

  static String createChatRoom({String? sender, String? receiver}) {
    final ids = [sender, receiver];
    ids.sort();
    return ids.join("_");
  }

  static Future<Profile?> getSeekerProfile(String uid) async {
    final token = await Helpers.getString("token");
    try {
      final response = await dio.get(
        "$baseUrl/accounts/profile/?user=$uid",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        if (response.data["providers"] is List &&
            (response.data["providers"] as List).isNotEmpty) {
          return Profile.fromJson(response.data["providers"][0]);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<double> averageRate(String id, double myRate) async {
    final Profile? profile = await getSeekerProfile(id);
    if (profile == null) return myRate;
    final ratings = profile.ratings;
    if (ratings != null && ratings.isNotEmpty) {
      List rates = List.from(ratings);
      rates.add(myRate);
      double total = 0.0;
      int count = 0;
      for (var rate in rates) {
        if (rate != null) {
          final val = double.tryParse(rate.toString());
          if (val != null) {
            total += val;
            count++;
          }
        }
      }
      return count > 0 ? total / count : myRate;
    }
    return myRate;
  }

  static Future<RequestDistance> getProfile(
    String uid, {
    required double lat,
    required double lng,
  }) async {
    return LocationService.getProfileDistance(uid, lat: lat, lng: lng);
  }

  static Future<String> getToken() async => getString("token");

  static Future<String?> getUserDeviceToken({required String uid}) async {
    try {
      final token = await Helpers.getString("token");
      final response = await dio.get(
        "$baseUrl/profile/user/devicetoken/$uid",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) return response.data["token"];
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> createStripeCustomer() =>
      PaymentService.createStripeCustomer();
  static Future<CustomerData> getCustomer({String? uid}) =>
      PaymentService.getCustomer(uid: uid);
  static Future<void> createCustomer() => PaymentService.createCustomer();
  static Future<void> updateCustomerEphemeral({
    required String ephKey,
    required String ephKeySecret,
  }) async {}

  static Future<bool> saveBool(String key, bool value) async {
    try {
      sharedPreferences = await prefs;
      await sharedPreferences!.setBool(key, value);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveString(String key, String value) async {
    try {
      sharedPreferences = await prefs;
      await sharedPreferences!.setString(key, value);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deletePref(String key) async {
    try {
      sharedPreferences = await prefs;
      await sharedPreferences!.remove(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> getBool(String key) async {
    try {
      sharedPreferences = await prefs;
      return sharedPreferences!.getBool(key) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<String> getString(String key) async {
    try {
      sharedPreferences = await prefs;
      return sharedPreferences!.getString(key) ?? "";
    } catch (e) {
      return "";
    }
  }

  static Future<bool> isAuthenticated() async {
    final token = await getString("token");
    if (token == "") return false;
    try {
      final dio = Dio();
      final response = await dio.get(
        "$baseUrl/accounts/profile/me/",
        options: Options(headers: dioHeaders(token)),
      );
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        await deletePref("token");
      }
      return false;
    }
  }

  static Future<bool> addUserSubscriptionDetails({
    required Subscription sSubscription,
    required String amount,
    required BuildContext context,
  }) async => PaymentService.addUserSubscriptionDetails(
    sSubscription: sSubscription,
    amount: amount,
    context: context,
  );
  static Future<Subscription?> getSubscription({String? uid}) async =>
      PaymentService.getSubscription(uid: uid);
  static Future<Subscription?> getUserSubscriptionDetails() async =>
      PaymentService.getUserSubscriptionDetails();
  static Future<bool> deleteUserSubscriptionDetails() async =>
      PaymentService.deleteUserSubscriptionDetails();
  static Future<bool> userHasTheValidSubscription() async =>
      PaymentService.userHasTheValidSubscription();

  static bool isProvider(String? type) =>
      type?.toUpperCase() == userTypeProvider;
  static bool isSeeker(String? type) => type?.toUpperCase() == userTypeSeeker;
}

void customAlert(BuildContext context, AlertType type, String message) =>
    DialogUtils.showCustomAlert(context, type, message);

class Payment {
  static Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
  }) async => PaymentService.createPaymentIntent(amount: amount);
  static Future<String> createCustomerEphemeral() async =>
      PaymentService.createCustomerEphemeral();
  static Future<void> setupStripeCustomer(BuildContext context) async =>
      PaymentService.setupStripeCustomer(context);
  static Future<void> updateCustomerPaymentMethod(String paymentMethod) async =>
      PaymentService.updateCustomerPaymentMethod(paymentMethod);
  static Future<bool> initStripeCustomer(BuildContext context) async =>
      PaymentService.initStripeCustomer(context);
  static Future<bool> initStripePayment({
    required String amount,
    required BuildContext context,
  }) async =>
      PaymentService.initStripePayment(amount: amount, context: context);
  static Future<bool> makePayment({
    String? amount,
    required BuildContext context,
  }) async => PaymentService.makePayment(amount: amount, context: context);
  static Future<String> getCustomerFromStripe() async =>
      PaymentService.getCustomerFromStripe();
  static Future<bool> createSubscription(
    BuildContext context,
    String planId,
  ) async => PaymentService.createSubscription(context, planId);
  static Future<void> createMontlySubscription(BuildContext context) async =>
      PaymentService.createMonthlySubscription(context);
  static Future<void> createYealySubscription(BuildContext context) async =>
      PaymentService.createYearlySubscription(context);
  static Future<void> confirmPayment(BuildContext context) async {}
  static Future<void> setUpStripeConnectAccount() async =>
      PaymentService.setUpStripeConnectAccount();
  static Future<AccountLink?> createAccountLink() async =>
      PaymentService.createAccountLink();
  static Future<void> payoutUser({
    required BuildContext context,
    required String uid,
    required String amount,
  }) async =>
      PaymentService.payoutUser(context: context, uid: uid, amount: amount);
}
