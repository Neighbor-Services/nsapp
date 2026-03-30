// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 6;

  @override
  Appointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appointment(
      id: fields[0] as String?,
      title: fields[1] as String?,
      seekerId: fields[2] as String?,
      description: fields[3] as String?,
      appointmentDate: fields[7] as DateTime?,
      chatID: fields[6] as String?,
      fromChat: fields[8] as bool?,
      fromUser: fields[9] as String?,
      createdAt: fields[10] as DateTime?,
      updatedAt: fields[11] as DateTime?,
      version: fields[12] as int?,
      status: fields[13] as String?,
      providerId: fields[14] as String?,
      isConsultation: fields[16] as bool?,
      consultationChannel: fields[17] as String?,
      isFunded: fields[18] as bool?,
      paymentIntentId: fields[19] as String?,
      totalPrice: fields[20] as double?,
      proposalId: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.seekerId)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.appointmentDate)
      ..writeByte(6)
      ..write(obj.chatID)
      ..writeByte(8)
      ..write(obj.fromChat)
      ..writeByte(9)
      ..write(obj.fromUser)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.version)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.providerId)
      ..writeByte(16)
      ..write(obj.isConsultation)
      ..writeByte(17)
      ..write(obj.consultationChannel)
      ..writeByte(18)
      ..write(obj.isFunded)
      ..writeByte(19)
      ..write(obj.paymentIntentId)
      ..writeByte(20)
      ..write(obj.totalPrice)
      ..writeByte(21)
      ..write(obj.proposalId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppointmentDataAdapter extends TypeAdapter<AppointmentData> {
  @override
  final int typeId = 7;

  @override
  AppointmentData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppointmentData(
      appointment: fields[0] as Appointment?,
      user: fields[1] as Profile?,
      role: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.appointment)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.role);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
