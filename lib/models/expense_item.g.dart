// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseItem _$ExpenseItemFromJson(Map<String, dynamic> json) => _ExpenseItem(
  id: json['id'] as String,
  name: json['name'] as String,
  cost: (json['cost'] as num).toInt(),
  order: (json['order'] as num).toInt(),
  targetDate: json['targetDate'] as String?,
);

Map<String, dynamic> _$ExpenseItemToJson(_ExpenseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cost': instance.cost,
      'order': instance.order,
      'targetDate': instance.targetDate,
    };
