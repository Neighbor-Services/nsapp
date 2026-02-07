import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/customer.dart';
import 'package:nsapp/core/models/account_link.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/core/models/subscription.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';

class PaymentService {
  static Future<String> _getToken() async {
    final token = await Helpers.getString("token");
    return token;
  }

  static Future<void> createStripeCustomer() async {
    try {
      CustomerData customerModel = await getCustomer(
        uid: SuccessGetProfileState.profile.user!.id,
      );
      if (customerModel.customer == null) {
        await createCustomer();
        await createCustomerEphemeral();
      }
    } catch (e) {
      debugPrint("Create Stripe Customer Exception: ${e.toString()}");
    }
  }

  static Future<CustomerData> getCustomer({String? uid}) async {
    try {
      final String token = await _getToken();
      if (token.isEmpty) return CustomerData();
      final response = await dio.get(
        "$basePaymentUrl/customer/user/",
        data: json.encode({"user_id": uid}),
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        if (response.data is Map<String, dynamic>) {
          return CustomerData.fromJson(response.data);
        }
      }
      return CustomerData();
    } catch (e) {
      debugPrint(e.toString());
      return CustomerData();
    }
  }

  static Future<void> createCustomer() async {
    try {
      final String token = await _getToken();
      if (token.isEmpty) return;
      await dio.post(
        "$basePaymentUrl/customer/create/",
        options: Options(headers: dioHeaders(token)),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<String> createCustomerEphemeral() async {
    try {
      final String token = await _getToken();
      if (token.isEmpty) return "";
      await dio.patch(
        "$basePaymentUrl/customer/ephmeral/",
        options: Options(headers: dioHeaders(token)),
      );
      return "";
    } catch (e) {
      return "";
    }
  }

  // DEPRECATED: Use initStripePayment which calls backend
  static Future<Map<String, dynamic>> createPaymentIntent({
    required String amount,
  }) async {
    return {};
  }

  static Future<void> setupStripeCustomer(BuildContext context) async {
    try {
      final init = await initStripeCustomer(context);
      if (init) {
        final customer = await Stripe.instance.presentCustomerSheet();

        if (customer != null && customer.paymentMethod != null) {
          await updateCustomerPaymentMethod(customer.paymentMethod!.id);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> updateCustomerPaymentMethod(String paymentMethod) async {
    try {
      final String token = await _getToken();
      await dio.patch(
        "$basePaymentUrl/customer/paymentmethod/update/",
        options: Options(headers: dioHeaders(token)),
        data: json.encode({"id": paymentMethod}),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<bool> initStripeCustomer(BuildContext context) async {
    try {
      await createCustomerEphemeral();
      CustomerData customerModel = await getCustomer(
        uid: SuccessGetProfileState.profile.user!.id,
      );

      await Stripe.instance.initCustomerSheet(
        customerSheetInitParams: CustomerSheetInitParams(
          customerEphemeralKeySecret: customerModel.customer!.ephemeralSecret!,
          customerId: customerModel.customer!.stripeCustomerId!,
          merchantDisplayName: "Neighbor Services",
          allowsRemovalOfLastSavedPaymentMethod: true,
          applePayEnabled: true,
          googlePayEnabled: true,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Theme.of(context).scaffoldBackgroundColor,
              primaryText: Theme.of(context).iconTheme.color,
              secondaryText: Theme.of(context).iconTheme.color,
              componentText: Theme.of(context).iconTheme.color,
              placeholderText: Theme.of(context).iconTheme.color,
              componentBorder: Theme.of(context).iconTheme.color,
              componentBackground: Theme.of(context).scaffoldBackgroundColor,
              componentDivider: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> initStripePayment({
    required String amount,
    required BuildContext context,
  }) async {
    try {
      final String token = await _getToken();
      if (token.isEmpty) return false;

      // 1. Call Backend to get PaymentSheet parameters
      // Backend: CustomerViewSet.payment_sheet
      final response = await dio.post(
        "$basePaymentUrl/customer/payment-sheet/",
        data: json.encode({"amount": amount}),
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode != 200) {
        debugPrint("Backend Payment Sheet Error: ${response.data}");
        return false;
      }

      final data = response.data;

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customerId: data['customer'],
          paymentIntentClientSecret: data['paymentIntent'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          merchantDisplayName: "Neighbor Services",
          style: ThemeModeState.themeMode,
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'US'),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: "US",
            currencyCode: "USD",
            testEnv: true,
          ),
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Theme.of(context).scaffoldBackgroundColor,
              primaryText: Theme.of(context).iconTheme.color,
              secondaryText: Theme.of(context).iconTheme.color,
              componentText: Theme.of(context).iconTheme.color,
              placeholderText: Theme.of(context).iconTheme.color,
              componentBorder: Theme.of(context).iconTheme.color,
              componentBackground: Theme.of(context).scaffoldBackgroundColor,
              componentDivider: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      );

      return true;
    } catch (e) {
      debugPrint("Init Stripe Payment Exception: $e");
      return false;
    }
  }

  static Future<bool> fundAppointment({
    required String appointmentId,
    required String amount,
    required BuildContext context,
  }) async {
    try {
      final String token = await _getToken();
      if (token.isEmpty) {
        DialogUtils.showCustomAlert(
          context,
          AlertType.error,
          "Session expired. Please login again.",
        );
        return false;
      }

      debugPrint(
        "DEBUG: Funding Appointment $appointmentId with amount $amount",
      );

      // 1. Get Payment Intent for specific appointment
      final response = await dio.post(
        "$basePaymentUrl/customer/fund-appointment/",
        data: json.encode({"appointment_id": appointmentId, "amount": amount}),
        options: Options(headers: dioHeaders(token)),
      );

      debugPrint(
        "DEBUG: Fund Appointment Response Status: ${response.statusCode}",
      );

      if (response.statusCode != 200) {
        debugPrint("Fund Appointment Error: ${response.data}");
        DialogUtils.showCustomAlert(
          context,
          AlertType.error,
          "Failed to initialize payment: ${response.data['error'] ?? 'Unknown error'}",
        );
        return false;
      }

      final data = response.data;
      debugPrint("DEBUG: Received Payment Data, initializing sheet...");
      debugPrint(
        "DEBUG: PaymentIntent Key present: ${data.containsKey('paymentIntent')}",
      );

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customerId: data['customer'],
          paymentIntentClientSecret: data['paymentIntent'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          merchantDisplayName: "Neighbor Services",
          style: ThemeModeState.themeMode,
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'US'),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: "US",
            currencyCode: "USD",
            testEnv: true,
          ),
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Theme.of(context).scaffoldBackgroundColor,
              primaryText: Theme.of(context).iconTheme.color,
              secondaryText: Theme.of(context).iconTheme.color,
              componentText: Theme.of(context).iconTheme.color,
              placeholderText: Theme.of(context).iconTheme.color,
              componentBorder: Theme.of(context).iconTheme.color,
              componentBackground: Theme.of(context).scaffoldBackgroundColor,
              componentDivider: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      );

      debugPrint("DEBUG: Payment Sheet Initialized, presenting...");

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();
      debugPrint("DEBUG: Payment Sheet Presented successfully");
      return true;
    } catch (e) {
      debugPrint("Fund Appointment Exception: $e");
      String errorMessage = "An error occurred during payment initialization.";

      if (e is StripeException) {
        errorMessage =
            "Payment cancelled or failed: ${e.error.localizedMessage}";
      } else if (e is DioException) {
        errorMessage =
            "Server error: ${e.response?.data?['error'] ?? e.message}";
      } else {
        errorMessage = e.toString();
      }

      if (context.mounted) {
        DialogUtils.showCustomAlert(context, AlertType.error, errorMessage);
      }
      return false;
    }
  }

  static Future<bool> makePayment({
    String? amount,
    required BuildContext context,
  }) async {
    try {
      var payment = await initStripePayment(amount: amount!, context: context);
      if (payment) {
        await Stripe.instance.presentPaymentSheet();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<String> getCustomerFromStripe() async {
    return "";
  }

  static Future<bool> createSubscription(
    BuildContext context,
    String planId,
  ) async {
    try {
      final String token = await _getToken();
      // Customer fetch removed as it is unused.
      /* 
      // Default payment method check might be too strict if we allow new card in payment sheet?
      if (customer.customer?.paymentMethod == null ||
          customer.customer?.paymentMethod == "") {
         // ...
      }
      */

      final response = await dio.post(
        "$basePaymentUrl/subscription/create/",
        data: json.encode({"plan_id": planId}),
        options: Options(headers: dioHeaders(token)),
      );

      debugPrint("Subscription API StatusCode: ${response.statusCode}");
      debugPrint("Subscription API Data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if additional action required (Payment Sheet)
        if (data['client_secret'] != null) {
          debugPrint("Initializing Payment Sheet...");
          debugPrint("Customer: ${data['customer']}");
          debugPrint("EphemeralKey: ${data['ephemeralKey']}");

          try {
            await Stripe.instance.initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                customerId: data['customer'],
                paymentIntentClientSecret: data['client_secret'],
                customerEphemeralKeySecret: data['ephemeralKey'],
                merchantDisplayName: "Neighbor Services",
                style: ThemeModeState.themeMode,
                applePay: const PaymentSheetApplePay(merchantCountryCode: 'US'),
                googlePay: const PaymentSheetGooglePay(
                  merchantCountryCode: "US",
                  currencyCode: "USD",
                  testEnv: true,
                ),
                appearance: PaymentSheetAppearance(
                  colors: PaymentSheetAppearanceColors(
                    background: Theme.of(context).scaffoldBackgroundColor,
                    primaryText: Theme.of(context).iconTheme.color,
                    secondaryText: Theme.of(context).iconTheme.color,
                    componentText: Theme.of(context).iconTheme.color,
                    placeholderText: Theme.of(context).iconTheme.color,
                    componentBorder: Theme.of(context).iconTheme.color,
                    componentBackground: Theme.of(
                      context,
                    ).scaffoldBackgroundColor,
                    componentDivider: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
            );
            debugPrint("Payment Sheet Initialized.");

            await Stripe.instance.presentPaymentSheet();
            debugPrint("Payment Sheet Presented & Completed.");
            return true;
          } catch (e) {
            debugPrint("Stripe Payment Sheet Error: $e");
            if (e is StripeException) {
              debugPrint(
                "Stripe Exception Details: ${e.error.localizedMessage}",
              );
            }
            rethrow;
          }
        }

        if (data is Map &&
            data['subscription'] != null &&
            data['subscription']['is_active'] == true) {
          return true;
        }

        return false;
      } else {
        DialogUtils.showCustomAlert(
          context,
          AlertType.error,
          "Payment declined",
        );
        return false;
      }
    } catch (e) {
      if (e is StripeException) {
        DialogUtils.showCustomAlert(
          context,
          AlertType.error,
          "Payment cancelled or failed",
        );
      } else {
        debugPrint(e.toString());
        DialogUtils.showCustomAlert(
          context,
          AlertType.error,
          "An error occurred",
        );
      }
      return false;
    }
  }

  static Future<void> createMonthlySubscription(BuildContext context) async {
    try {
      final String token = await _getToken();
      await getCustomerFromStripe();
      CustomerData customer = await getCustomer(
        uid: SuccessGetProfileState.profile.user!.id,
      );
      if (customer.customer!.paymentMethod == "") {
        DialogUtils.showCustomAlert(
          context,
          AlertType.error,
          "Please set default payment method before proceeding",
        );
        return;
      }

      final response = await dio.post(
        "$basePaymentUrl/subscription/montly/create/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        DialogUtils.showCustomAlert(
          context,
          AlertType.success,
          "Subscription Successful",
        );
      } else {
        DialogUtils.showCustomAlert(
          context,
          AlertType.error,
          "Payment declined",
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> createYearlySubscription(BuildContext context) async {
    try {
      final String token = await _getToken();
      await getCustomerFromStripe();
      CustomerData customer = await getCustomer(
        uid: SuccessGetProfileState.profile.user!.id,
      );
      if (customer.customer!.paymentMethod == "") {
        DialogUtils.showCustomAlert(
          context,
          AlertType.error,
          "Please set default payment method before proceeding",
        );
        return;
      }

      final response = await dio.post(
        "$basePaymentUrl/subscription/yearly/create/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        DialogUtils.showCustomAlert(
          context,
          AlertType.success,
          "Subscription Successful",
        );
      } else {
        DialogUtils.showCustomAlert(
          context,
          AlertType.error,
          "Payment declined",
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> setUpStripeConnectAccount() async {
    try {
      CustomerData customerModel = await getCustomer(
        uid: SuccessGetProfileState.profile.user!.id,
      );
      if (customerModel.customer!.accountId != null ||
          customerModel.customer!.accountId.toString() != "") {
        final String token = await _getToken();
        await dio.post(
          "$basePaymentUrl/customer/account/connect/",
          options: Options(headers: dioHeaders(token)),
        );
        return;
      } else {
        final String token = await _getToken();
        final response = await dio.post(
          "$basePaymentUrl/customer/account/connect/",
          options: Options(headers: dioHeaders(token)),
        );
        if (response.statusCode == 200) {
          return response.data["message"];
        } else {
          return response.data["error"];
        }
      }
    } catch (e) {
      if (e is DioException) {}
      debugPrint(e.toString());
    }
  }

  static Future<AccountLink?> createAccountLink() async {
    try {
      final String token = await _getToken();
      // Use Backend endpoint
      final response = await dio.post(
        "$basePaymentUrl/payments/wallet/onboard/",
        options: Options(headers: dioHeaders(token)),
      );

      if (response.statusCode == 200) {
        return AccountLink.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Create Account Link Error: $e");
      return null;
    }
  }

  static Future<void> payoutUser({
    required BuildContext context,
    required String uid,
    required String amount,
  }) async {
    try {
      final String token = await _getToken();
      final response = await dio.post(
        "$basePaymentUrl/customer/transfer/",
        options: Options(headers: dioHeaders(token)),
        data: json.encode({"amount": int.parse(amount), "user_id": uid}),
      );

      if (response.statusCode == 200) {
        DialogUtils.showCustomAlert(
          context,
          AlertType.success,
          "Payment successful",
        );
      } else {
        DialogUtils.showCustomAlert(
          context,
          AlertType.error,
          "Payment unsuccessfully",
        );
      }
    } catch (e) {
      DialogUtils.showCustomAlert(
        context,
        AlertType.error,
        "Payment unsuccessfully",
      );
    }
  }

  static Future<bool> addUserSubscriptionDetails({
    required Subscription sSubscription,
    required String amount,
    required BuildContext context,
  }) async {
    try {
      final results = await PaymentService.makePayment(
        amount: amount,
        context: context,
      );

      if (results) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<Subscription?> getSubscription({String? uid}) async {
    try {
      final String token = await _getToken();
      if (token.isEmpty) return null;

      final response = await dio.get(
        "$basePaymentUrl/subscription/?user=$uid",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          return Subscription.fromJson(response.data);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static Future<Subscription?> getUserSubscriptionDetails() async {
    try {
      final String token = await _getToken();
      if (token.isEmpty) return null;
      final response = await dio.get(
        "$basePaymentUrl/subscription/user/get/",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        if (response.data != null &&
            response.data is Map &&
            response.data["subscription"] != null) {
          return Subscription.fromJson(response.data["subscription"]);
        }
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<bool> deleteUserSubscriptionDetails() async {
    try {
      final String token = await _getToken();
      final response = await dio.delete(
        "$basePaymentUrl/subscription/user/delete/",
        options: Options(headers: dioHeaders(token)),
      );
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  static Future<bool> userHasTheValidSubscription() async {
    try {
      final Subscription? result = await getUserSubscriptionDetails();

      if (result != null) {
        // Must be active AND (either has no expiry or expiry is in future)
        if (result.isActive == true) {
          if (result.nextPayment == null) {
            return true; // Assume active if nextPayment is missing but isActive is true
          }
          return result.nextPayment!.isAfter(DateTime.now());
        }
      }
      return false;
    } catch (e) {
      debugPrint("Error checking subscription validity: $e");
      return false;
    }
  }
}
