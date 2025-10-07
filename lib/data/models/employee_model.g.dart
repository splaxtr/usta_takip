// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmployeeModelAdapter extends TypeAdapter<EmployeeModel> {
  @override
  final int typeId = 4;

  @override
  EmployeeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmployeeModel(
      id: fields[0] as String,
      name: fields[1] as String,
      surname: fields[2] as String,
      tcKimlikNo: fields[3] as String?,
      phone: fields[4] as String,
      email: fields[5] as String?,
      address: fields[6] as String?,
      birthDate: fields[7] as DateTime?,
      avatarUrl: fields[8] as String?,
      position: fields[9] as String,
      dailyWage: fields[10] as double,
      status: fields[11] as EmployeeStatus,
      hireDate: fields[12] as DateTime,
      terminationDate: fields[13] as DateTime?,
      notes: fields[14] as String?,
      createdAt: fields[15] as DateTime,
      updatedAt: fields[16] as DateTime?,
      emergencyContactName: fields[17] as String?,
      emergencyContactPhone: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EmployeeModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.surname)
      ..writeByte(3)
      ..write(obj.tcKimlikNo)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.birthDate)
      ..writeByte(8)
      ..write(obj.avatarUrl)
      ..writeByte(9)
      ..write(obj.position)
      ..writeByte(10)
      ..write(obj.dailyWage)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.hireDate)
      ..writeByte(13)
      ..write(obj.terminationDate)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.emergencyContactName)
      ..writeByte(18)
      ..write(obj.emergencyContactPhone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EmployeeStatusAdapter extends TypeAdapter<EmployeeStatus> {
  @override
  final int typeId = 5;

  @override
  EmployeeStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EmployeeStatus.active;
      case 1:
        return EmployeeStatus.onLeave;
      case 2:
        return EmployeeStatus.terminated;
      case 3:
        return EmployeeStatus.suspended;
      default:
        return EmployeeStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, EmployeeStatus obj) {
    switch (obj) {
      case EmployeeStatus.active:
        writer.writeByte(0);
        break;
      case EmployeeStatus.onLeave:
        writer.writeByte(1);
        break;
      case EmployeeStatus.terminated:
        writer.writeByte(2);
        break;
      case EmployeeStatus.suspended:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
