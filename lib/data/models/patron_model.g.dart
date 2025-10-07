// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patron_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatronModelAdapter extends TypeAdapter<PatronModel> {
  @override
  final int typeId = 6;

  @override
  PatronModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PatronModel(
      id: fields[0] as String,
      name: fields[1] as String,
      surname: fields[2] as String?,
      type: fields[3] as PatronType,
      phone: fields[4] as String,
      email: fields[5] as String?,
      address: fields[6] as String?,
      taxOffice: fields[7] as String?,
      taxNumber: fields[8] as String?,
      tcKimlikNo: fields[9] as String?,
      companyName: fields[10] as String?,
      authorizedPerson: fields[11] as String?,
      iban: fields[12] as String?,
      notes: fields[13] as String?,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime?,
      isActive: fields[16] as bool,
      projectIds: (fields[17] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PatronModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.surname)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.taxOffice)
      ..writeByte(8)
      ..write(obj.taxNumber)
      ..writeByte(9)
      ..write(obj.tcKimlikNo)
      ..writeByte(10)
      ..write(obj.companyName)
      ..writeByte(11)
      ..write(obj.authorizedPerson)
      ..writeByte(12)
      ..write(obj.iban)
      ..writeByte(13)
      ..write(obj.notes)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.isActive)
      ..writeByte(17)
      ..write(obj.projectIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatronModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PatronTypeAdapter extends TypeAdapter<PatronType> {
  @override
  final int typeId = 7;

  @override
  PatronType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PatronType.individual;
      case 1:
        return PatronType.company;
      default:
        return PatronType.individual;
    }
  }

  @override
  void write(BinaryWriter writer, PatronType obj) {
    switch (obj) {
      case PatronType.individual:
        writer.writeByte(0);
        break;
      case PatronType.company:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatronTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
