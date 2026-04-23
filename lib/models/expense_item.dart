import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_item.freezed.dart';
part 'expense_item.g.dart';

@freezed
abstract class ExpenseItem with _$ExpenseItem {
  const factory ExpenseItem({
    required String id,
    required String name,
    required int cost,
    required int order,
    String? targetDate, // yyyy/mm 形式
  }) = _ExpenseItem;

  factory ExpenseItem.fromJson(Map<String, dynamic> json) =>
      _$ExpenseItemFromJson(json);
}
