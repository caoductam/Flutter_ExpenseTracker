// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BudgetAdapter extends TypeAdapter<Budget> {
  @override
  final int typeId = 1;

  @override
  Budget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Budget(
      id: fields[0] as String,
      category: fields[1] as String,
      monthlyLimit: fields[2] as double,
      month: fields[3] as int,
      year: fields[4] as int,
      alertEnabled: fields[5] as bool,
      alertThreshold: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Budget obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.monthlyLimit)
      ..writeByte(3)
      ..write(obj.month)
      ..writeByte(4)
      ..write(obj.year)
      ..writeByte(5)
      ..write(obj.alertEnabled)
      ..writeByte(6)
      ..write(obj.alertThreshold);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
