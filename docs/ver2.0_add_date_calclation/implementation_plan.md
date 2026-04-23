# 実装計画: Wedding Fund アプリ修正（更新版）

## 概要

以下の修正・機能追加を行います。

1. `weddingDate` → `proposeDate`（`String?` 型、`yyyy/mm` 形式入力）
2. `BasicInfoData` に `monthlyExpense`（月の固定出費）を追加
3. **BasicInfoData の全費用項目**を `ExpenseItem` という統合モデルに変換し、ドラッグで順番変更・各項目の購入可能時期を表示
4. ホーム画面に「**時期計算**」「**出費額計算**」の2つのモードを追加

---

## 主要設計変更：費用項目の統合

現在 `BasicInfoData` にある固定費用フィールド（婚約指輪、結婚指輪、式、ハネムーン、引越し費用）と `furnitures`（家財道具リスト）を、**全て統合した `List<ExpenseItem>` に置き換えます**。

```dart
// 新モデル
class ExpenseItem {
  String id;
  String name;   // 例: '婚約指輪', '冷蔵庫'
  int cost;      // 費用（円）
  int order;     // 表示順（ドラッグで変更）
}
```

`BasicInfoData` は以下のように変わります：

| 変更前 | 変更後 |
|---|---|
| `DateTime? weddingDate` | `String? proposeDate`（`yyyy/mm`形式） |
| `int engagementRing` | → `ExpenseItem` として `expenses` リストに統合 |
| `int weddingRing` | → 同上 |
| `int weddingCeremony` | → 同上 |
| `int honeymoon` | → 同上 |
| `int movingCost` | → 同上 |
| `List<FurnitureItem> furnitures` | → 同上（家財道具もExpenseItemとして統合） |
| `int savingsGoal` | そのまま残す |
| *(新規)* | `int monthlyExpense`（月の固定出費） |
| *(新規)* | `List<ExpenseItem> expenses` |

> [!WARNING]
> Firestore に既存データがある場合、旧フォーマットとの互換性のため `fromJson` で移行処理を行います。

---

## 変更ファイル一覧

### モデル層

#### [NEW] `expense_item.dart` / `expense_item.freezed.dart` / `expense_item.g.dart`
- `id`, `name`, `cost`, `order` フィールドを持つ freezed モデル

#### [MODIFY] [basic_info_data.dart](file:///Users/itta/dev/dart/wedding_fund/lib/models/basic_info_data.dart)
- `proposeDate`（`String?`）追加、`weddingDate` 削除
- `expenses`（`List<ExpenseItem>`）追加
- `monthlyExpense`（`int`）追加
- 旧フィールド（`engagementRing` 等）削除
- `totalRequiredFunds` を `expenses` の合計 + `savingsGoal` に変更

#### [DELETE] `furniture_item.dart` / `.freezed.dart` / `.g.dart`
- `ExpenseItem` に統合するため削除

---

### プロバイダー層

#### [MODIFY] [app_state_provider.dart](file:///Users/itta/dev/dart/wedding_fund/lib/providers/app_state_provider.dart)
- `FinancialCalculation` を **2モード対応**に変更
- `weddingDate` → `proposeDate`（`yyyy/mm` → `DateTime` 変換）
- 新規: `ItemAffordabilityCalculation` プロバイダーを追加（各アイテムの購入可能時期を計算）

---

### UI層

#### [MODIFY] [basic_info_screen.dart](file:///Users/itta/dev/dart/wedding_fund/lib/screens/basic_info_screen.dart)
- `proposeDate` をテキスト入力（`yyyy/mm`バリデーション付き）に変更
- `monthlyExpense` 入力フィールドを追加
- 家財道具セクション廃止 → `expenses` を `ReorderableListView` で表示・並び替え
- アイテム追加ダイアログを汎用化（品名・金額の入力）
- 初期データに「婚約指輪」「結婚指輪」「結婚式」「新婚旅行」「新居の契約金」を自動追加

#### [MODIFY] [home_screen.dart](file:///Users/itta/dev/dart/wedding_fund/lib/screens/home_screen.dart)
- 「**出費額計算**」「**時期計算**」の2つのモードをタブまたはボタンで切り替え
  - **出費額計算**: `proposeDate` を目標として月の許容出費額を逆算（現行機能）
  - **時期計算**: 各 `ExpenseItem` を `order` 順に並べ、累積で何ヶ月後に賄えるかを計算・表示

---

## 購入可能時期 アルゴリズム（時期計算モード）

```
現在時点: now（現在月）
現在の貯金: currentSavings
月次収入: monthlyIncome（月末着）
月次出費: monthlyExpense（固定）
純月次増加: monthlyIncome - monthlyExpense

累積必要額 = 0
各アイテム（order順）:
  累積必要額 += item.cost
  m = 0
  ループ（最大600ヶ月）:
    m += 1
    貯金見込み = currentSavings
                + monthlyIncome * m      // 月末着収入
                - monthlyExpense * m     // 固定出費
                + ボーナス分（その月までの回数 × bonusAmount）
    if 貯金見込み >= 累積必要額:
      購入可能月 = now + m ヶ月 + 1ヶ月  // 月末受取なので翌月
      表示: yyyy/mm 形式
      break
  if 上限超過: '計算不可' と表示
```

---

## 検証計画

- `flutter pub run build_runner build --delete-conflicting-outputs` で freezed 再生成
- `flutter run` でビルド・動作確認
- `expenses` リストのドラッグ並び替え動作確認
- 時期計算・出費額計算の両モードで結果を手動検証
- 旧データとの互換性（fromJson）確認
