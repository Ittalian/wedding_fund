import 'package:freezed_annotation/freezed_annotation.dart';

part 'assets_data.freezed.dart';
part 'assets_data.g.dart';

@freezed
abstract class AssetsData with _$AssetsData {
  const factory AssetsData({
    @Default(0) int currentSavings,
    @Default(0) int monthlyIncome,
    @Default(0) int bonusAmount,
    @Default([]) List<int> bonusMonths, // ボーナスの支給月 (例: [6, 12])
  }) = _AssetsData;

  factory AssetsData.fromJson(Map<String, dynamic> json) =>
      _$AssetsDataFromJson(json);
}
