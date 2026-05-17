part of 'profile_bloc.dart';

sealed class ProfileState {
  final Profile? profile;
  ProfileState({this.profile});
}

class InitialProfileState extends ProfileState {
  InitialProfileState({super.profile});
}

class LoadingProfileState extends ProfileState {
  LoadingProfileState({super.profile});
}

class LoadingAuditLogsState extends ProfileState {
  LoadingAuditLogsState({super.profile});
}

class DateOfBirthProfileState extends ProfileState {
  final DateTime dob;
  DateOfBirthProfileState({required this.dob, super.profile});
}

class ImageProfileState extends ProfileState {
  final XFile? profilePicture;
  ImageProfileState({this.profilePicture, super.profile});
}

class ImagesProfileState extends ProfileState {
  final List<XFile>? images;
  ImagesProfileState({this.images, super.profile});
}

class UserTypeProfileState extends ProfileState {
  final String userType;
  UserTypeProfileState({required this.userType, super.profile});
}

class SuccessCreateProfileState extends ProfileState {
  SuccessCreateProfileState({super.profile});
}

class SuccessAddAboutState extends ProfileState {
  SuccessAddAboutState({super.profile});
}

class SuccessDeleteAboutState extends ProfileState {
  SuccessDeleteAboutState({super.profile});
}

class SuccessAddReviewState extends ProfileState {
  SuccessAddReviewState({super.profile});
}

class SuccessUpdateProfileState extends ProfileState {
  SuccessUpdateProfileState({super.profile});
}

class SuccessUpdateTokenState extends ProfileState {
  SuccessUpdateTokenState({super.profile});
}

class SuccessGetProfileState extends ProfileState {
  @override
  final Profile profile;
  SuccessGetProfileState({required this.profile}) : super(profile: profile);
}

class SuccessGetProfileStreamState extends SuccessGetProfileState {
  SuccessGetProfileStreamState({required super.profile});
}

class SuccessGetAboutStreamState extends ProfileState {
  final AboutData about;
  SuccessGetAboutStreamState({required this.about, super.profile});
}

class SuccessGetReviewStreamState extends ProfileState {
  final List<ReviewData> reviews;
  SuccessGetReviewStreamState({required this.reviews, super.profile});
}

class SuccessGetAuditLogsState extends ProfileState {
  final List<AuditLog> logs;
  SuccessGetAuditLogsState({required this.logs, super.profile});
}

class FailureGetAuditLogsState extends ProfileState {
  final String message;
  FailureGetAuditLogsState({required this.message, super.profile});
}

class FailureGetProfileState extends ProfileState {
  final String message;
  FailureGetProfileState({required this.message, super.profile});
}

class FailureGetProfileStreamState extends ProfileState {
  final String message;
  FailureGetProfileStreamState({required this.message, super.profile});
}

class FailureUpdateTokenState extends ProfileState {
  final String message;
  FailureUpdateTokenState({required this.message, super.profile});
}

class FailureGetAboutState extends ProfileState {
  final String message;
  FailureGetAboutState({required this.message, super.profile});
}

class FailureGetReviewsStreamState extends ProfileState {
  final String message;
  FailureGetReviewsStreamState({required this.message, super.profile});
}

class FailureCreateProfileState extends ProfileState {
  final String message;
  FailureCreateProfileState({required this.message, super.profile});
}

class FailureUpdateProfileState extends ProfileState {
  final String message;
  FailureUpdateProfileState({required this.message, super.profile});
}

class FailureAddAboutState extends ProfileState {
  final String message;
  FailureAddAboutState({required this.message, super.profile});
}

class FailureDeleteAboutState extends ProfileState {
  final String message;
  FailureDeleteAboutState({required this.message, super.profile});
}

class FailureAddReviewState extends ProfileState {
  final String message;
  FailureAddReviewState({required this.message, super.profile});
}

class PortfolioUserState extends ProfileState {
  final String userId;
  PortfolioUserState({required this.userId, super.profile});
}

class OtherServiceSelectState extends ProfileState {
  final bool others;
  OtherServiceSelectState({required this.others, super.profile});
}

class SuccessInitiateBackgroundCheckState extends ProfileState {
  final String url;
  SuccessInitiateBackgroundCheckState({required this.url, super.profile});
}

class FailureInitiateBackgroundCheckState extends ProfileState {
  final String message;
  FailureInitiateBackgroundCheckState({required this.message, super.profile});
}
