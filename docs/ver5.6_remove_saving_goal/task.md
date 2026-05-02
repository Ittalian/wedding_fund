# タスクリスト

- [x] `BasicInfoScreen` から「必要な貯金目標額」のテキストボックスを削除
- [x] `BasicInfoScreen` の「貯金詳細設定」ボタンの名前を「貯金目標設定」に変更し、文字色を黒に設定
- [x] `BasicInfoScreen` およびシステム全体から「必要な貯金目標額」の設定を完全削除
- [x] `BasicInfoScreen` およびデータモデルから「貯金目標設定を有効化」のチェックボックスおよび `alwaysKeepSavingsGoal` プロパティを完全削除
- [x] `app_state_provider.dart` を更新し、各費用の「支払い後貯金額」の設定が常に有効になるようにロジックを修正。未設定の場合は ¥0 として計算
- [x] `BasicInfoScreen` のボタンを「各費用の支払い後貯金目標を設定する」という横長のボタンに変更しUIを改善
- [x] `HomeScreen` の「支払い後貯金額提案」にある確認ダイアログのメッセージから改行を削除
