# タスクリスト

## モデル層
- [x] `expense_item.dart` 新規作成
- [x] `basic_info_data.dart` 修正（`proposeDate`, `expenses`, `monthlyExpense` 追加・旧フィールド削除）
- [x] `furniture_item.dart` 削除

## コード生成
- [x] `dart run build_runner build --delete-conflicting-outputs` → No issues found!

## プロバイダー層
- [x] `app_state_provider.dart` 修正（旧データ移行、`proposeDate` 対応、`ItemAffordabilityCalculation` 追加）

## UI層
- [x] `basic_info_screen.dart` 修正（proposeDate テキスト入力、monthlyExpense フィールド、ReorderableListView）
- [x] `home_screen.dart` 修正（出費額計算・時期計算 2モード追加）

## 検証
- [ ] `flutter run` でビルド・動作確認
- [ ] ドラッグ並び替え動作確認
- [ ] 時期計算・出費額計算の両モードで手動検証
