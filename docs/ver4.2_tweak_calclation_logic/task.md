# 実装タスク

- [x] 1. `lib/models/basic_info_data.dart` の編集 (`proposeDate` を `forecastStartDate` に変更)
- [x] 2. `lib/models/assets_data.dart` の編集 (`incomeDate`, `bonusDate` の追加)
- [x] 3. `build_runner` を実行して自動生成ファイルを更新
- [x] 4. `lib/screens/basic_info_screen.dart` の編集
  - [x] ラベルの変更（予測開始日）
  - [x] `yyyy/mm/dd` のバリデーション処理
- [x] 5. `lib/screens/assets_screen.dart` の編集
  - [x] 収入日、ボーナス日の入力フィールド追加
  - [x] 月末日付などの存在チェックを含むバリデーション処理
- [x] 6. `lib/providers/app_state_provider.dart` の編集
  - [x] 起点日を `forecastStartDate` に変更
  - [x] 収入とボーナスの日付ベースの正確な加算ロジック実装（今日の日付での判定含む）
  - [x] 時期計算の戻り値に残高 (`remainingBalance`) を追加
- [x] 7. `lib/screens/home_screen.dart` の編集 (残高表示のUI追加)
- [x] 8. `flutter analyze` による静的解析の確認
- [x] 9. `walkthrough.md` の作成
