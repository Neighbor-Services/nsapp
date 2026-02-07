// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RequestAdapter extends TypeAdapter<Request> {
  @override
  final int typeId = 17;

  @override
  Request read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Request(
      id: fields[0] as String?,
      title: fields[1] as String?,
      description: fields[2] as String?,
      userId: fields[3] as String?,
      service: fields[4] as Service?,
      approved: fields[6] as bool?,
      address: fields[7] as String?,
      longitude: fields[9] as double?,
      latitude: fields[10] as double?,
      withImage: fields[11] as bool?,
      done: fields[12] as bool?,
      imageUrl: fields[13] as String?,
      approvedUser: fields[14] as String?,
      createdAt: fields[15] as DateTime?,
      updatedAt: fields[16] as DateTime?,
      version: fields[17] as int?,
      serviceID: fields[5] as String?,
      scheduledTime: fields[8] as DateTime?,
      distance: fields[18] as double?,
      status: fields[19] as String?,
      proposalsCount: fields[20] as int?,
      appointmentId: fields[21] as String?,
      isFunded: fields[22] as bool?,
      price: fields[23] as double?,
      targetProviderId: fields[24] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Request obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.userId)
      ..writeByte(4)
      ..write(obj.service)
      ..writeByte(5)
      ..write(obj.serviceID)
      ..writeByte(6)
      ..write(obj.approved)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.scheduledTime)
      ..writeByte(9)
      ..write(obj.longitude)
      ..writeByte(10)
      ..write(obj.latitude)
      ..writeByte(11)
      ..write(obj.withImage)
      ..writeByte(12)
      ..write(obj.done)
      ..writeByte(13)
      ..write(obj.imageUrl)
      ..writeByte(14)
      ..write(obj.approvedUser)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.version)
      ..writeByte(18)
      ..write(obj.distance)
      ..writeByte(19)
      ..write(obj.status)
      ..writeByte(20)
      ..write(obj.proposalsCount)
      ..writeByte(21)
      ..write(obj.appointmentId)
      ..writeByte(22)
      ..write(obj.isFunded)
      ..writeByte(23)
      ..write(obj.price)
      ..writeByte(24)
      ..write(obj.targetProviderId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
