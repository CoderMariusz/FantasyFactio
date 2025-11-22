// GENERATED CODE - DO NOT MODIFY BY HAND (manually created for Hive)

part of 'building.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionConfigAdapter extends TypeAdapter<ProductionConfig> {
  @override
  final int typeId = 6;

  @override
  ProductionConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionConfig(
      baseRate: fields[0] as double,
      resourceType: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionConfig obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.baseRate)
      ..writeByte(1)
      ..write(obj.resourceType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UpgradeConfigAdapter extends TypeAdapter<UpgradeConfig> {
  @override
  final int typeId = 7;

  @override
  UpgradeConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpgradeConfig(
      baseCost: fields[0] as int,
      costIncrement: fields[1] as int,
      maxLevel: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UpgradeConfig obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.baseCost)
      ..writeByte(1)
      ..write(obj.costIncrement)
      ..writeByte(2)
      ..write(obj.maxLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpgradeConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
      type: fields[1] as BuildingType,
      level: fields[2] as int,
      gridPosition: fields[3] as GridPosition,
      production: fields[4] as ProductionConfig,
      upgradeConfig: fields[5] as UpgradeConfig,
      lastCollected: fields[6] as DateTime,
      isActive: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Building obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.gridPosition)
      ..writeByte(4)
      ..write(obj.production)
      ..writeByte(5)
      ..write(obj.upgradeConfig)
      ..writeByte(6)
      ..write(obj.lastCollected)
      ..writeByte(7)
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
