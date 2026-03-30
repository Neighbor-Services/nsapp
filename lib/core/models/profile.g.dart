// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileAdapter extends TypeAdapter<Profile> {
  @override
  final int typeId = 0;

  @override
  Profile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Profile(
      id: fields[0] as String?,
      user: fields[1] as User?,
      firstName: fields[2] as String?,
      lastName: fields[3] as String?,
      dateOfBirth: fields[4] as DateTime?,
      service: fields[5] as String?,
      country: fields[6] as String?,
      state: fields[7] as String?,
      zipCode: fields[8] as String?,
      gender: fields[9] as String?,
      countryCode: fields[10] as String?,
      phone: fields[11] as String?,
      city: fields[12] as String?,
      ratings: (fields[13] as List?)?.cast<dynamic>(),
      address: fields[14] as String?,
      rating: fields[15] as String?,
      deviceToken: fields[16] as String?,
      profilePictureUrl: fields[17] as String?,
      userType: fields[18] as String?,
      longitude: fields[19] as String?,
      latitude: fields[20] as String?,
      createdAt: fields[21] as DateTime?,
      updatedAt: fields[22] as DateTime?,
      version: fields[23] as int?,
      averageRating: fields[24] as double?,
      totalReviews: fields[25] as int?,
      bio: fields[28] as String?,
      catalogServiceId: fields[29] as String?,
      isIdentityVerified: fields[31] as bool?,
      subscriptionTier: fields[32] as String?,
      performanceBadges: (fields[33] as List?)?.cast<PerformanceBadge>(),
      preferredPaymentMode: fields[34] as String?,
    )
      ..portfolioItems = (fields[26] as List?)?.cast<PortfolioItem>()
      ..servicePackages = (fields[27] as List?)?.cast<ServicePackage>()
      ..catalogServiceName = fields[30] as String?;
  }

  @override
  void write(BinaryWriter writer, Profile obj) {
    writer
      ..writeByte(35)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.lastName)
      ..writeByte(4)
      ..write(obj.dateOfBirth)
      ..writeByte(5)
      ..write(obj.service)
      ..writeByte(6)
      ..write(obj.country)
      ..writeByte(7)
      ..write(obj.state)
      ..writeByte(8)
      ..write(obj.zipCode)
      ..writeByte(9)
      ..write(obj.gender)
      ..writeByte(10)
      ..write(obj.countryCode)
      ..writeByte(11)
      ..write(obj.phone)
      ..writeByte(12)
      ..write(obj.city)
      ..writeByte(13)
      ..write(obj.ratings)
      ..writeByte(14)
      ..write(obj.address)
      ..writeByte(15)
      ..write(obj.rating)
      ..writeByte(16)
      ..write(obj.deviceToken)
      ..writeByte(17)
      ..write(obj.profilePictureUrl)
      ..writeByte(18)
      ..write(obj.userType)
      ..writeByte(19)
      ..write(obj.longitude)
      ..writeByte(20)
      ..write(obj.latitude)
      ..writeByte(21)
      ..write(obj.createdAt)
      ..writeByte(22)
      ..write(obj.updatedAt)
      ..writeByte(23)
      ..write(obj.version)
      ..writeByte(24)
      ..write(obj.averageRating)
      ..writeByte(25)
      ..write(obj.totalReviews)
      ..writeByte(26)
      ..write(obj.portfolioItems)
      ..writeByte(27)
      ..write(obj.servicePackages)
      ..writeByte(28)
      ..write(obj.bio)
      ..writeByte(29)
      ..write(obj.catalogServiceId)
      ..writeByte(30)
      ..write(obj.catalogServiceName)
      ..writeByte(31)
      ..write(obj.isIdentityVerified)
      ..writeByte(32)
      ..write(obj.subscriptionTier)
      ..writeByte(33)
      ..write(obj.performanceBadges)
      ..writeByte(34)
      ..write(obj.preferredPaymentMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
