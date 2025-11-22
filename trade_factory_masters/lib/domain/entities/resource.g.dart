// GENERATED CODE - DO NOT MODIFY BY HAND (manually created for Hive)

part of 'resource.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResourceAdapter extends TypeAdapter<Resource> {
  @override
  final int typeId = 0;

  @override
  Resource read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Resource(
      id: fields[0] as String,
      displayName: fields[1] as String,
      type: fields[2] as ResourceType,
      amount: fields[3] as int,
      maxCapacity: fields[4] as int,
      iconPath: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Resource obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.maxCapacity)
      ..writeByte(5)
      ..write(obj.iconPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ResourceTypeAdapter extends TypeAdapter<ResourceType> {
  @override
  final int typeId = 1;

  @override
  ResourceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ResourceType.tier1;
      case 1:
        return ResourceType.tier2;
      case 2:
        return ResourceType.tier3;
      default:
        return ResourceType.tier1;
    }
  }

  @override
  void write(BinaryWriter writer, ResourceType obj) {
    switch (obj) {
      case ResourceType.tier1:
        writer.writeByte(0);
        break;
      case ResourceType.tier2:
        writer.writeByte(1);
        break;
      case ResourceType.tier3:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
