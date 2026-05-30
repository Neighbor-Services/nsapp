part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class SelectDateOfBirthEvent extends ProfileEvent {
  final BuildContext context;
  SelectDateOfBirthEvent({required this.context});
}

class SelectImageFromCameraEvent extends ProfileEvent {}

class UpdateTokenEvent extends ProfileEvent {}

class SelectImageFromGalleryEvent extends ProfileEvent {}

class SelectImagesFromGalleryEvent extends ProfileEvent {}

class SetUserTypeEvent extends ProfileEvent {
  final String userType;
  SetUserTypeEvent({required this.userType});
}

class GetAboutEvent extends ProfileEvent {
  final String user;
  GetAboutEvent({required this.user});
}

class GetReviewsEvent extends ProfileEvent {
  final String user;
  GetReviewsEvent({required this.user});
}

class AddProfileEvent extends ProfileEvent {
  final Profile profile;
  final String? profilePicturePath;

  AddProfileEvent({required this.profile, this.profilePicturePath});
}

class GetProfileEvent extends ProfileEvent {}

class GetProfileStreamEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final Profile profile;
  final String? profilePicturePath;

  UpdateProfileEvent({required this.profile, this.profilePicturePath});
}

class GetAuditLogsEvent extends ProfileEvent {}

class LogoutProfileEvent extends ProfileEvent {}

class AddAboutEvent extends ProfileEvent {
  final About about;

  AddAboutEvent({required this.about});
}

class AddReviewEvent extends ProfileEvent {
  final Review review;

  AddReviewEvent({required this.review});
}

class AboutUserEvent extends ProfileEvent {
  final String userID;

  AboutUserEvent({required this.userID});
}

class ChooseOtherServiceEvent extends ProfileEvent {
  final bool others;

  ChooseOtherServiceEvent({required this.others});
}

class DeleteAboutUserEvent extends ProfileEvent {
  final String id;

  DeleteAboutUserEvent({required this.id});
}

class InitiateBackgroundCheckEvent extends ProfileEvent {
  final String paymentIntentId;
  InitiateBackgroundCheckEvent({required this.paymentIntentId});
}

class CreateStripeCustomerEvent extends ProfileEvent {
  final String userId;
  CreateStripeCustomerEvent({required this.userId});
}



