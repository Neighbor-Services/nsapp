import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:nsapp/core/services/hive_service.dart';
import 'package:nsapp/core/services/notification_socket_service.dart';
import 'package:nsapp/features/authentications/data/datasource/remote/authentication_remote_data_source.dart';
import 'package:nsapp/features/authentications/data/datasource/remote/authentication_remote_data_source_impl.dart';
import 'package:nsapp/features/authentications/data/repository/authenication_repository_impl.dart';
import 'package:nsapp/features/authentications/domain/repository/authentication_repository.dart';
import 'package:nsapp/features/authentications/domain/usecase/change_password_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/login_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/login_with_google_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/logout_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/register_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/register_with_google_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/reset_password_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/verify_registered_email_usecase.dart';
import 'package:nsapp/features/authentications/domain/usecase/request_password_reset_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/verify_email_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/send_email_verification_use_case.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/messages/data/datasource/remote/message_remote_datasource.dart';
import 'package:nsapp/features/messages/data/datasource/remote/message_remote_datasource_impl.dart';
import 'package:nsapp/features/messages/data/repository/messages_repository_impl.dart';
import 'package:nsapp/features/messages/domain/repository/messages_repository.dart';
import 'package:nsapp/features/messages/domain/usecase/delete_message_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/get_messages_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/get_my_messages_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/reload_message_receiver_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/set_seen_use_case.dart';
import 'package:nsapp/features/messages/domain/usecase/update_message_use_case.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/profile/data/datasource/remote/profile_remote_datasource.dart';
import 'package:nsapp/features/profile/data/datasource/remote/profile_remote_datasource_impl.dart';
import 'package:nsapp/features/profile/data/repository/profile_repository_impl.dart';
import 'package:nsapp/features/profile/domain/repository/profile_repository.dart';
import 'package:nsapp/features/profile/domain/usecase/add_about_use_case.dart';
import 'package:nsapp/features/profile/domain/usecase/add_profile_use_case.dart';
import 'package:nsapp/features/profile/domain/usecase/add_review_use_case.dart';
import 'package:nsapp/features/profile/domain/usecase/delete_about_use_case.dart';
import 'package:nsapp/features/profile/domain/usecase/get_about_use_case.dart';
import 'package:nsapp/features/profile/domain/usecase/get_profile_stream_use_case.dart';
import 'package:nsapp/features/profile/domain/usecase/get_profile_use_case.dart';
import 'package:nsapp/features/profile/domain/usecase/get_reviews_use_case.dart';
import 'package:nsapp/features/profile/domain/usecase/update_device_token_use_case.dart';
import 'package:nsapp/features/profile/domain/usecase/update_profile_use_case.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/data/datasource/remote/provider_remote_datasource.dart';
import 'package:nsapp/features/provider/data/datasource/remote/provider_remote_datasource_impl.dart';
import 'package:nsapp/features/provider/data/repository/provider_repository_impl.dart';
import 'package:nsapp/features/provider/domain/repository/provider_repository.dart';
import 'package:nsapp/features/provider/domain/usecase/accept_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/add_appointment_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/add_portfolio_item_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/add_service_package_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/cancel_appointment_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/cancel_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_accepted_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_appointments_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_recent_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_requests_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/is_request_accepted_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/reload_profile_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/serach_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/complete_appointment_use_case.dart'
    as provider_complete;
import 'package:nsapp/features/provider/domain/usecase/update_appointment_use_case.dart'
    as provider_update_appt;
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/seeker/data/datasource/remote/seeker_remote_datasource.dart';
import 'package:nsapp/features/seeker/data/datasource/remote/seeker_remote_datasource_impl.dart';
import 'package:nsapp/features/seeker/data/repository/seeker_repository_impl.dart';
import 'package:nsapp/features/seeker/domain/repository/seeker_repository.dart';
import 'package:nsapp/features/seeker/domain/usecase/add_to_favorite_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/approve_provider_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/cancel_appointment_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/cancel_approved_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/create_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/delete_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/get_accepted_users_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/get_appointments_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/get_my_favorites_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/get_my_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/get_popular_provider_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/mark_as_done_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/rate_provider_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/reload_request_use_case.dart'; // Just in case I named it differently? No, I named it MatchProvidersUseCase.
import 'package:nsapp/features/seeker/domain/usecase/match_providers_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/remove_from_favorite_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/search_provider_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/update_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/complete_appointment_use_case.dart'
    as seeker_complete;
import 'package:nsapp/features/seeker/domain/usecase/update_appointment_use_case.dart'
    as seeker_update_appt;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/data/datasource/remote/shared_remote_datasource.dart';
import 'package:nsapp/features/shared/data/datasource/remote/shared_remote_datasource_impl.dart';
import 'package:nsapp/features/shared/data/repository/shared_repository_impl.dart';
import 'package:nsapp/features/shared/domain/repository/shared_repository.dart';
import 'package:nsapp/features/shared/domain/usecase/add_notification_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/add_report_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/add_service_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/change_user_type_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/create_dispute_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_notifications_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_wallet_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_services_usecase.dart';
import 'package:nsapp/features/shared/domain/usecase/request_payout_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_subscription_plans_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/search_place_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/search_places_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/set_seen_notification_use_case.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_disputes_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_stripe_dashboard_link_use_case.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ! External
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
  sl.registerLazySingleton<SharedPreferencesWithCache>(() => prefs);
  sl.registerLazySingleton(() => Dio());
  // sl.registerLazySingleton(() => InternetConnectionCheckerPlus());
  sl.registerLazySingleton(() => NotificationSocketService());

  final hiveService = HiveService();
  await hiveService.init();
  sl.registerLazySingleton(() => hiveService);

  // ! Data Source
  sl.registerLazySingleton<AuthenticationRemoteDataSource>(
    () => AuthenticationRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<ProviderRemoteDatasource>(
    () => ProviderRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<SeekerRemoteDatasource>(
    () => SeekerRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<SharedRemoteDatasource>(
    () => SharedRemoteDatasourceImpl(),
  );
  sl.registerLazySingleton<MessageRemoteDatasource>(
    () => MessageRemoteDatasourceImpl(),
  );

  // ! Repository
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenicationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ProviderRepository>(
    () => ProviderRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<SeekerRepository>(
    () => SeekerRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<SharedRepository>(
    () => SharedRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<MessagesRepository>(
    () => MessagesRepositoryImpl(sl(), sl()),
  );

  // ! Use Cases
  // Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => RegisterWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => VerifyRegisteredEmailUsecase(sl()));
  sl.registerLazySingleton(() => RequestPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => VerifyEmailUseCase(sl()));
  sl.registerLazySingleton(() => SendEmailVerificationUseCase(sl()));

  // Messsages
  sl.registerLazySingleton(() => GetMessagesUseCase(sl()));
  sl.registerLazySingleton(() => GetMyMessagesUseCase(sl()));
  sl.registerLazySingleton(() => ReloadMessageReceiverUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMessageUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMessageUseCase(sl()));
  sl.registerLazySingleton(() => SetSeenUseCase(sl()));

  // Profile
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileStreamUseCase(sl()));
  sl.registerLazySingleton(() => AddProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDeviceTokenUseCase(sl()));
  sl.registerLazySingleton(() => AddReviewUseCase(sl()));
  sl.registerLazySingleton(() => GetReviewsUseCase(sl()));
  sl.registerLazySingleton(() => AddAboutUseCase(sl()));
  sl.registerLazySingleton(() => GetAboutUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAboutUseCase(sl()));

  // Provider
  sl.registerLazySingleton(() => GetRequestsUseCase(sl()));
  sl.registerLazySingleton(() => AcceptRequestUseCase(sl()));
  sl.registerLazySingleton(
    () => CancelRequestUseCase(sl()),
  ); // Provider cancel request
  sl.registerLazySingleton(() => ReloadProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetAcceptedRequestUseCase(sl()));
  sl.registerLazySingleton(() => AddAppointmentUseCase(sl()));
  sl.registerLazySingleton(
    () => GetAppointmentsUseCase(sl()),
  ); // Provider get appointments
  sl.registerLazySingleton(() => CancelProviderAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => SerachRequestUseCase(sl()));
  sl.registerLazySingleton(() => IsRequestAcceptedUseCase(sl()));
  sl.registerLazySingleton(() => AddPortfolioItemUseCase(sl()));
  sl.registerLazySingleton(() => AddServicePackageUseCase(sl()));
  sl.registerLazySingleton(
    () => provider_update_appt.UpdateProviderAppointmentUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => provider_complete.CompleteAppointmentUseCase(sl()),
  );

  // Seeker
  sl.registerLazySingleton(() => CreateRequestUseCase(sl()));
  sl.registerLazySingleton(
    () => GetMyRequestUseCase(sl()),
  ); // Was GetSeekerRequestsUseCase in my list, but file is get_my_request_use_case
  sl.registerLazySingleton(() => GetAcceptedUsersUseCase(sl()));
  sl.registerLazySingleton(() => ApproveProviderUseCase(sl()));
  sl.registerLazySingleton(() => CancelApprovedRequestUseCase(sl()));
  // Seeker's CancelRequestUseCase is 'cancel_approved_request_use_case.dart' based on bloc Usage?
  // SeekerBloc uses CancelApprovedRequestUseCase.
  sl.registerLazySingleton(() => SearchProviderUseCase(sl()));
  sl.registerLazySingleton(() => GetPopularProviderRequestUseCase(sl()));
  sl.registerLazySingleton(() => AddToFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRequestUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRequestUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => GetMyFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => GetSeekerAppointmentsUseCase(sl()));
  sl.registerLazySingleton(() => CancelAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsDoneUseCase(sl()));
  sl.registerLazySingleton(() => RateProviderUseCase(sl()));
  sl.registerLazySingleton(() => ReloadRequestUseCase(sl()));
  sl.registerLazySingleton(() => MatchProvidersUseCase(sl()));
  sl.registerLazySingleton(
    () => seeker_update_appt.UpdateSeekerAppointmentUseCase(sl()),
  );
  sl.registerLazySingleton(
    () => seeker_complete.CompleteAppointmentUseCase(sl()),
  );

  // Shared

  // Shared
  sl.registerLazySingleton(() => AddNotificationUseCase(sl()));
  sl.registerLazySingleton(() => GetMyNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => SetSeenNotificationUseCase(sl()));
  sl.registerLazySingleton(() => AddReportUseCase(sl()));
  sl.registerLazySingleton(() => SearchPlacesUseCase(sl()));
  sl.registerLazySingleton(() => SearchPlaceUseCase(sl()));
  sl.registerLazySingleton(() => GetServicesUsecase(sl()));
  sl.registerLazySingleton(() => AddServiceUseCase(sl()));
  sl.registerLazySingleton(() => ChangeUserTypeUseCase(sl()));
  sl.registerLazySingleton(() => CreateDisputeUseCase(sl()));
  sl.registerLazySingleton(() => GetMyWalletUseCase(sl()));
  sl.registerLazySingleton(() => RequestPayoutUseCase(sl()));
  sl.registerLazySingleton(() => GetSubscriptionPlansUseCase(sl()));
  sl.registerLazySingleton(() => GetMyDisputesUseCase(sl()));
  sl.registerLazySingleton(() => GetStripeDashboardLinkUseCase(sl()));

  // ! Blocs
  sl.registerFactory(
    () => AuthenticationBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory(
    () =>
        ProfileBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()),
  );

  sl.registerFactory(
    () => ProviderBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory(
    () => SeekerBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );

  sl.registerFactory(() => MessageBloc(sl(), sl(), sl(), sl(), sl(), sl()));

  sl.registerFactory(
    () => SharedBloc(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
    ),
  );
}
