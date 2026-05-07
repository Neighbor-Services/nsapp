
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
        emit(DateOfBirthProfileState(dob: date));
      }
    });
    
    on<SelectImageFromGalleryEvent>((event, emit) async {
      final selectedImage = await Helpers.selectImageFromGallery();
      if (selectedImage != null) {
        emit(ImageProfileState(profilePicture: selectedImage));
      }
    });

    on<AboutUserEvent>((event, emit) async {
      emit(PortfolioUserState(userId: event.userID));
    });

    on<SelectImagesFromGalleryEvent>((event, emit) async {
      final selectedImages = await Helpers.selectImagesFromGallery();
      if (selectedImages != null && selectedImages.isNotEmpty) {
        emit(ImagesProfileState(images: selectedImages));
      }
    });

    on<SelectImageFromCameraEvent>((event, emit) async {
      final selectedImage = await Helpers.selectImageFromCamera();
      if (selectedImage != null) {
        emit(ImageProfileState(profilePicture: selectedImage));
      }
    });

    on<SetUserTypeEvent>((event, emit) async {
      emit(UserTypeProfileState(userType: event.userType));
    });

    on<AddProfileEvent>((event, emit) async {
      emit(LoadingProfileState());
      final results = await addProfileUseCase.call(ProfileParams(
        profile: event.profile,
        profilePicturePath: event.profilePicturePath,
      ));
      results.fold(
        (failure) => emit(FailureCreateProfileState(message: failure.message ?? 'Failed to create profile')),
        (success) {
          _cachedProfile = event.profile;
          emit(SuccessCreateProfileState());
        },
      );
    });

    on<UpdateTokenEvent>((event, emit) async {
      final results = await updateDeviceTokenUseCase.call(event);
      results.fold(
        (failure) => emit(FailureUpdateTokenState(message: failure.message ?? 'Failed to update token')),
        (success) => emit(SuccessUpdateTokenState()),
      );
    });

    on<AddReviewEvent>((event, emit) async {
      emit(LoadingProfileState());
      final results = await addReviewUseCase.call(event.review);
      results.fold(
        (failure) => emit(FailureAddReviewState(message: failure.message ?? 'Failed to add review')),
        (success) => emit(SuccessAddReviewState()),
      );
    });

    on<AddAboutEvent>((event, emit) async {
      emit(LoadingProfileState());
      final results = await addAboutUseCase.call(event.about);
      results.fold(
        (failure) => emit(FailureAddAboutState(message: failure.message ?? 'Failed to add about')),
        (success) => emit(SuccessAddAboutState()),
      );
    });

    on<DeleteAboutUserEvent>((event, emit) async {
      emit(LoadingProfileState());
      final results = await deleteAboutUseCase.call(event.id);
      results.fold(
        (failure) => emit(FailureDeleteAboutState(message: failure.message ?? 'Failed to delete about')),
        (success) => emit(SuccessDeleteAboutState()),
      );
    });

    on<UpdateProfileEvent>((event, emit) async {
      emit(LoadingProfileState());
      final results = await updateProfileUseCase.call(ProfileParams(
        profile: event.profile,
        profilePicturePath: event.profilePicturePath,
      ));
      results.fold(
        (failure) => emit(FailureUpdateProfileState(message: failure.message ?? 'Failed to update profile')),
        (success) {
          _cachedProfile = event.profile;
          emit(SuccessUpdateProfileState());
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
          emit(FailureGetAboutState(message: failure.message ?? 'Failed to fetch about info'));
        },
        (success) {
          emit(SuccessGetAboutStreamState(about: success));
        },
      );
    });

    on<GetReviewsEvent>((event, emit) async {
      final results = await getReviewsUseCase.call(event.user);
      results.fold(
        (failure) {
          emit(FailureGetReviewsStreamState(message: failure.message ?? 'Failed to fetch reviews'));
        },
        (success) {
          emit(SuccessGetReviewStreamState(reviews: success));
        },
      );
    });

    on<ChooseOtherServiceEvent>((event, emit) {
      emit(OtherServiceSelectState(others: event.others));
    });

    on<InitiateBackgroundCheckEvent>((event, emit) async {
      emit(LoadingProfileState());
      final results = await initiateBackgroundCheckUseCase.call(
          BackgroundCheckParams(paymentIntentId: event.paymentIntentId));
      results.fold(
        (failure) => emit(FailureInitiateBackgroundCheckState(
            message: failure.message ?? 'Failed to initiate background check')),
        (success) {
          if (success != null && success.isNotEmpty) {
            emit(SuccessInitiateBackgroundCheckState(url: success));
          } else {
            emit(FailureInitiateBackgroundCheckState(
                message: 'Invalid response from server'));
          }
        },
      );
    });

    on<GetAuditLogsEvent>((event, emit) async {
      emit(LoadingAuditLogsState());
      final results = await getAuditLogsUseCase.call(NoParams());
      results.fold(
        (failure) => emit(FailureGetAuditLogsState(
            message: failure.message ?? 'Failed to fetch audit logs')),
        (success) {
          _cachedAuditLogs = success;
          emit(SuccessGetAuditLogsState(logs: success));
        },
      );
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
