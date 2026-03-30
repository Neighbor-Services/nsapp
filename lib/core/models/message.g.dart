// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 5;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String?,
      chatRoomId: fields[1] as String?,
      withImage: fields[2] as bool?,
      isCalender: fields[3] as bool?,
      withImageAndText: fields[4] as bool?,
      message: fields[5] as String?,
      calenderDate: fields[6] as DateTime?,
      sender: fields[7] as String?,
      receiver: fields[8] as String?,
      mediaUrl: fields[9] as String?,
      read: fields[10] as bool?,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
      version: fields[13] as int?,
      image: fields[14] as String?,
      fileName: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chatRoomId)
      ..writeByte(2)
      ..write(obj.withImage)
      ..writeByte(3)
      ..write(obj.isCalender)
      ..writeByte(4)
      ..write(obj.withImageAndText)
      ..writeByte(5)
      ..write(obj.message)
      ..writeByte(6)
      ..write(obj.calenderDate)
      ..writeByte(7)
      ..write(obj.sender)
      ..writeByte(8)
      ..write(obj.receiver)
      ..writeByte(9)
      ..write(obj.mediaUrl)
      ..writeByte(10)
      ..write(obj.read)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.version)
      ..writeByte(14)
      ..write(obj.image)
      ..writeByte(15)
      ..write(obj.fileName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
