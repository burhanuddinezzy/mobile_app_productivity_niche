// GENERATED CODE - Put these in their respective .g.dart files
// Run: flutter packages pub run build_runner build

// ==================== mood_model.g.dart ====================
part of 'mood_model.dart';

class MoodTypeAdapter extends TypeAdapter<MoodType> {
  @override
  final int typeId = 4;

  @override
  MoodType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MoodType.awful;
      case 1:
        return MoodType.bad;
      case 2:
        return MoodType.meh;
      case 3:
        return MoodType.good;
      case 4:
        return MoodType.rad;
      default:
        return MoodType.meh;
    }
  }

  @override
  void write(BinaryWriter writer, MoodType obj) {
    switch (obj) {
      case MoodType.awful:
        writer.writeByte(0);
        break;
      case MoodType.bad:
        writer.writeByte(1);
        break;
      case MoodType.meh:
        writer.writeByte(2);
        break;
      case MoodType.good:
        writer.writeByte(3);
        break;
      case MoodType.rad:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// ==================== activity_model.g.dart ====================
