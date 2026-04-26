# プロポーズ予定日の変更と詳細な資金計算シミュレーションの実装

## 目的
1. 基本情報の「プロポーズ予定日」を「予測開始日 (yyyy/mm/dd)」に変更する。
2. 財産管理で「平均収入の入る日」「ボーナスの入る日」を入力可能にする。
3. 月単位の概算だった資金シミュレーションを、指定された「日」ベースで正確に計算するように変更し、「今日の日付」に基づき今月分の収入が加味されているかを判定する。
4. 時期計算の画面で、各項目を支払った後の貯金残高を表示する。

> [!IMPORTANT]
> ## User Review Required
> 
> ユーザー様への確認事項があります。以下の「Open Questions」をご確認ください。

## Open Questions

> [!WARNING]
> **1. 「今日の日付」に基づく収入加算判定について**
> ご要望にある「今月分の収入が貯金額に入っているかは、今日の日付がそれらの日付より前か後かで判定する」という点について、以下の解釈で実装してよろしいでしょうか？
> 
> - **解釈**: 現在入力されている「現在の貯金額」は「現実の今日時点の金額」であると見なします。そのため、「現実の今の月」については、今日の日付(`DateTime.now().day`)が「収入日」より前であれば「今月分の給料はこれから入る（計算で加算する）」、後であれば「既に貯金額に含まれている（加算しない）」と判定します。
> 
> **2. シミュレーションの起点について**
> 「予測開始日」を過去の日付（例：先月）に設定した場合、シミュレーションは「予測開始日」からスタートしますが、現在の貯金額は「今日時点」として計算に矛盾が生じないように、「予測開始日」は基本的に「今日以降」を想定した機能（未来からのキャッシュフローを見積もるためのもの）として扱います。もし「過去の特定の時点からの推移を再現したい」という意図がある場合は、ロジックを大きく変える必要がありますが、今回は「未来のシミュレーションの起点日」としての実装でよろしいでしょうか？

## Proposed Changes

---

### Models (データモデル)

#### [MODIFY] [basic_info_data.dart](file:///Users/itta/dev/dart/wedding_fund/lib/models/basic_info_data.dart)
- `proposeDate` フィールドを削除し、代わりに `startDate` (String, `yyyy/mm/dd` 形式) を追加します。

#### [MODIFY] [assets_data.dart](file:///Users/itta/dev/dart/wedding_fund/lib/models/assets_data.dart)
- `incomeDate` (int, 例: 25) を追加します。
- `bonusDate` (int, 例: 10) を追加します。

*(※ モデル変更に伴い `build_runner` を実行して `.freezed.dart` と `.g.dart` を再生成します)*

---

### Screens (UI画面)

#### [MODIFY] [basic_info_screen.dart](file:///Users/itta/dev/dart/wedding_fund/lib/screens/basic_info_screen.dart)
- 「プロポーズ予定年月」のラベルを「予測開始日 (yyyy/mm/dd)」に変更します。
- バリデーションを `yyyy/mm` から `yyyy/mm/dd` (実在する日付かどうかのチェックを含む) に変更します。

#### [MODIFY] [assets_screen.dart](file:///Users/itta/dev/dart/wedding_fund/lib/screens/assets_screen.dart)
- 「平均収入が入る日 (1~31)」「ボーナスが入る日 (1~31)」の入力フィールドを追加します。
- バリデーションの追加：
  - 数値かつ1〜31の範囲であること。
  - ボーナスについては、選択された `bonusMonths` (ボーナス月) 全てにおいて、入力された日付が存在するかを検証します（例：ボーナス月が2月で、日付を30日とした場合はエラー）。

#### [MODIFY] [home_screen.dart](file:///Users/itta/dev/dart/wedding_fund/lib/screens/home_screen.dart)
- 時期計算モード (`_buildTimingMode`) のリスト表示において、計算結果から受け取った「支払った後の貯金残高」を表示するように UI を改修します。

---

### Providers & Logic (計算ロジック)

#### [MODIFY] [app_state_provider.dart](file:///Users/itta/dev/dart/wedding_fund/lib/providers/app_state_provider.dart)
- `_parseProposeDate` を `_parseStartDate` に変更し、`yyyy/mm/dd` に対応させます。
- **出費額計算 (`FinancialCalculation`)**
  - 計算の起点を `DateTime.now()` から、入力された `startDate` (予測開始日) に変更します。
  - `monthsLeft` による大まかな月数掛け算をやめ、`startDate` から各 `targetDate` までの「年月」をイテレートし、各月に設定された `incomeDate` および `bonusDate` が到来するかどうかを日付ベースで正確にカウントするヘルパー関数を導入します。
  - 「今月の収入・ボーナス」の判定として、ループ処理の中で対象月が現実の「今月」と一致する場合に限り、`DateTime.now().day` と `incomeDate` / `bonusDate` を比較し、既に過ぎていれば加算しない（現在の貯金に反映済みとする）ロジックを適用します。
- **時期計算 (`ItemAffordabilityCalculation`)**
  - 同様に日付ベースでのキャッシュフロー加算ロジックに変更します。
  - 各項目の金額を支払える日に達した時点での「総資産 - 累積費用」を計算し、`remainingBalance` (貯金残高) として結果マップに含めて返却します。

## Verification Plan

### Automated Tests
- `flutter analyze` による静的解析の通過確認。
- `flutter pub run build_runner build` によるモデルファイルの正常な再生成。

### Manual Verification
1. **基本情報画面**: 予測開始日に `2026/05/10` などの `yyyy/mm/dd` 形式が正常に保存されること、無効な日付（例: 2026/02/30）が弾かれることを確認。
2. **財産管理画面**: 収入日・ボーナス日が保存されること。2月をボーナス月に設定した状態でボーナス日を30日に設定するとエラーになることを確認。
3. **出費額計算**: 現在の日付と収入日を変動させ、「今月の収入」が反映される・されない場合の出費許容額が期待通りに変化するかを確認。
4. **時期計算**: ホーム画面の時期計算タブにて、各費用項目の達成時期に加え「達成後の残高: ¥◯◯」が正しく表示されることを確認。
