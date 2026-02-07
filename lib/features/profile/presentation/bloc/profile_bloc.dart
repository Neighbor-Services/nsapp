import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
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

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
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
  ) : super(InitialProfileState()) {
    on<SelectDateOfBirthEvent>((event, emit) async {
      final date = await Helpers.selectBirthDate(event.context);
      if (date != null) {
        DateOfBirthProfileState.dob = date;
      }
      emit(DateOfBirthProfileState());
    });
    on<SelectImageFromGalleryEvent>((event, emit) async {
      await Helpers.selectImageFromGallery();
      if (image != null) {
        ImageProfileState.profilePicture = image;
      }
      emit(ImageProfileState());
    });

    on<AboutUserEvent>((event, emit) async {
      PortfolioUserState.userId = event.userID;
      emit(PortfolioUserState());
    });

    on<SelectImagesFromGalleryEvent>((event, emit) async {
      await Helpers.selectImagesFromGallery();
      if (images != null && images!.isNotEmpty) {
        ImagesProfileState.images = images;
      }
      emit(ImagesProfileState());
    });
    on<SelectImageFromCameraEvent>((event, emit) async {
      await Helpers.selectImageFromCamera();
      if (image != null) {
        ImageProfileState.profilePicture = image;
      }
      emit(ImageProfileState());
    });
    on<SetUserTypeEvent>((event, emit) async {
      UserTypeProfileState.userType = event.userType;
      emit(UserTypeProfileState());
    });
    on<AddProfileEvent>((event, emit) async {
      emit(LoadingProfileState());
      // Ensure global image variable is set for upload
      if (ImageProfileState.profilePicture != null) {
        image = ImageProfileState.profilePicture;
      }
      final results = await addProfileUseCase.call(event.profile);
      results.fold(
        (failure) => emit(FailureCreateProfileState()),
        (success) => emit(SuccessCreateProfileState()),
      );
    });

    on<UpdateTokenEvent>((event, emit) async {
      final results = await updateDeviceTokenUseCase.call(event);
      results.fold(
        (failure) => emit(FailureUpdateTokenState()),
        (success) => emit(SuccessUpdateTokenState()),
      );
    });

    on<AddReviewEvent>((event, emit) async {
      emit(LoadingProfileState());
      final results = await addReviewUseCase.call(event.review);
      results.fold(
        (failure) => emit(FailureAddReviewState()),
        (success) => emit(SuccessAddReviewState()),
      );
    });
    on<AddAboutEvent>((event, emit) async {
      emit(LoadingProfileState());
      final results = await addAboutUseCase.call(event.about);
      results.fold(
        (failure) => emit(FailureAddAboutState()),
        (success) => emit(SuccessAddAboutState()),
      );
    });
    on<DeleteAboutUserEvent>((event, emit) async {
      emit(LoadingProfileState());
      final results = await deleteAboutUseCase.call(event.id);
      results.fold(
        (failure) => emit(FailureDeleteAboutState()),
        (success) => emit(SuccessDeleteAboutState()),
      );
    });
    on<UpdateProfileEvent>((event, emit) async {
      emit(LoadingProfileState());
      // Ensure global image variable is set for upload
      if (ImageProfileState.profilePicture != null) {
        image = ImageProfileState.profilePicture;
      }
      final results = await updateProfileUseCase.call(event.profile);
      results.fold(
        (failure) => emit(FailureUpdateProfileState()),
        (success) => emit(SuccessUpdateProfileState()),
      );
    });
    on<GetProfileStreamEvent>((event, emit) async {
      final results = await getProfileStreamUseCase.call(event);
      results.fold((failure) => emit(FailureGetProfileStreamState()), (
        success,
      ) {
        SuccessGetProfileStreamState.profile = Future.value(success);
        emit(SuccessGetProfileStreamState());
      });
    }, transformer: sequential());
    on<GetProfileEvent>((event, emit) async {
      final results = await getProfileStreamUseCase.call(event);

      results.fold((failure) => emit(FailureGetProfileState()), (success) {
        SuccessGetProfileState.profile = success;
        emit(SuccessGetProfileState());
      });
    });

    on<GetAboutEvent>((event, emit) async {
      final results = await getAboutUseCase.call(event.user);
      results.fold(
        (failure) {
          SuccessGetAboutStreamState.about = Future.value(AboutData());
          emit(FailureGetAboutState());
        },
        (success) {
          SuccessGetAboutStreamState.about = Future.value(success);

          emit(SuccessGetAboutStreamState());
        },
      );
    }, transformer: sequential());
    on<GetReviewsEvent>((event, emit) async {
      final results = await getReviewsUseCase.call(event.user);
      results.fold(
        (failure) {
          SuccessGetReviewStreamState.reviews = Future.value([]);
          emit(FailureGetReviewsStreamState());
        },
        (success) {
          SuccessGetReviewStreamState.reviews = Future.value(success);

          emit(SuccessGetReviewStreamState());
        },
      );
    }, transformer: sequential());
    on<ChooseOtherServiceEvent>((event, emit) {
      OtherServiceSelectState.others = event.others;
      emit(OtherServiceSelectState());
    });
  }
}
