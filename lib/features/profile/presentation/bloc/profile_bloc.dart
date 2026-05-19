
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/about.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/review.dart';
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
import 'package:nsapp/features/profile/domain/usecase/initiate_background_check_use_case.dart';
import 'package:nsapp/features/profile/domain/usecase/get_audit_logs_use_case.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/audit_log.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends HydratedBloc<ProfileEvent, ProfileState> {
  final AddProfileUseCase addProfileUseCase;
  final GetProfileUseCase getProfileUseCase;
  final GetProfileStreamUseCase getProfileStreamUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final AddAboutUseCase addAboutUseCase;
  final AddReviewUseCase addReviewUseCase;
  final GetAboutUseCase getAboutUseCase;
  final GetReviewsUseCase getReviewsUseCase;
  final UpdateDeviceTokenUseCase updateDeviceTokenUseCase;
  final DeleteAboutUseCase deleteAboutUseCase;
  final InitiateBackgroundCheckUseCase initiateBackgroundCheckUseCase;
  final GetAuditLogsUseCase getAuditLogsUseCase;

  Profile? _cachedProfile;
  List<AuditLog> _cachedAuditLogs = [];

  Profile? get currentProfile => _cachedProfile;
  List<AuditLog> get auditLogs => _cachedAuditLogs;

  ProfileBloc(
    this.addProfileUseCase,
    this.getProfileUseCase,
    this.getProfileStreamUseCase,
    this.updateProfileUseCase,
    this.addAboutUseCase,
    this.addReviewUseCase,
    this.getAboutUseCase,
    this.getReviewsUseCase,
    this.updateDeviceTokenUseCase,
    this.deleteAboutUseCase,
    this.initiateBackgroundCheckUseCase,
    this.getAuditLogsUseCase,
  ) : super(InitialProfileState()) {
    on<SelectDateOfBirthEvent>((event, emit) async {
      final date = await Helpers.selectBirthDate(event.context);
      if (date != null) {
        emit(DateOfBirthProfileState(dob: date, profile: _cachedProfile));
      }
    });
    
    on<SelectImageFromGalleryEvent>((event, emit) async {
      final selectedImage = await Helpers.selectImageFromGallery();
      if (selectedImage != null) {
        emit(ImageProfileState(profilePicture: selectedImage, profile: _cachedProfile));
      }
    });

    on<AboutUserEvent>((event, emit) async {
      emit(PortfolioUserState(userId: event.userID, profile: _cachedProfile));
    });

    on<SelectImagesFromGalleryEvent>((event, emit) async {
      final selectedImages = await Helpers.selectImagesFromGallery();
      if (selectedImages != null && selectedImages.isNotEmpty) {
        emit(ImagesProfileState(images: selectedImages, profile: _cachedProfile));
      }
    });

    on<SelectImageFromCameraEvent>((event, emit) async {
      final selectedImage = await Helpers.selectImageFromCamera();
      if (selectedImage != null) {
        emit(ImageProfileState(profilePicture: selectedImage, profile: _cachedProfile));
      }
    });

    on<SetUserTypeEvent>((event, emit) async {
      emit(UserTypeProfileState(userType: event.userType, profile: _cachedProfile));
    });

    on<AddProfileEvent>((event, emit) async {
      emit(LoadingProfileState(profile: _cachedProfile));
      final results = await addProfileUseCase.call(ProfileParams(
        profile: event.profile,
        profilePicturePath: event.profilePicturePath,
      ));
      results.fold(
        (failure) => emit(FailureCreateProfileState(message: failure.message ?? 'Failed to create profile', profile: _cachedProfile)),
        (success) {
          _cachedProfile = event.profile;
          emit(SuccessCreateProfileState(profile: _cachedProfile));
        },
      );
    });

    on<UpdateTokenEvent>((event, emit) async {
      final results = await updateDeviceTokenUseCase.call(event);
      results.fold(
        (failure) => emit(FailureUpdateTokenState(message: failure.message ?? 'Failed to update token', profile: _cachedProfile)),
        (success) => emit(SuccessUpdateTokenState(profile: _cachedProfile)),
      );
    });

    on<AddReviewEvent>((event, emit) async {
      emit(LoadingProfileState(profile: _cachedProfile));
      final results = await addReviewUseCase.call(event.review);
      results.fold(
        (failure) => emit(FailureAddReviewState(message: failure.message ?? 'Failed to add review', profile: _cachedProfile)),
        (success) => emit(SuccessAddReviewState(profile: _cachedProfile)),
      );
    });

    on<AddAboutEvent>((event, emit) async {
      emit(LoadingProfileState(profile: _cachedProfile));
      final results = await addAboutUseCase.call(event.about);
      results.fold(
        (failure) => emit(FailureAddAboutState(message: failure.message ?? 'Failed to add about', profile: _cachedProfile)),
        (success) => emit(SuccessAddAboutState(profile: _cachedProfile)),
      );
    });

    on<DeleteAboutUserEvent>((event, emit) async {
      emit(LoadingProfileState(profile: _cachedProfile));
      final results = await deleteAboutUseCase.call(event.id);
      results.fold(
        (failure) => emit(FailureDeleteAboutState(message: failure.message ?? 'Failed to delete about', profile: _cachedProfile)),
        (success) => emit(SuccessDeleteAboutState(profile: _cachedProfile)),
      );
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(LoadingProfileState(profile: _cachedProfile));
      final results = await updateProfileUseCase.call(ProfileParams(
        profile: event.profile,
        profilePicturePath: event.profilePicturePath,
      ));
      results.fold(
        (failure) => emit(FailureUpdateProfileState(message: failure.message ?? 'Failed to update profile', profile: _cachedProfile)),
        (success) {
          _cachedProfile = event.profile;
          emit(SuccessUpdateProfileState(profile: _cachedProfile));
        },
      );
    });

    on<GetProfileStreamEvent>((event, emit) async {
      final results = await getProfileStreamUseCase.call(event);
      results.fold(
        (failure) {
          debugPrint("ProfileBloc: GetProfileStreamEvent Failure: ${failure.message}");
          if (_cachedProfile != null) {
            emit(SuccessGetProfileStreamState(profile: _cachedProfile!));
          } else {
            emit(FailureGetProfileStreamState(message: failure.message ?? 'Failed to fetch profile'));
          }
        },
        (success) {
          debugPrint("ProfileBloc: GetProfileStreamEvent Success");
          _cachedProfile = success;
          emit(SuccessGetProfileStreamState(profile: success));
        },
      );
    });

    on<GetProfileEvent>((event, emit) async {
      final results = await getProfileStreamUseCase.call(event);
      results.fold(
        (failure) {
          debugPrint("ProfileBloc: GetProfileEvent Failure: ${failure.message}");
          if (_cachedProfile != null) {
            emit(SuccessGetProfileState(profile: _cachedProfile!));
          } else {
            emit(FailureGetProfileState(message: failure.message ?? 'Failed to fetch profile'));
          }
        },
        (success) {
          _cachedProfile = success;
          emit(SuccessGetProfileState(profile: success));
        },
      );
    });

    on<GetAboutEvent>((event, emit) async {
      final results = await getAboutUseCase.call(event.user);
      results.fold(
        (failure) {
          emit(FailureGetAboutState(message: failure.message ?? 'Failed to fetch about info', profile: _cachedProfile));
        },
        (success) {
          emit(SuccessGetAboutStreamState(about: success, profile: _cachedProfile));
        },
      );
    });

    on<GetReviewsEvent>((event, emit) async {
      final results = await getReviewsUseCase.call(event.user);
      results.fold(
        (failure) {
          emit(FailureGetReviewsStreamState(message: failure.message ?? 'Failed to fetch reviews', profile: _cachedProfile));
        },
        (success) {
          emit(SuccessGetReviewStreamState(reviews: success, profile: _cachedProfile));
        },
      );
    });

    on<ChooseOtherServiceEvent>((event, emit) {
      emit(OtherServiceSelectState(others: event.others, profile: _cachedProfile));
    });

    on<InitiateBackgroundCheckEvent>((event, emit) async {
      emit(LoadingProfileState(profile: _cachedProfile));
      final results = await initiateBackgroundCheckUseCase.call(
          BackgroundCheckParams(paymentIntentId: event.paymentIntentId));
      results.fold(
        (failure) => emit(FailureInitiateBackgroundCheckState(
            message: failure.message ?? 'Failed to initiate background check', profile: _cachedProfile)),
        (success) {
          if (success != null && success.isNotEmpty) {
            emit(SuccessInitiateBackgroundCheckState(url: success, profile: _cachedProfile));
          } else {
            emit(FailureInitiateBackgroundCheckState(
                message: 'Invalid response from server', profile: _cachedProfile));
          }
        },
      );
    });

    on<GetAuditLogsEvent>((event, emit) async {
      emit(LoadingAuditLogsState(profile: _cachedProfile));
      final results = await getAuditLogsUseCase.call(NoParams());
      results.fold(
        (failure) => emit(FailureGetAuditLogsState(
            message: failure.message ?? 'Failed to fetch audit logs', profile: _cachedProfile)),
        (success) {
          _cachedAuditLogs = success;
          emit(SuccessGetAuditLogsState(logs: success, profile: _cachedProfile));
        },
      );
    });

    on<CreateStripeCustomerEvent>((event, emit) async {
      // This is a fire-and-forget background task as per the original UI implementation
      await Helpers.createStripeCustomer(userId: event.userId);
    });

    on<LogoutProfileEvent>((event, emit) {
      _cachedProfile = null;
      _cachedAuditLogs = [];
      emit(InitialProfileState());
    });
  }

  @override
  ProfileState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('profile')) {
        _cachedProfile = Profile.fromJson(json['profile']);
      }
      if (json.containsKey('audit_logs')) {
        final List logsJson = json['audit_logs'];
        _cachedAuditLogs = logsJson.map((e) => AuditLog.fromJson(e)).toList();
      }
      
      if (_cachedProfile != null) {
        return SuccessGetProfileState(profile: _cachedProfile!);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(ProfileState state) {
    // Always persist the cached profile, regardless of which transient
    // state (e.g. PortfolioUserState, LoadingProfileState) is currently active.
    // This prevents profile data from being wiped when navigating to provider cards.
    final Map<String, dynamic> data = {};
    if (_cachedProfile != null) {
      data['profile'] = _cachedProfile!.toJson();
    }
    if (_cachedAuditLogs.isNotEmpty) {
      data['audit_logs'] = _cachedAuditLogs.map((e) => e.toJson()).toList();
    }
    // Also update _cachedProfile if the current state carries a profile
    if (state is SuccessGetProfileState) {
      data['profile'] = state.profile.toJson();
    }
    return data.isNotEmpty ? data : null;
  }
}
