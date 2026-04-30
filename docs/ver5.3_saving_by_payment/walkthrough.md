# 貯金詳細設定機能 実装ウォークスルー

## 概要

「常に目標額を貯金」チェックボックスの横に「貯金詳細設定」ボタンを追加し、  
各費用項目ごとに支払い後の目標貯金額を個別設定できる機能を実装しました。

---

## 変更内容

### 1. モデル変更 — `expense_item.dart`

`ExpenseItem` に `savingByPayment` フィールドを追加。

```dart
@Default(0) int savingByPayment, // この費用支払い後の目標貯金額
```

`build_runner` で freezed / json_serializable コードを再生成済み。

---

### 2. 新規画面 — `savings_detail_screen.dart`

各費用項目の `savingByPayment` を個別に入力できる画面。

**主な機能:**
- 全費用項目をカード形式でリスト表示
- 各カードに「支払い後の目標貯金額（円）」入力フィールド
- 未入力のヒントテキストに `savingsGoal`（目標貯金額）を表示
- 個別の ✕ ボタンでフィールドをクリア
- AppBar 右の「全て削除」ボタンで全フィールドを一括クリア（確認ダイアログあり）
- 「保存する」ボタンで結果を前画面に返却（`Navigator.pop`）
- 保存時、1つでも設定がある場合は `shouldUncheckAlwaysKeep: true` を通知

---

### 3. 画面変更 — `basic_info_screen.dart`

チェックボックスの行に「貯金詳細設定」ボタン（`OutlinedButton`）を追加。

```
[ ] 常に目標額を貯金          [⚙ 貯金詳細設定]
```

**遷移ロジック:**
- ボタン押下 → `SavingsDetailScreen` へ `Navigator.push`
- 戻り値の `expenses` を `_expenses` に反映
- `shouldUncheckAlwaysKeep == true` の場合、`_alwaysKeepSavingsGoal = false` に設定

---

### 4. 計算ロジック変更 — `app_state_provider.dart`

**適用条件:** `!alwaysKeepSavingsGoal && expenses.any((e) => e.savingByPayment > 0)`

適用時の挙動:
- 各費用項目を支払う時点で「`cumulativeCost + minBalance`」を必要額として評価
- `minBalance` = `savingByPayment > 0` ? `savingByPayment` : `savingsGoal`（未設定項目は目標貯金額をフォールバック）
- 詳細設定有効時は `savingsGoal` を targets に別途追加しない（各項目の `minBalance` で吸収）

**反映した計算クラス:**

| クラス | 用途 |
|---|---|
| `computeSuggestions` | Firestore キャッシュ用の提案計算 |
| `FinancialCalculation` | ホーム画面の出費額計算 |
| `ItemAffordabilityCalculation` | 時期計算 |

---

## 検証

```
flutter analyze → No issues found!
```

---

## チェックボックスと詳細設定の優先ルール

| チェック | 詳細設定 | 適用される計算 |
|---|---|---|
| **ON** | あり / なし | 全項目に `savingsGoal` を最低残高として適用（従来通り） |
| **OFF** | **あり** | 各項目の `savingByPayment`（未設定は `savingsGoal`）を最低残高として適用 |
| **OFF** | なし | 最低残高なし（従来通り） |

> 詳細設定画面を保存するとチェックが自動でOFFになりますが、  
> その後手動でONにした場合はチェックが優先されます。
