// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gelir_gider_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GelirGiderModelAdapter extends TypeAdapter<GelirGiderModel> {
  @override
  final int typeId = 11;

  @override
  GelirGiderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GelirGiderModel(
      id: fields[0] as String,
      type: fields[1] as TransactionType,
      category: fields[2] as String,
      amount: fields[3] as double,
      projectId: fields[4] as String?,
      employeeId: fields[5] as String?,
      patronId: fields[6] as String?,
      date: fields[7] as DateTime,
      description: fields[8] as String,
      paymentMethod: fields[9] as PaymentMethod,
      invoiceNumber: fields[10] as String?,
      receiptImageUrl: fields[11] as String?,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime?,
      notes: fields[14] as String?,
      isRecurring: fields[15] as bool,
      recurringPeriod: fields[16] as RecurringPeriod?,
    );
  }

  @override
  void write(BinaryWriter writer, GelirGiderModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.projectId)
      ..writeByte(5)
      ..write(obj.employeeId)
      ..writeByte(6)
      ..write(obj.patronId)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.paymentMethod)
      ..writeByte(10)
      ..write(obj.invoiceNumber)
      ..writeByte(11)
      ..write(obj.receiptImageUrl)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.isRecurring)
      ..writeByte(16)
      ..write(obj.recurringPeriod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GelirGiderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 12;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      default:
        return TransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
        break;
      case TransactionType.expense:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentMethodAdapter extends TypeAdapter<PaymentMethod> {
  @override
  final int typeId = 13;

  @override
  PaymentMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMethod.cash;
      case 1:
        return PaymentMethod.bankTransfer;
      case 2:
        return PaymentMethod.creditCard;
      case 3:
        return PaymentMethod.check;
      case 4:
        return PaymentMethod.other;
      default:
        return PaymentMethod.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMethod obj) {
    switch (obj) {
      case PaymentMethod.cash:
        writer.writeByte(0);
        break;
      case PaymentMethod.bankTransfer:
        writer.writeByte(1);
        break;
      case PaymentMethod.creditCard:
        writer.writeByte(2);
        break;
      case PaymentMethod.check:
        writer.writeByte(3);
        break;
      case PaymentMethod.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringPeriodAdapter extends TypeAdapter<RecurringPeriod> {
  @override
  final int typeId = 14;

  @override
  RecurringPeriod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurringPeriod.daily;
      case 1:
        return RecurringPeriod.weekly;
      case 2:
        return RecurringPeriod.monthly;
      case 3:
        return RecurringPeriod.yearly;
      default:
        return RecurringPeriod.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurringPeriod obj) {
    switch (obj) {
      case RecurringPeriod.daily:
        writer.writeByte(0);
        break;
      case RecurringPeriod.weekly:
        writer.writeByte(1);
        break;
      case RecurringPeriod.monthly:
        writer.writeByte(2);
        break;
      case RecurringPeriod.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringPeriodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
