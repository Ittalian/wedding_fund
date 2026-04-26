// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_info_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BasicInfoData _$BasicInfoDataFromJson(Map<String, dynamic> json) =>
    _BasicInfoData(
      forecastStartDate: json['forecastStartDate'] as String?,
      monthlyExpense: (json['monthlyExpense'] as num?)?.toInt() ?? 0,
      expenses:
          (json['expenses'] as List<dynamic>?)
              ?.map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      savingsGoal: (json['savingsGoal'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BasicInfoDataToJson(_BasicInfoData instance) =>
    <String, dynamic>{
      'forecastStartDate': instance.forecastStartDate,
      'monthlyExpense': instance.monthlyExpense,
      'expenses': instance.expenses.map((e) => e.toJson()).toList(),
      'savingsGoal': instance.savingsGoal,
    };
