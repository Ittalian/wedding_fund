# 提案キャッシュのDB保存化

## 概要

現在、`FinancialCalculation.build()` が毎回ストリーム更新のたびに二分探索（O(log N) × 項目数）を実行しているため、起動時/データ変更時に遅延が発生している。

**改善方針**:
- 二分探索による提案計算をFirestoreにキャッシュする
- 画面はキャッシュを読んで表示する（高速）
- データ保存時のみ再計算して更新する

---

## アーキテクチャ

```
保存時:
  UserSave → computeSuggestions() → Firestore[calculationCache]

表示時:
  FinancialCalculation.build()
    ├─ 速い計算（検証 + monthlyAllowedExpense）
    └─ Firestore[calculationCache] からキャッシュ読み込み
```

---

## 変更ファイル

### providers/app_state_provider.dart

#### [MODIFY] [app_state_provider.dart](file:///Users/itta/dev/dart/wedding_fund/lib/providers/app_state_provider.dart)

**① DateTime シリアライズヘルパー追加（行123の後）**
- `_dateToStr(DateTime) → String` (例: `'2026-06-30'`)
- `_strToDate(String) → DateTime`

**② `_computeSuggestions(AssetsData, BasicInfoData) → Map` 関数追加（行123の後）**
- 現在 `FinancialCalculation.build()` にある二分探索ブロックを全て移動
- 戻り値: `reductionSuggestions / delaySuggestions / advanceSuggestions / increaseSuggestions`
- DateTimeはそのまま（保存前にシリアライズ）

**③ `_serializeSuggestions / _deserializeSuggestions` ヘルパー追加**
- DateTimeを文字列に変換してFirestore保存可能にする

**④ `FinancialCalculation.build()` の修正**
- 二分探索ブロック（行258〜484）を削除
- キャッシュプロバイダを watch して提案を取得
- 返却Mapにキャッシュの提案をマージ

**⑤ `CalculationCacheNotifier` クラスを追加（`FinancialCalculation`の後）**
```dart
@riverpod
class CalculationCacheNotifier extends _$CalculationCacheNotifier {
  Stream<Map<String, dynamic>?> build() {
    // Firestore の calculationCache フィールドを監視
  }
  Future<void> recompute(AssetsData assets, BasicInfoData basicInfo) async {
    // _computeSuggestions() を呼び、シリアライズしてFirestoreに保存
  }
}
```

---

### screens/assets_screen.dart

#### [MODIFY] [assets_screen.dart](file:///Users/itta/dev/dart/wedding_fund/lib/screens/assets_screen.dart)

- `_save()` メソッドで `updateAssets(data)` 後に:
  - 現在の basicInfoData を `ref.read(basicInfoDataProvider).value` で取得
  - `ref.read(calculationCacheNotifierProvider.notifier).recompute(data, basicInfo)` を呼ぶ

---

### screens/basic_info_screen.dart

#### [MODIFY] [basic_info_screen.dart](file:///Users/itta/dev/dart/wedding_fund/lib/screens/basic_info_screen.dart)

- `_save()` メソッドで `updateBasicInfo(data)` 後に:
  - 現在の assetsData を `ref.read(assetsDataProvider).value` で取得
  - `ref.read(calculationCacheNotifierProvider.notifier).recompute(assets, data)` を呼ぶ

---

## UX考慮

- **初回起動時（キャッシュなし）**: 提案セクションを非表示にする（既存の `?? []` で空リスト扱い）
- **保存後**: Firestoreが更新され、ストリームで自動的にUIに反映される

---

## 検証計画

```bash
flutter analyze
```
- 起動直後に提案が空（非表示）→ 保存後に提案が表示されることを確認
