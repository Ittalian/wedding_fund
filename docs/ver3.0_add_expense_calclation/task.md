# タスクリスト: 出費計算リニューアル

## モデル層
- [x] `expense_item.dart` に `targetDate` を追加
- [x] `dart run build_runner build --delete-conflicting-outputs` 実行

## プロバイダー層
- [x] `app_state_provider.dart` のデータ移行ロジック（`_migrateBasicInfoData`）削除
- [x] `ItemAffordabilityCalculation` (時期計算) の修正: 賄える時期が `proposeDate` より早い場合は `proposeDate` を下限として返すように修正
- [x] `FinancialCalculation` (出費計算) の全面リニューアル: 各 `ExpenseItem` の `targetDate` に基づき、目標達成に必要な「毎月の最小許容出費額」を逆算

## UI層
- [x] `basic_info_screen.dart` の修正: `proposeDate` の保存不具合修正、`ExpenseItem` の `targetDate` 入力追加
- [x] `home_screen.dart` の修正: 新しい出費計算結果の表示に対応

## 検証
- [ ] `flutter run` によるビルドと画面遷移の確認
- [ ] 出費計算のロジックが正しく機能するか確認
