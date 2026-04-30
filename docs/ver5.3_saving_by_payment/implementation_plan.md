# 貯金詳細設定機能の実装

「常に目標額を貯金」チェックボックスの横に「貯金詳細設定」ボタンを追加し、  
各費用項目の支払い後に維持すべき目標貯金額を個別に設定できる新しい画面を実装します。

## ユーザーレビュー事項

> [!IMPORTANT]
> **設計の確認事項（フィードバック反映済み）**
> - 詳細設定画面を保存した際に、「常に目標額を貯金」チェックボックスを自動的に**オフ**にします
> - その後、ユーザーが手動でチェックをオンにした場合はそちらを優先します
> - 適用条件：**「チェックがオフ」かつ「1つ以上の詳細設定が入力済み」**の場合に詳細設定を使用
> - 詳細設定画面は `Navigator.push` による遷移（スタックに積む）とします

> [!NOTE]
> **詳細設定の仕様**
> - 各費用項目ごとに「この費用を支払った後も維持したい貯金額（円）」を設定
> - 0の場合は詳細設定なし（デフォルト）
> - **詳細設定が未入力の項目は `savingsGoal`（目標貯金額）を代わりに使用して計算**
> - 設定値は `ExpenseItem` に `savingByPayment` フィールドとして追加
> - 詳細設定画面に「全ての詳細設定を削除」ボタンを配置

## 提案する変更

---

### モデル層

#### [MODIFY] [expense_item.dart](file:///Users/itta/dev/dart/wedding_fund/lib/models/expense_item.dart)
- `savingByPayment` フィールドを追加（`@Default(0) int savingByPayment`）

#### [MODIFY] [expense_item.freezed.dart](file:///Users/itta/dev/dart/wedding_fund/lib/models/expense_item.freezed.dart)
- `build_runner` で自動生成するため、手動編集は不要

#### [MODIFY] [expense_item.g.dart](file:///Users/itta/dev/dart/wedding_fund/lib/models/expense_item.g.dart)
- 同上、`build_runner` で自動生成

---

### 計算ロジック

#### [MODIFY] [app_state_provider.dart](file:///Users/itta/dev/dart/wedding_fund/lib/providers/app_state_provider.dart)
- 適用条件：`!alwaysKeepSavingsGoal && expenses.any((e) => e.savingByPayment > 0)`
- 各費用項目の `savingByPayment`（未設定なら `savingsGoal`）を累積コストに加算して計算
- `ItemAffordabilityCalculation`・`FinancialCalculation`・`computeSuggestions` の全てに反映

---

### 画面層

#### [NEW] [savings_detail_screen.dart](file:///Users/itta/dev/dart/wedding_fund/lib/screens/savings_detail_screen.dart)
- 各費用項目をリストで表示
- 各項目に「この費用支払い後の目標貯金額（円）」入力フィールド
- 「全ての詳細設定を削除」ボタンを配置（全項目の `savingByPayment` を 0 にリセット）
- 「保存」ボタンで `_expenses` を更新して前の画面に戻る（`Navigator.pop(result)` でリストを返す）
- 保存時に、1つでも `savingByPayment > 0` の項目があれば `alwaysKeepSavingsGoal = false` を通知

#### [MODIFY] [basic_info_screen.dart](file:///Users/itta/dev/dart/wedding_fund/lib/screens/basic_info_screen.dart)
- チェックボックスの行に「貯金詳細設定」ボタン（`OutlinedButton`）を追加
- ボタン押下で `SavingsDetailScreen` に `Navigator.push` し、結果を受け取って `_expenses` と `_alwaysKeepSavingsGoal` を更新
- 詳細設定保存時に `alwaysKeepSavingsGoal` を `false` に設定

---

## 検証計画

### 自動テスト
```bash
flutter analyze
flutter pub run build_runner build --delete-conflicting-outputs
```

### 手動確認
1. 「貯金詳細設定」ボタンをタップ → 詳細設定画面に遷移する
2. いずれかの費用項目に金額を入力して保存 → 「常に目標額を貯金」チェックがオフになる
3. チェックをオンに戻す → 詳細設定は保持されるが計算時には無視される（別途確認）
4. 詳細設定を全て0に戻す → チェックの状態はそのまま
