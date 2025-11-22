// GENERATED CODE - DO NOT MODIFY BY HAND (manually created for Hive)

part of 'building.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuildingAdapter extends TypeAdapter<Building> {
  @override
  final int typeId = 2;

  @override
  Building read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Building(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as BuildingType,
      level: fields[3] as int,
      position: fields[4] as GridPosition,
      isActive: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Building obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.position)
      ..writeByte(5)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BuildingTypeAdapter extends TypeAdapter<BuildingType> {
  @override
  final int typeId = 3;

  @override
  BuildingType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BuildingType.collector;
      case 1:
        return BuildingType.processor;
      case 2:
        return BuildingType.storage;
      case 3:
        return BuildingType.conveyor;
      case 4:
        return BuildingType.market;
      default:
        return BuildingType.collector;
    }
  }

  @override
  void write(BinaryWriter writer, BuildingType obj) {
    switch (obj) {
      case BuildingType.collector:
        writer.writeByte(0);
        break;
      case BuildingType.processor:
        writer.writeByte(1);
        break;
      case BuildingType.storage:
        writer.writeByte(2);
        break;
      case BuildingType.conveyor:
        writer.writeByte(3);
        break;
      case BuildingType.market:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildingTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GridPositionAdapter extends TypeAdapter<GridPosition> {
  @override
  final int typeId = 4;

  @override
  GridPosition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GridPosition(
      x: fields[0] as int,
      y: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GridPosition obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.x)
      ..writeByte(1)
      ..write(obj.y);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridPositionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
