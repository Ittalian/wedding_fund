# 出費計算機能の修正タスク

## 仕様まとめ
- 境界値: `minAllowedExpense <= 0` = 赤字、`minAllowedExpense > 0` = 黒字
- 赤字時: 費用减額提案 + savingByPayment減額提案 + 時期延長提案
- 黒字時: 前倒し提案 + 費用増額提案 + savingByPayment増額提案
- savingsGoalは提案から除去

## タスク

- [x] `app_state_provider.dart` の修正
  - [x] `_serializeSuggestions` / `_deserializeSuggestions` に新フィールド追加
  - [x] `isPlanDeficit` の境界値変更 (`mn < 0` → `mn <= 0`)
  - [x] リスト宣言に新リスト追加
  - [x] 赤字ブランチ: savingByPayment減額提案追加、savingsGoal提案削除
  - [x] 黒字ブランチ: savingByPayment増額提案追加、savingsGoal提案削除
  - [x] `computeSuggestions` 戻り値に新フィールド追加
  - [x] `FinancialCalculation.build` の境界値変更・戻り値更新
- [x] `home_screen.dart` の修正
  - [x] 赤字UI: savingByPayment減額提案カード追加
  - [x] 黒字UI: savingByPayment増額提案カード追加
  - [x] ヘルパーメソッド追加
