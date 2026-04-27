# 提案キャッシュDB保存化 — ウォークスルー

## 概要

出費額計算の「改善提案」「最適化提案」を生成する二分探索処理が、アプリ起動のたびに実行されていたため遅延が発生していた。  
**保存時のみ計算してFirestoreにキャッシュ**し、表示時はキャッシュを読むだけにすることで解決した。

---

## アーキテクチャ変更

```
【変更前】
データ変更検知 → FinancialCalculation.build() → 毎回二分探索 → UI（遅い）

【変更後】
表示時: FinancialCalculation.build() → 高速計算 + Firestoreキャッシュ読取 → UI（速い）
保存時: _save() → computeSuggestions() → Firestore[calculationCache]
```

---

## 変更内容

### `providers/app_state_provider.dart`

| 追加・変更 | 内容 |
|---|---|
| `_dateToStr / _strToDate` | DateTime ↔ Firestore文字列 変換ヘルパー |
| `_serializeSuggestions` | DateTimeを含むMapをFirestore保存可能形式に変換 |
| `_deserializeSuggestions` | Firestoreの文字列をDateTimeに復元 |
| `computeSuggestions()` | 二分探索を含む全提案計算（保存時のみ呼ぶ） |
| `FinancialCalculation.build()` | 二分探索を削除、`calculationCacheProvider` からキャッシュを読んでマージ |
| `CalculationCacheNotifier` | Firestoreの `calculationCache` をStreamで提供 + `recompute()` メソッド |

### `screens/assets_screen.dart`

- `_save()` にて `updateAssets()` 後に `calculationCacheProvider.notifier.recompute()` を呼ぶ

### `screens/basic_info_screen.dart`

- `_save()` にて `updateBasicInfo()` 後に `calculationCacheProvider.notifier.recompute()` を呼ぶ

---

## 注意点

> **初回起動時（未保存）**: `calculationCache` がFirestoreにまだ存在しないため、提案セクションは非表示になる。  
> 財産管理または基本情報を保存すると、その時点でキャッシュが生成され、以降は提案が表示される。

---

## 検証結果

```
flutter analyze → No issues found!
build_runner build → 2 outputs generated
```
