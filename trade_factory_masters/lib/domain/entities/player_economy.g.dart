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
      playerId: fields[0] as String,
      gold: fields[1] as int,
      resources: (fields[2] as List).cast<Resource>(),
      buildings: (fields[3] as List).cast<Building>(),
      lastUpdated: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerEconomy obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.playerId)
      ..writeByte(1)
      ..write(obj.gold)
      ..writeByte(2)
      ..write(obj.resources)
      ..writeByte(3)
      ..write(obj.buildings)
      ..writeByte(4)
      ..write(obj.lastUpdated);
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
