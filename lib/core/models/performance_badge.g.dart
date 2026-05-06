// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_badge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PerformanceBadgeAdapter extends TypeAdapter<PerformanceBadge> {
  @override
  final int typeId = 100;

  @override
  PerformanceBadge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PerformanceBadge(
      name: fields[0] as String?,
      iconType: fields[1] as String?,
      description: fields[2] as String?,
      awardedAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PerformanceBadge obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.iconType)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.awardedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerformanceBadgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
