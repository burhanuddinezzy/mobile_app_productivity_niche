part of 'tree_model.dart';

class TreeTypeAdapter extends TypeAdapter<TreeType> {
  @override
  final int typeId = 0;

  @override
  TreeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TreeType.oak;
      case 1:
        return TreeType.pine;
      case 2:
        return TreeType.cherry;
      case 3:
        return TreeType.maple;
      case 4:
        return TreeType.willow;
      case 5:
        return TreeType.bamboo;
      case 6:
        return TreeType.cactus;
      case 7:
        return TreeType.palm;
      default:
        return TreeType.oak;
    }
  }

  @override
  void write(BinaryWriter writer, TreeType obj) {
    switch (obj) {
      case TreeType.oak:
        writer.writeByte(0);
        break;
      case TreeType.pine:
        writer.writeByte(1);
        break;
      case TreeType.cherry:
        writer.writeByte(2);
        break;
      case TreeType.maple:
        writer.writeByte(3);
        break;
      case TreeType.willow:
        writer.writeByte(4);
        break;
      case TreeType.bamboo:
        writer.writeByte(5);
        break;
      case TreeType.cactus:
        writer.writeByte(6);
        break;
      case TreeType.palm:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TreeModelAdapter extends TypeAdapter<TreeModel> {
  @override
  final int typeId = 1;

  @override
  TreeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TreeModel(
      id: fields[0] as String,
      type: fields[1] as TreeType,
      plantedAt: fields[2] as DateTime,
      durationMinutes: fields[3] as int,
      isDead: fields[4] as bool,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TreeModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.plantedAt)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.isDead)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
