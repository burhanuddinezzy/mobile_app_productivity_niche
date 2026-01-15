part of 'journal_entry_model.dart';

class JournalEntryAdapter extends TypeAdapter<JournalEntry> {
  @override
  final int typeId = 6;

  @override
  JournalEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalEntry(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      mood: fields[2] as MoodType,
      activityIds: (fields[3] as List).cast<String>(),
      note: fields[4] as String?,
      photoUrls: (fields[5] as List?)?.cast<String>() ?? const [],
    );
  }

  @override
  void write(BinaryWriter writer, JournalEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.activityIds)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.photoUrls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}