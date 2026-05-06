// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WalletAdapter extends TypeAdapter<Wallet> {
  @override
  final int typeId = 22;

  @override
  Wallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Wallet(
      id: fields[0] as String?,
      user: fields[1] as String?,
      balance: fields[2] as double?,
      currency: fields[3] as String?,
      stripeConnectId: fields[4] as String?,
      transactions: (fields[5] as List?)?.cast<WalletTransaction>(),
      payoutRequests: (fields[6] as List?)?.cast<PayoutRequest>(),
    );
  }

  @override
  void write(BinaryWriter writer, Wallet obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.user)
      ..writeByte(2)
      ..write(obj.balance)
      ..writeByte(3)
      ..write(obj.currency)
      ..writeByte(4)
      ..write(obj.stripeConnectId)
      ..writeByte(5)
      ..write(obj.transactions)
      ..writeByte(6)
      ..write(obj.payoutRequests);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WalletTransactionAdapter extends TypeAdapter<WalletTransaction> {
  @override
  final int typeId = 23;

  @override
  WalletTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WalletTransaction(
      id: fields[0] as String?,
      amount: fields[1] as double?,
      transactionType: fields[2] as String?,
      description: fields[3] as String?,
      status: fields[4] as String?,
      referenceId: fields[5] as String?,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WalletTransaction obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.transactionType)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.referenceId)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PayoutRequestAdapter extends TypeAdapter<PayoutRequest> {
  @override
  final int typeId = 24;

  @override
  PayoutRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PayoutRequest(
      id: fields[0] as String?,
      amount: fields[1] as double?,
      status: fields[2] as String?,
      createdAt: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PayoutRequest obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayoutRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
