// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_acceptance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RequestAcceptanceAdapter extends TypeAdapter<RequestAcceptance> {
  @override
  final int typeId = 14;

  @override
  RequestAcceptance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RequestAcceptance(
      acceptance: fields[0] as Acceptance?,
      provider: fields[1] as Profile?,
      user: fields[2] as Profile?,
    );
  }

  @override
  void write(BinaryWriter writer, RequestAcceptance obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.acceptance)
      ..writeByte(1)
      ..write(obj.provider)
      ..writeByte(2)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestAcceptanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
