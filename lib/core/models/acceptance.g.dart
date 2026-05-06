// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acceptance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AcceptanceAdapter extends TypeAdapter<Acceptance> {
  @override
  final int typeId = 16;

  @override
  Acceptance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Acceptance(
      id: fields[0] as String?,
      providerId: fields[1] as String?,
      isApproved: fields[2] as bool?,
      request: fields[3] as Request?,
      createdAt: fields[4] as String?,
      updatedAt: fields[5] as String?,
      version: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Acceptance obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.providerId)
      ..writeByte(2)
      ..write(obj.isApproved)
      ..writeByte(3)
      ..write(obj.request)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcceptanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
