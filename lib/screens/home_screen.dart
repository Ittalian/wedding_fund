import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_state_provider.dart';
import '../models/basic_info_data.dart';
import 'assets_screen.dart';
import 'basic_info_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum _CalcMode { expense, timing }

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _CalcMode _mode = _CalcMode.expense;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'ja_JP', symbol: '¥');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // モード切り替えボタン
              SegmentedButton<_CalcMode>(
                segments: const [
                  ButtonSegment(
                    value: _CalcMode.expense,
                    label: Text('出費額計算'),
                    icon: Icon(Icons.calculate),
                  ),
                  ButtonSegment(
                    value: _CalcMode.timing,
                    label: Text('時期計算'),
                    icon: Icon(Icons.calendar_month),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) =>
                    setState(() => _mode = s.first),
              ),
              const SizedBox(height: 16),

              if (_mode == _CalcMode.expense)
                Expanded(child: SingleChildScrollView(child: _buildExpenseMode(currencyFormatter)))
              else
                Expanded(child: SingleChildScrollView(child: _buildTimingMode(currencyFormatter))),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AssetsScreen())),
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('財産管理'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const BasicInfoScreen())),
                icon: const Icon(Icons.favorite),
                label: const Text('基本情報管理'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.pink.shade50,
                  foregroundColor: Colors.pink.shade900,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // 出費額計算モード（既存ロジック）
  // ──────────────────────────────────────────
  Widget _buildExpenseMode(NumberFormat fmt) {
    final calcData = ref.watch(financialCalculationProvider);

    if (calcData['isDataReady'] == true &&
        calcData['isDeficit'] == false &&
        calcData['message'] != null) {
      return Card(
        color: Colors.green.shade50,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            calcData['message'],
            style: const TextStyle(fontSize: 17, color: Colors.green),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (calcData['isDataReady'] == false || calcData['isDeficit'] == true) {
      final reductionSuggestions = calcData['reductionSuggestions'] as List<dynamic>?;
      final delaySuggestions = calcData['delaySuggestions'] as List<dynamic>?;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.red.shade50,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    calcData['message'] ?? '情報を入力してください',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  if (calcData['isDeficit'] == true && calcData['deficitAmount'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '現在不足額: ${fmt.format(calcData['deficitAmount'])}\n\n'
                        '計画や目標を見直してください。',
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (calcData['isDeficit'] == true && (reductionSuggestions != null || delaySuggestions != null)) ...[
            const SizedBox(height: 16),
            const Text(
              '改善提案',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            // 減額提案
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.money_off, color: Colors.teal, size: 20),
                        SizedBox(width: 8),
                        Text('費用の減額見直し', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (reductionSuggestions != null && reductionSuggestions.isNotEmpty)
                      ...reductionSuggestions.map((s) {
                        final name = s['name'] as String;
                        final suggestedCost = s['suggestedCost'] as int;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              Text('・$name を', style: const TextStyle(fontSize: 13)),
                              ActionChip(
                                label: Text(
                                  fmt.format(suggestedCost),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.teal,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -2),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _applyReductionSuggestion(
                                  context, name, suggestedCost, fmt),
                              ),
                              const Text('以下にする', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        );
                      })
                    else
                      const Text('1つの項目だけでは不足を補えません。\n複数の項目を合わせて減額するか、時期の延長をご検討ください。',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 時期提案
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.update, color: Colors.indigo, size: 20),
                        SizedBox(width: 8),
                        Text('費用の時期見直し', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (delaySuggestions != null && delaySuggestions.isNotEmpty)
                      ...delaySuggestions.map((s) {
                        final items = (s['items'] as List<dynamic>).cast<String>();
                        final date = s['requiredDate'] as DateTime;
                        final dateStr = '${date.year}/${date.month.toString().padLeft(2, '0')}';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            children: [
                              Text('・${items.join('・')} を', style: const TextStyle(fontSize: 13)),
                              ActionChip(
                                label: Text(
                                  '${date.year}年${date.month}月',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.indigo,
                                padding: EdgeInsets.zero,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -2),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  final origDate = s['originalDate'] as DateTime;
                                  final origStr = '${origDate.year}/${origDate.month.toString().padLeft(2, '0')}';
                                  _applyDelaySuggestion(context, items, origStr, dateStr);
                                },
                              ),
                              const Text('まで延長する', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        );
                      })
                    else
                      const Text('現在の収入では時期を伸ばしても達成が困難です。\n収入を増やすか費用を減額してください。',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ]
        ],
      );
    }

    final advanceSuggestions = calcData['advanceSuggestions'] as List<dynamic>?;
    final increaseSuggestions = calcData['increaseSuggestions'] as List<dynamic>?;
    final hasOptimization =
        (advanceSuggestions != null && advanceSuggestions.isNotEmpty) ||
        (increaseSuggestions != null && increaseSuggestions.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  '計算結果（出費額計算）',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text('目標達成に必要な毎月の出費上限額',
                    style: TextStyle(fontSize: 14)),
                Text(
                  fmt.format(calcData['monthlyAllowedExpense']),
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
                const SizedBox(height: 16),
                Text(
                  '全体の目標貯金額: ${fmt.format(calcData['targetSavings'])}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        if (hasOptimization) ...[
          const SizedBox(height: 16),
          const Text(
            '最適化提案',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          // Approach A: 目標時期の前倒し
          if (advanceSuggestions != null && advanceSuggestions.isNotEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.fast_forward, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('費用の時期を前倒しできます',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...advanceSuggestions.map((s) {
                      final name = s['name'] as String;
                      final earliestDate = s['earliestDate'] as DateTime;
                      final dateStr = '${earliestDate.year}/${earliestDate.month.toString().padLeft(2, '0')}';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text('・$name を', style: const TextStyle(fontSize: 13)),
                            ActionChip(
                              label: Text(
                                '${earliestDate.year}年${earliestDate.month}月',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -2),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                final origDate = s['originalDate'] as DateTime;
                                final origStr = '${origDate.year}/${origDate.month.toString().padLeft(2, '0')}';
                                _applyAdvanceSuggestion(context, name, origStr, dateStr);
                              },
                            ),
                            const Text('まで前倒しできます', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Approach B: 費用・貯金の増額
          if (increaseSuggestions != null && increaseSuggestions.isNotEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.deepPurple, size: 20),
                        SizedBox(width: 8),
                        Text('費用・貯金目標を増やせます',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...increaseSuggestions.map((s) {
                      final name = s['name'] as String;
                      final maxCost = s['maxCost'] as int;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text('・$name を', style: const TextStyle(fontSize: 13)),
                            ActionChip(
                              label: Text(
                                fmt.format(maxCost),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.deepPurple,
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: -2),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                final currentCost = s['currentCost'] as int;
                                _applyIncreaseSuggestion(context, name, currentCost, maxCost, fmt);
                              },
                            ),
                            const Text('まで増やせます', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }

  // ──────────────────────────────────────────
  // 時期計算モード（各項目を賄える時期を表示）
  // ──────────────────────────────────────────
  Widget _buildTimingMode(NumberFormat fmt) {
    final results = ref.watch(itemAffordabilityCalculationProvider);

    if (results.isEmpty) {
      return Card(
        color: Colors.orange.shade50,
        elevation: 0,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 40),
              SizedBox(height: 8),
              Text(
                '財産管理から月の収入を入力し、\n基本情報に費用項目を追加してください',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '各費用項目を賄える時期',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          '優先度順に累積計算 • 当月で賄える判定',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        ...results.asMap().entries.map((entry) {
          final index = entry.key;
          final result = entry.value;
          final item = result['item'];
          final affordableDate = result['affordableDate'] as String?;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
              ),
              title: Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(fmt.format(item.cost)),
              trailing: affordableDate != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('賄える時期',
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey)),
                        Text(
                          affordableDate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        if (result['remainingBalance'] != null)
                          Text(
                            '残高: ${fmt.format(result['remainingBalance'])}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.teal),
                          ),
                      ],
                    )
                  : const Text(
                      '計算不可',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
            ),
          );
        }),
      ],
    );
  }

  // ──────────────────────────────────────────
  // 提案適用ヘルパー
  // ──────────────────────────────────────────

  /// 現在の BasicInfoData を取得して更新・保存する共通処理
  Future<void> _saveBasicInfoChange(BasicInfoData Function(BasicInfoData) updater) async {
    final basicInfo = ref.read(basicInfoDataProvider).value;
    if (basicInfo == null) return;
    final newInfo = updater(basicInfo);
    await ref.read(basicInfoDataProvider.notifier).updateBasicInfo(newInfo);
    final assets = ref.read(assetsDataProvider).value;
    if (assets != null) {
      await ref.read(calculationCacheProvider.notifier).recompute(assets, newInfo);
    }
  }

  /// 確認ダイアログを表示し、OKなら [onConfirm] を実行
  Future<void> _showConfirmDialog({
    required BuildContext context,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('確認'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              // ① 確認ダイアログを閉じる
              Navigator.pop(ctx);
              if (!context.mounted) return;
              // ② 保存中ダイアログを表示
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx2) => PopScope(
                  canPop: false,
                  child: const AlertDialog(
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text('保存中...'),
                      ],
                    ),
                  ),
                ),
              );
              // ③ 保存処理
              await onConfirm();
              if (context.mounted) {
                // ④ 保存中ダイアログを閉じる
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('変更しました')));
              }
            },
            child: const Text('変更する'),
          ),
        ],
      ),
    );
  }

  /// 減額提案を適用（費用項目のcostを変更）
  Future<void> _applyReductionSuggestion(
    BuildContext context,
    String itemName,
    int suggestedCost,
    NumberFormat fmt,
  ) async {
    final isSavingsGoal = itemName == '目標貯金';
    final label = isSavingsGoal ? '目標貯金' : itemName;
    // 変更前の金額を basicInfo から取得
    final basicInfo = ref.read(basicInfoDataProvider).value;
    final currentCost = isSavingsGoal
        ? (basicInfo?.savingsGoal ?? 0)
        : (basicInfo == null ? 0 : basicInfo.expenses.firstWhere((e) => e.name == itemName, orElse: () => basicInfo.expenses.first).cost);
    await _showConfirmDialog(
      context: context,
      message: '「$label」の金額を\n${fmt.format(currentCost)}から${fmt.format(suggestedCost)}\n　に変更しますか？',
      onConfirm: () => _saveBasicInfoChange((info) {
        if (isSavingsGoal) {
          return info.copyWith(savingsGoal: suggestedCost);
        }
        final updated = info.expenses.map((e) {
          if (e.name == itemName) return e.copyWith(cost: suggestedCost);
          return e;
        }).toList();
        return info.copyWith(expenses: updated);
      }),
    );
  }

  /// 延長提案を適用（対象items全てのtargetDateを変更）
  Future<void> _applyDelaySuggestion(
    BuildContext context,
    List<String> itemNames,
    String originalDateStr,
    String newDateStr,
  ) async {
    String toDisplay(String s) => '${s.replaceFirst('/', '年').replaceAll('/', '月')}月';
    final namesDisplay = itemNames.join('・');
    await _showConfirmDialog(
      context: context,
      message: '「$namesDisplay」の目標時期を\n${toDisplay(originalDateStr)}から${toDisplay(newDateStr)}\n　に変更しますか？',
      onConfirm: () => _saveBasicInfoChange((info) {
        final updated = info.expenses.map((e) {
          if (itemNames.contains(e.name)) return e.copyWith(targetDate: newDateStr);
          return e;
        }).toList();
        return info.copyWith(expenses: updated);
      }),
    );
  }

  /// 前倒し提案を適用（費用項目のtargetDateを変更）
  Future<void> _applyAdvanceSuggestion(
    BuildContext context,
    String itemName,
    String originalDateStr,
    String newDateStr,
  ) async {
    String toDisplay(String s) => '${s.replaceFirst('/', '年').replaceAll('/', '月')}月';
    await _showConfirmDialog(
      context: context,
      message: '「$itemName」の目標時期を\n${toDisplay(originalDateStr)}から${toDisplay(newDateStr)}\n　に変更しますか？',
      onConfirm: () => _saveBasicInfoChange((info) {
        final updated = info.expenses.map((e) {
          if (e.name == itemName) return e.copyWith(targetDate: newDateStr);
          return e;
        }).toList();
        return info.copyWith(expenses: updated);
      }),
    );
  }

  /// 増額提案を適用（費用項目のcost または savingsGoalを変更）
  Future<void> _applyIncreaseSuggestion(
    BuildContext context,
    String itemName,
    int currentCost,
    int maxCost,
    NumberFormat fmt,
  ) async {
    final isSavingsGoal = itemName == '目標貯金';
    final label = isSavingsGoal ? '目標貯金' : itemName;
    await _showConfirmDialog(
      context: context,
      message: '「$label」の金額を\n${fmt.format(currentCost)}から${fmt.format(maxCost)}\n　に変更しますか？',
      onConfirm: () => _saveBasicInfoChange((info) {
        if (isSavingsGoal) {
          return info.copyWith(savingsGoal: maxCost);
        }
        final updated = info.expenses.map((e) {
          if (e.name == itemName) return e.copyWith(cost: maxCost);
          return e;
        }).toList();
        return info.copyWith(expenses: updated);
      }),
    );
  }
}
