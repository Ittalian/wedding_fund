// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AssetsData _$AssetsDataFromJson(Map<String, dynamic> json) => _AssetsData(
  currentSavings: (json['currentSavings'] as num?)?.toInt() ?? 0,
  monthlyIncome: (json['monthlyIncome'] as num?)?.toInt() ?? 0,
  incomeDate: (json['incomeDate'] as num?)?.toInt() ?? 25,
  bonusAmount: (json['bonusAmount'] as num?)?.toInt() ?? 0,
  bonusMonths:
      (json['bonusMonths'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  bonusDate: (json['bonusDate'] as num?)?.toInt() ?? 5,
);

Map<String, dynamic> _$AssetsDataToJson(_AssetsData instance) =>
    <String, dynamic>{
      'currentSavings': instance.currentSavings,
      'monthlyIncome': instance.monthlyIncome,
      'incomeDate': instance.incomeDate,
      'bonusAmount': instance.bonusAmount,
      'bonusMonths': instance.bonusMonths,
      'bonusDate': instance.bonusDate,
    };
