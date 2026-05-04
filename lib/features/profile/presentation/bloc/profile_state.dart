part of 'profile_bloc.dart';

abstract class ProfileState {}

class InitialProfileState extends ProfileState {}

class LoadingProfileState extends ProfileState {}

class DateOfBirthProfileState extends ProfileState {
  final DateTime dob;
  DateOfBirthProfileState({required this.dob});
}

class ImageProfileState extends ProfileState {
  final XFile? profilePicture;
  ImageProfileState({this.profilePicture});
}

class ImagesProfileState extends ProfileState {
  final List<XFile>? images;
  ImagesProfileState({this.images});
}

class UserTypeProfileState extends ProfileState {
  final String userType;
  UserTypeProfileState({required this.userType});
}

class SuccessCreateProfileState extends ProfileState {}

class SuccessAddAboutState extends ProfileState {}

class SuccessDeleteAboutState extends ProfileState {}

class SuccessAddReviewState extends ProfileState {}

class SuccessUpdateProfileState extends ProfileState {}

class SuccessUpdateTokenState extends ProfileState {}

class SuccessGetProfileState extends ProfileState {
  static Profile lastProfile = Profile();
  final Profile profile;
  SuccessGetProfileState({required this.profile}) {
    SuccessGetProfileState.lastProfile = profile;
  }
}

class SuccessGetProfileStreamState extends ProfileState {
  final Future<Profile> profile;
  SuccessGetProfileStreamState({required this.profile});
}

class SuccessGetAboutStreamState extends ProfileState {
  final Future<AboutData> about;
  SuccessGetAboutStreamState({required this.about});
}

class SuccessGetReviewStreamState extends ProfileState {
  final Future<List<ReviewData>> reviews;
  SuccessGetReviewStreamState({required this.reviews});
}

class SuccessGetAuditLogsState extends ProfileState {
  final List<AuditLog> logs;
  SuccessGetAuditLogsState({required this.logs});
}

class FailureGetAuditLogsState extends ProfileState {
  final String message;
  FailureGetAuditLogsState({required this.message});
}

class FailureGetProfileState extends ProfileState {
  final String message;
  FailureGetProfileState({required this.message});
}

class FailureGetProfileStreamState extends ProfileState {
  final String message;
  FailureGetProfileStreamState({required this.message});
}

class FailureUpdateTokenState extends ProfileState {
  final String message;
  FailureUpdateTokenState({required this.message});
}

class FailureGetAboutState extends ProfileState {
  final String message;
  FailureGetAboutState({required this.message});
}

class FailureGetReviewsStreamState extends ProfileState {
  final String message;
  FailureGetReviewsStreamState({required this.message});
}

class FailureCreateProfileState extends ProfileState {
  final String message;
  FailureCreateProfileState({required this.message});
}

class FailureUpdateProfileState extends ProfileState {
  final String message;
  FailureUpdateProfileState({required this.message});
}

class FailureAddAboutState extends ProfileState {
  final String message;
  FailureAddAboutState({required this.message});
}

class FailureDeleteAboutState extends ProfileState {
  final String message;
  FailureDeleteAboutState({required this.message});
}

class FailureAddReviewState extends ProfileState {
  final String message;
  FailureAddReviewState({required this.message});
}

class PortfolioUserState extends ProfileState {
  static String lastUserId = "";
  final String userId;
  PortfolioUserState({required this.userId}) {
    PortfolioUserState.lastUserId = userId;
  }
}

class OtherServiceSelectState extends ProfileState {
  static bool lastOthers = false;
  final bool others;
  OtherServiceSelectState({required this.others}) {
    OtherServiceSelectState.lastOthers = others;
  }
}

class SuccessInitiateBackgroundCheckState extends ProfileState {
  final String url;
  SuccessInitiateBackgroundCheckState({required this.url});
}

class FailureInitiateBackgroundCheckState extends ProfileState {
  final String message;
  FailureInitiateBackgroundCheckState({required this.message});
}


