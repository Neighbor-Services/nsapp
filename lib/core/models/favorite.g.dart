// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteAdapter extends TypeAdapter<Favorite> {
  @override
  final int typeId = 15;

  @override
  Favorite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Favorite(
      id: fields[0] as String?,
      user: fields[1] as Profile?,
      favoriteUser: fields[2] as Profile?,
      createdAt: fields[3] as DateTime?,
      version: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Favorite obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.favoriteUser)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
