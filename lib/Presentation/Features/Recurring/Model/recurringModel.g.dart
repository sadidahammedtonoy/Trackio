// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurringModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringModelAdapter extends TypeAdapter<RecurringModel> {
  @override
  final int typeId = 3;

  @override
  RecurringModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      category: fields[2] as String,
      type: fields[3] as String,
      wallet: fields[4] as String,
      note: fields[5] as String,
      frequency: fields[6] as String,
      lastExecutedMonthKey: fields[7] as String,
      isActive: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.wallet)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.frequency)
      ..writeByte(7)
      ..write(obj.lastExecutedMonthKey)
      ..writeByte(8)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
