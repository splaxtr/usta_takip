// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectModelAdapter extends TypeAdapter<ProjectModel> {
  @override
  final int typeId = 2;

  @override
  ProjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      patronId: fields[3] as String,
      location: fields[4] as String?,
      status: fields[5] as ProjectStatus,
      startDate: fields[6] as DateTime,
      endDate: fields[7] as DateTime?,
      budget: fields[8] as double,
      employeeIds: (fields[9] as List?)?.cast<String>(),
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime?,
      imageUrl: fields[12] as String?,
      notes: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.patronId)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.budget)
      ..writeByte(9)
      ..write(obj.employeeIds)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.imageUrl)
      ..writeByte(13)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProjectStatusAdapter extends TypeAdapter<ProjectStatus> {
  @override
  final int typeId = 3;

  @override
  ProjectStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProjectStatus.planning;
      case 1:
        return ProjectStatus.inProgress;
      case 2:
        return ProjectStatus.onHold;
      case 3:
        return ProjectStatus.completed;
      case 4:
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.planning;
    }
  }

  @override
  void write(BinaryWriter writer, ProjectStatus obj) {
    switch (obj) {
      case ProjectStatus.planning:
        writer.writeByte(0);
        break;
      case ProjectStatus.inProgress:
        writer.writeByte(1);
        break;
      case ProjectStatus.onHold:
        writer.writeByte(2);
        break;
      case ProjectStatus.completed:
        writer.writeByte(3);
        break;
      case ProjectStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
