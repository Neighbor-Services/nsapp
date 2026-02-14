// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 11;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      id: fields[0] as String?,
      stripeCustomerId: fields[1] as String?,
      ephemeralSecret: fields[4] as String?,
      createdAt: fields[5] as String?,
      updatedAt: fields[6] as String?,
    )
      ..accountId = fields[2] as String?
      ..paymentMethod = fields[3] as String?;
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.stripeCustomerId)
      ..writeByte(2)
      ..write(obj.accountId)
      ..writeByte(3)
      ..write(obj.paymentMethod)
      ..writeByte(4)
      ..write(obj.ephemeralSecret)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomerDataAdapter extends TypeAdapter<CustomerData> {
  @override
  final int typeId = 12;

  @override
  CustomerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerData(
      customer: fields[0] as Customer?,
      user: fields[1] as Profile?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerData obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.customer)
      ..writeByte(1)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
