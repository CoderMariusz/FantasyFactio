// GENERATED CODE - DO NOT MODIFY BY HAND (manually created for Hive)

part of 'player_economy.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerEconomyAdapter extends TypeAdapter<PlayerEconomy> {
  @override
  final int typeId = 5;

  @override
  PlayerEconomy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerEconomy(
      gold: fields[0] as int,
      inventory: (fields[1] as Map).cast<String, Resource>(),
      buildings: (fields[2] as List).cast<Building>(),
      tier: fields[3] as int,
      lastSeen: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerEconomy obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.gold)
      ..writeByte(1)
      ..write(obj.inventory)
      ..writeByte(2)
      ..write(obj.buildings)
      ..writeByte(3)
      ..write(obj.tier)
      ..writeByte(4)
      ..write(obj.lastSeen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerEconomyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
