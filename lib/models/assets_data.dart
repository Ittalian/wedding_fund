import 'package:freezed_annotation/freezed_annotation.dart';

part 'assets_data.freezed.dart';
part 'assets_data.g.dart';

@freezed
abstract class AssetsData with _$AssetsData {
  const factory AssetsData({
    @Default(0) int currentSavings,
    @Default(0) int monthlyIncome,
    @Default(25) int incomeDate, // 平均収入が入る日 (1~31)
    @Default(0) int bonusAmount,
    @Default([]) List<int> bonusMonths, // ボーナスの支給月 (例: [6, 12])
    @Default(5) int bonusDate, // ボーナスが入る日 (1~31)
  }) = _AssetsData;

  factory AssetsData.fromJson(Map<String, dynamic> json) =>
      _$AssetsDataFromJson(json);
}
