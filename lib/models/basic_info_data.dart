import 'package:freezed_annotation/freezed_annotation.dart';
import 'expense_item.dart';

part 'basic_info_data.freezed.dart';
part 'basic_info_data.g.dart';

@freezed
abstract class BasicInfoData with _$BasicInfoData {
  const BasicInfoData._();

  const factory BasicInfoData({
    String? proposeDate, // yyyy/mm 形式
    @Default(0) int monthlyExpense, // 月の固定出費
    @Default([]) List<ExpenseItem> expenses,
    @Default(0) int savingsGoal,
  }) = _BasicInfoData;

  factory BasicInfoData.fromJson(Map<String, dynamic> json) =>
      _$BasicInfoDataFromJson(json);

  int get totalRequiredFunds {
    final expenseTotal = expenses.fold<int>(0, (sum, item) => sum + item.cost);
    return expenseTotal + savingsGoal;
  }
}
