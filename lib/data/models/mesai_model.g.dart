// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mesai_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MesaiModelAdapter extends TypeAdapter<MesaiModel> {
  @override
  final int typeId = 8;

  @override
  MesaiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MesaiModel(
      id: fields[0] as String,
      employeeId: fields[1] as String,
      projectId: fields[2] as String,
      date: fields[3] as DateTime,
      checkInTime: fields[4] as DateTime?,
      checkOutTime: fields[5] as DateTime?,
      workHours: fields[6] as double?,
      dailyWage: fields[7] as double,
      totalPay: fields[8] as double,
      type: fields[9] as MesaiType,
      status: fields[10] as MesaiStatus,
      notes: fields[11] as String?,
      isPaid: fields[12] as bool,
      paidDate: fields[13] as DateTime?,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime?,
      location: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MesaiModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.projectId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.checkInTime)
      ..writeByte(5)
      ..write(obj.checkOutTime)
      ..writeByte(6)
      ..write(obj.workHours)
      ..writeByte(7)
      ..write(obj.dailyWage)
      ..writeByte(8)
      ..write(obj.totalPay)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.isPaid)
      ..writeByte(13)
      ..write(obj.paidDate)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.location);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MesaiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MesaiTypeAdapter extends TypeAdapter<MesaiType> {
  @override
  final int typeId = 9;

  @override
  MesaiType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MesaiType.regular;
      case 1:
        return MesaiType.overtime;
      case 2:
        return MesaiType.weekend;
      case 3:
        return MesaiType.holiday;
      default:
        return MesaiType.regular;
    }
  }

  @override
  void write(BinaryWriter writer, MesaiType obj) {
    switch (obj) {
      case MesaiType.regular:
        writer.writeByte(0);
        break;
      case MesaiType.overtime:
        writer.writeByte(1);
        break;
      case MesaiType.weekend:
        writer.writeByte(2);
        break;
      case MesaiType.holiday:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MesaiTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MesaiStatusAdapter extends TypeAdapter<MesaiStatus> {
  @override
  final int typeId = 10;

  @override
  MesaiStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MesaiStatus.pending;
      case 1:
        return MesaiStatus.approved;
      case 2:
        return MesaiStatus.rejected;
      default:
        return MesaiStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, MesaiStatus obj) {
    switch (obj) {
      case MesaiStatus.pending:
        writer.writeByte(0);
        break;
      case MesaiStatus.approved:
        writer.writeByte(1);
        break;
      case MesaiStatus.rejected:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MesaiStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
