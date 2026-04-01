// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tranModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranItemAdapter extends TypeAdapter<TranItem> {
  @override
  final int typeId = 0;

  @override
  TranItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranItem(
      id: fields[0] as String,
      monthKey: fields[1] as String,
      type: fields[2] as String,
      date: fields[3] as DateTime,
      amount: fields[4] as double,
      wallet: fields[5] as String,
      category: fields[6] as String,
      note: fields[7] as String,
      marked: fields[8] as bool,
      isSynced: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TranItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.monthKey)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.amount)
      ..writeByte(5)
      ..write(obj.wallet)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.marked)
      ..writeByte(9)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
