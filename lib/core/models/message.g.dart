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
      calenderStartDate: fields[6] as DateTime?,
      calenderEndDate: fields[7] as DateTime?,
      calenderDate: fields[8] as DateTime?,
      sender: fields[9] as String?,
      receiver: fields[10] as String?,
      mediaUrl: fields[11] as String?,
      read: fields[12] as bool?,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
      version: fields[15] as int?,
      image: fields[16] as String?,
      fileName: fields[17] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(18)
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
      ..write(obj.calenderStartDate)
      ..writeByte(7)
      ..write(obj.calenderEndDate)
      ..writeByte(8)
      ..write(obj.calenderDate)
      ..writeByte(9)
      ..write(obj.sender)
      ..writeByte(10)
      ..write(obj.receiver)
      ..writeByte(11)
      ..write(obj.mediaUrl)
      ..writeByte(12)
      ..write(obj.read)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.version)
      ..writeByte(16)
      ..write(obj.image)
      ..writeByte(17)
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
