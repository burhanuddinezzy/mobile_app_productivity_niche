part of 'session_model.dart';

class SessionModelAdapter extends TypeAdapter<SessionModel> {
  @override
  final int typeId = 2;

  @override
  SessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionModel(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime?,
      plannedDuration: fields[3] as int,
      actualDuration: fields[4] as int,
      completed: fields[5] as bool,
      treeType: fields[6] as TreeType,
      coinsEarned: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SessionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.plannedDuration)
      ..writeByte(4)
      ..write(obj.actualDuration)
      ..writeByte(5)
      ..write(obj.completed)
      ..writeByte(6)
      ..write(obj.treeType)
      ..writeByte(7)
      ..write(obj.coinsEarned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}