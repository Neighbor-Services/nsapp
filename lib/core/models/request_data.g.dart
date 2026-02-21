// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RequestDataAdapter extends TypeAdapter<RequestData> {
  @override
  final int typeId = 13;

  @override
  RequestData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RequestData(
      request: fields[0] as Request?,
      user: fields[1] as Profile?,
      approvedUser: fields[2] as Profile?,
    );
  }

  @override
  void write(BinaryWriter writer, RequestData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.request)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.approvedUser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
