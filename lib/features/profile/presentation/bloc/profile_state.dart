part of 'profile_bloc.dart';

abstract class ProfileState {}

class InitialProfileState extends ProfileState {}

class LoadingProfileState extends ProfileState {}

class DateOfBirthProfileState extends ProfileState {
  static DateTime dob = DateTime.now().subtract(Duration(days: (365 * 18)));
}

class ImageProfileState extends ProfileState {
  static XFile? profilePicture;
}

class ImagesProfileState extends ProfileState {
  static List<XFile>? images;
}

class UserTypeProfileState extends ProfileState {
  static String userType = 'provider';
}

class FailureCreateProfileState extends ProfileState {}

class FailureUpdateProfileState extends ProfileState {}

class FailureAddAboutState extends ProfileState {}

class FailureDeleteAboutState extends ProfileState {}

class FailureAddReviewState extends ProfileState {}

class SuccessCreateProfileState extends ProfileState {}

class SuccessAddAboutState extends ProfileState {}

class SuccessDeleteAboutState extends ProfileState {}

class SuccessAddReviewState extends ProfileState {}

class SuccessUpdateProfileState extends ProfileState {}

class SuccessUpdateTokenState extends ProfileState {}

class SuccessGetProfileState extends ProfileState {
  static Profile profile = Profile();
}

class SuccessGetProfileStreamState extends ProfileState {
  static Future<Profile>? profile;
}

class SuccessGetAboutStreamState extends ProfileState {
  static Future<AboutData>? about;
}

class SuccessGetReviewStreamState extends ProfileState {
  static Future<List<ReviewData>>? reviews;
}

class FailureGetProfileState extends ProfileState {}

class FailureGetProfileStreamState extends ProfileState {}

class FailureUpdateTokenState extends ProfileState {}

class FailureGetAboutState extends ProfileState {}

class FailureGetReviewsStreamState extends ProfileState {}

class PortfolioUserState extends ProfileState {
  static String userId = "";
}

class OtherServiceSelectState extends ProfileState {
  static bool others = false;
}
