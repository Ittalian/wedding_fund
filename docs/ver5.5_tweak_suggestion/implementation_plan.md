# 出費計算機能の修正

## 概要

「出費額計算」モードの提案ロジックを以下の方針で修正する。

- **赤字（不足）の場合**: 貯金額（savingsGoal）の見直し提案を追加
- **黒字（余剰）の場合**: 費用の時期の前倒し提案（既存）に加えて、月ごとの出費が0になる境界値を探索

**重要な仕様変更点**:
> 月ごとの出費額（`monthlyExpense`）に入力されている値は、「時期計算」の収支シミュレーションで使用するが、「出費額計算」の`isPlanDeficit()`判定では使用しない（現在はすでに使われていない）。  
> 「月ごとの出費が0になるところを提案の境界値とする」= 現在の `monthlyAllowedExpense == 0` になるラインを境界とする。つまり、`isPlanDeficit`の判定基準を `minAllowedExpense < 0` から変更するのではなく、**提案の境界値として「月ごとの出費ゼロライン」を使う**。

---

## ユーザーレビュー必須

> [!IMPORTANT]
> 「月ごとの出費が0になるところを提案の境界値とする」の解釈を確認します。
>
> 現在のロジック：
> - `minAllowedExpense < 0` → 不足判定（赤字提案）
> - `minAllowedExpense >= 0` → 余剰判定（前倒し・増額提案）
>
> **新しい境界値の解釈**:
> - 足りない提案（赤字側）: `minAllowedExpense < 0` のとき → 貯金額見直し提案と時期延長提案を表示
> - 足りている提案（黒字側）: `minAllowedExpense >= 0` のとき → 前倒し提案と増額提案を表示
>
> 「月ごとの出費が0になるところ」= `minAllowedExpense == 0` の境界を基準に、  
> - 赤字提案: 月出費上限が0以下（赤字か収支ゼロ）になる場合に表示  
> - 黒字提案: 月出費上限が正（余剰あり）の場合に表示  
>
> この解釈で合っていますか？現在のロジックと実質的に同じです。

> [!IMPORTANT]
> 「足りない場合の貯金額見直し提案」について：
> - 現在は「費用の減額提案」のみ。これに加えて `savingsGoal` を減らす提案を追加（既に `目標貯金` として提案されている）。
> - それとも「貯金額を増やす」（追加貯金の提案）という別の意味でしょうか？
>
> **推測**: 赤字時に「貯金額目標（savingsGoal）を下げる提案」を追加 → 既に `reductionSuggestions` に `目標貯金` として入っているため、UIに明示的に表示するよう修正する。

---

## 変更内容

### `app_state_provider.dart`

#### 赤字時の貯金見直し提案（`computeSuggestions`）

現在は `reductionSuggestions` の中に `目標貯金` の減額提案が含まれているが、savingsGoalの見直し提案として**別フィールド**として返す。

```
'savingsGoalSuggestion': {'currentGoal': X, 'suggestedGoal': Y}
```

#### `isPlanDeficit` の境界値

月ごとの出費額（`monthlyExpense`）は出費計算に影響しないため変更不要。  
ただし、`isPlanDeficit` の判定は `minAllowedExpense < 0` で維持する（境界はゼロ）。

---

### 変更の方針

#### [MODIFY] `app_state_provider.dart`

**`computeSuggestions` の変更点**:

1. **赤字時の貯金額見直し提案**: `savingsGoalSuggestion` フィールドを追加（`savingsGoal`の最大許容値を二分探索）
2. **戻り値に `savingsGoalSuggestion` を追加**
3. **シリアライズ/デシリアライズ**: `savingsGoalSuggestion` の対応を追加

**`FinancialCalculation.build` の変更点**:

1. 戻り値に `savingsGoalSuggestion` を追加
2. 黒字時（余剰あり）の前倒し提案の境界値確認（変更不要）

---

#### [MODIFY] `home_screen.dart`

**赤字時（`isDeficit == true`）**:
- 既存: `reductionSuggestions`（費用の減額）、`delaySuggestions`（時期延長）
- **追加**: `savingsGoalSuggestion`（貯金目標の見直し）カードを追加

**黒字時**:
- 既存: `advanceSuggestions`（前倒し）、`increaseSuggestions`（増額）
- 変更なし

---

## 検証方法

### 自動テスト
なし（既存のテストフレームワークなし）

### 手動検証
1. 不足状態のデータで「出費額計算」を開き、貯金目標の見直し提案が表示されることを確認
2. 余剰状態のデータで「出費額計算」を開き、前倒し提案が表示されることを確認
3. `savingsGoal == 0` のケースで正常動作することを確認
