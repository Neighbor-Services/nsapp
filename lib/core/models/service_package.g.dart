// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_package.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServicePackageAdapter extends TypeAdapter<ServicePackage> {
  @override
  final int typeId = 4;

  @override
  ServicePackage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServicePackage(
      id: fields[0] as String?,
      profile: fields[1] as String?,
      name: fields[2] as String?,
      price: fields[3] as double?,
      description: fields[4] as String?,
      deliveryTime: fields[5] as int?,
      revisions: fields[6] as int?,
      features: (fields[7] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ServicePackage obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profile)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.deliveryTime)
      ..writeByte(6)
      ..write(obj.revisions)
      ..writeByte(7)
      ..write(obj.features);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServicePackageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
