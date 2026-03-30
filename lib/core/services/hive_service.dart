import 'package:hive_flutter/hive_flutter.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/user.dart';
import 'package:nsapp/core/models/portfolio_item.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/chat.dart';
import 'package:nsapp/core/models/customer.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/core/models/favorite.dart';
import 'package:nsapp/core/models/acceptance.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/core/models/notification.dart';
import 'package:nsapp/core/models/wallet.dart';
import 'package:nsapp/core/models/performance_badge.dart';

class HiveService {
  static const String profileBox = 'profile_box';
  static const String messageBox = 'message_box';
  static const String appointmentBox = 'appointment_box';
  static const String settingsBox = 'settings_box';
  static const String serviceRequestBox = 'service_request_box';

  Future<void> init() async {
    await Hive.initFlutter();

    // TypeAdapters registration
    Hive.registerAdapter(ProfileAdapter());
    Hive.registerAdapter(UserAdapter());
    Hive.registerAdapter(PasswordAdapter());
    Hive.registerAdapter(PortfolioItemAdapter());
    Hive.registerAdapter(ServicePackageAdapter());
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(AppointmentAdapter());
    Hive.registerAdapter(AppointmentDataAdapter());
    Hive.registerAdapter(ChatAdapter());
    Hive.registerAdapter(ChatDataAdapter());
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(CustomerDataAdapter());
    Hive.registerAdapter(RequestDataAdapter());
    Hive.registerAdapter(RequestAcceptanceAdapter());
    Hive.registerAdapter(FavoriteAdapter());
    Hive.registerAdapter(AcceptanceAdapter());
    Hive.registerAdapter(RequestAdapter());
    Hive.registerAdapter(ServiceAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(NotificationAdapter());
    Hive.registerAdapter(NotificationDataAdapter());
    Hive.registerAdapter(WalletAdapter());
    Hive.registerAdapter(WalletTransactionAdapter());
    Hive.registerAdapter(PayoutRequestAdapter());
    Hive.registerAdapter(PerformanceBadgeAdapter());

    await openBoxes();
  }

  Future<void> openBoxes() async {
    await Future.wait([
      Hive.openBox(profileBox),
      Hive.openBox(messageBox),
      Hive.openBox(appointmentBox),
      Hive.openBox(settingsBox),
      Hive.openBox(serviceRequestBox),
    ]);
  }

  Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  Future<void> clearAll() async {
    await Hive.deleteFromDisk();
    await openBoxes();
  }
}
